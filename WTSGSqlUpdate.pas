unit WTSGSqlUpdate;
{$mode objfpc}{$H+}

interface

uses
  SysUtils, Classes, Controls, Grids,
  {$IFDEF MSWINDOWS} Windows,Variants, {$ENDIF} Dialogs,LSystemTrita,UIB, Menus, wtList ,
  LCLType,WTStringGridSql,Graphics;

type
 { TOldCellValue = record
   Row:integer;
   Col:integer;
   Value:String;
  end;}
  Toperazione = (OpBrowse,OpInsert,OpEdit, OpDelete);
  TStatoUpdateKind = (stInsert,stEdit,stDelete);
  TStatoUpdate  = set of TStatoUpdateKind;
  TBeforeInsert = procedure (Sender: Tobject; Ffield:TwtListField) of object;
  TBeforeUpdate = procedure (Sender: Tobject;var where: string; var aRow:integer) of object;
  TBeforeDelete = procedure (Sender: Tobject;var where: string; var aRow:integer) of object;

  { TwtSGSqlUpdate }

  TwtSGSqlUpdate = class(TwtStringGridSql)
  private
    FBeforeUpdate: TBeforeUpdate;
    FBeforeDelete: TBeforeDelete;
    FBeforeInsert: TBeforeInsert;
    FIBsqlPost:    TUIBQuery;  //oggetto che servirà per modificare il recordo
    Foperazione :  Toperazione;
    FStatoUpdate:  TStatoUpdate;
    FIndexRiga:integer; //posizione della riga i cui valori sono stati memorizzati del array temporaneo
    FListSql : TStringList; // contiene le istruzioni sql delle righe modificate
    procedure  UpDateDB(riga:Integer); // Modifica i dati della tabella
    procedure  InsertDB(riga:Integer); //Inserisce i dati nella tabella
    procedure  CancellaDB(riga:Integer); //Cancella i dati nella tabella

//    function  EseguiSql(st,errore:string):Boolean;
    procedure SetStatoUpdate(const Value: TStatoUpdate);
    { Private declarations }
  protected
    procedure IntestaGrid; override;
    procedure InsertPopMenu (Sender: TObject);
    procedure DeletePopMenu (Sender: TObject);
    procedure DoBeforeUpdate(var where: string; var aRow:integer);
    procedure DoBeforeDelete(Sender: Tobject; var where: string; var aRow:integer);
    procedure DoBeforeInsert(Sender: Tobject; Ffield:TwtListField);
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X: Integer; Y: Integer); override;
    function ValidateEntry(const ACol, ARow: Integer; const OldValue: string;
      var NewValue: string): boolean; override;
    procedure DoPrepareCanvas(aCol,aRow:Integer; aState: TGridDrawState); override;
    { Protected declarations }
  public
     constructor Create (AOwner: TComponent); override;
     procedure   CreateWnd; override;
     destructor  Destroy; override;
     procedure   SalvaDati;
     procedure   AnnullaAggiornamento;
     procedure   Add; //aggiungi nuovo record
     procedure   Cancella; //cancella  record
     function    GetOperazione:Toperazione;
    { Public declarations }
  published
    property  OnBeforeUpdate: TBeforeUpdate read FBeforeUpdate write FBeforeUpdate;
    property  OnBeforeInsert: TBeforeInsert read FBeforeInsert write FBeforeInsert;
    property  OnBeforeDelete: TBeforeDelete read FBeforeDelete write FBeforeDelete;
    property  StatoUpdate:TStatoUpdate read FStatoUpdate write SetStatoUpdate default [StInsert,StEdit,StDelete];

    { Published declarations }
  end;

procedure Register;
implementation



{ TwtSGSqlUpdate }

constructor TwtSGSqlUpdate.Create(AOwner: TComponent);
Var FpopUp: TPopupMenu;
    FInsert,FDelete: TMenuItem;
begin
  inherited Create (AOwner);
  FIBsqlPost:=  TUIBQuery.Create(self);            //TIBQuery.Create(Self);
  Options:= Options + [goEditing,goTabs,goDrawFocusSelected];
  Foperazione:= OpBrowse;
  StatoUpdate := StatoUpdate + [StInsert,StEdit,StDelete];
  FixedCols:= 0;
  RowCount := 2;
  FIndexRiga:= 1;
  FListSql:= TStringList.Create();
  // Create PopUp
  FPopUp 		:= TPopupMenu.Create(self);
  FInsert 	        := TMenuItem.Create( FPopUp );
  FInsert.Caption 	:= 'Inserisci Record';
  FInsert.OnClick       :=@InsertPopMenu;
  FDelete 	        :=  TMenuItem.Create( FPopUp );
  FDelete.Caption 	:= 'Cancella Record';
  FDelete.OnClick       :=@DeletePopMenu;
  FpopUp.Items.Add(FInsert);
  FpopUp.Items.Add(FDelete);
  PopupMenu := FpopUp;
end;

procedure TwtSGSqlUpdate.CreateWnd;
begin
  inherited CreateWnd;
  FIBsqlPost.DataBase:= Database;
  FIBsqlPost.Transaction:= Transaction;
end;

destructor TwtSGSqlUpdate.Destroy;
begin
  FIBsqlPost.Free;
  inherited Destroy;
end;



procedure TwtSGSqlUpdate.Add;
begin
 if (StInsert in StatoUpdate) then
  begin
   Foperazione := OpInsert;
   RowCount:= RowCount + 1;
   Row:= RowCount - 1;
   Cells[ColCount-1,RowCount-1] := 'I';
   col:= 0;
  end;
end;


procedure TwtSGSqlUpdate.IntestaGrid;
begin
  Columns.Clear;
  inherited IntestaGrid;
  Columns.Add;
  Columns[ColCount-1].Title.Caption:= 'CHECK';
  Columns[ColCount-1].Visible:= False;
end;


procedure TwtSGSqlUpdate.SalvaDati;
Var xcol,riga,x:integer;

begin
  if (Foperazione <> OpBrowse) then
   begin
     FListSql.Clear;
     for riga:= 1 to RowCount-1 do
       begin
         if Cells[ColCount-1, riga] = 'M' then  //se l'ultima cella contiene il caratte M
          UpDateDB(riga)
         else if Cells[ColCount-1, riga] = 'I' then  //se l'ultima cella contiene il caratte I
          InsertDB(riga)
         else if Cells[ColCount-1, riga] = 'C' then  //se l'ultima cella contiene il caratte C
           CancellaDB(riga);
       end;
   end;
   //ciclo la lista delle istruzioni sql create
//   FIBsqlPost.QuickScript:= True;
   for x:= 0 to FListSql.Count-1 do
     begin
       FIBsqlPost.SQL.text:= FListSql[x];
       FIBsqlPost.Open();
       FIBsqlPost.Close(etmCommit);
     end;
  // FIBsqlPost.ExecSQL;
//   FIBsqlPost.Close(etmCommit);
//   FIBsqlPost.QuickScript:= False;
   Foperazione:=OpBrowse;
   Active:=False;
   Active:=True;
end;

procedure TwtSGSqlUpdate.AnnullaAggiornamento;
begin
  Active:=False;
  Active:=True;
  Foperazione:=OpBrowse;
end;

procedure TwtSGSqlUpdate.UpDateDB(riga:Integer);
Var st,FieldsValue,Fwhere:string;
    xcol:integer;
begin
 Fwhere := '';
 FieldsValue:='';
 // controllo se ci sono dati  modificati
 for xcol:= 0 to ColCount -2 do //passo tutte le collone eccetto l'ultima che contiene il CHECk e creo sql
   begin
     if Columns[xcol].Visible then //se la colonna è visibile
      begin
        if FieldsValue <> '' then FieldsValue:= FieldsValue + ',';
        FieldsValue:= FieldsValue + Ffields.Items[xcol].Field + ' = ' + '''' + CheckValueDB(Cells[xcol,riga],Ffields.Items[xcol].Tipo) + '''';
      end;
   end;
  if (FieldsValue <> '') then
    begin
      st:= 'Update ' + FindTable(Sql.Text) +  ' set '  +  FieldsValue;
      DoBeforeUpdate(fwhere,riga);
      if Fwhere = '' then                 // se il campo where è vuoto vuol dire che non è stato modificato dall'evento OndDtaEntry
        st:= st + ' where ' +  Ffields.WhereToString // quindi come condizione where inserisco tutti i campi con i relativi valori
      else
        st := st +  ' where ' +  Fwhere;
    end;
    FListSql.Add(st);
 end;


procedure TwtSGSqlUpdate.InsertDB(riga:Integer);
Var st,campi,valori,valore:string;
    xcol:integer;
    checkValori:boolean;
begin
   DoBeforeInsert(Self,Ffields);
   st:= 'Insert into ' + FindTable(Sql.Text) + ' ' ;
   campi:= ''; valori:= '';checkValori:=False;
   for xcol:= 0 to ColCount -2 do //passo tutte le collone eccetto l'ultima che contiene il CHECk e creo sql
     begin
       if Columns[xcol].Visible then //se la colonna è visibile
        begin
          if campi <> '' then campi:= campi + ',';
            campi:= campi + Ffields.Items[xcol].Field;
          valore:= CheckValueDB(Cells[xcol,riga],Ffields.Items[xcol].Tipo);
          if valori <> '' then valori := valori + ',';
            valori:= valori +  '''' + valore + '''';
          if valore <> '' then checkValori:= True; //controllo se almeno un campo ha un valore
        end;
     end;
    if checkValori then
     begin
       st:= st + '(' + campi +  ') values (' + valori + ')';
       FListSql.Add(st);
     end;
end;

procedure TwtSGSqlUpdate.CancellaDB(riga: Integer);
Var st,Fwhere:string;
begin
  st:= 'Delete From ' + FindTable(Sql.Text) + ' where ';
  DoBeforeDelete(self,fwhere,riga);
  if Fwhere = '' then                 // se il campo where è vuoto vuol dire che non è stato modificato dall'evento OndDtaEntry
    st:= st +  Ffields.WhereToString // quindi come condizione where inserisco tutti i campi con i relativi valori
  else
   st := st + Fwhere;
  FListSql.Add(st);
end;


procedure TwtSGSqlUpdate.Cancella;
begin
  if (StDelete in StatoUpdate)then
   begin
     Foperazione:=OpDelete;
     if (Cells[ColCount-1,Row] = '') then
       Cells[ColCount-1,Row] := 'C'
     else
       Cells[ColCount-1,Row] := '';
     Refresh;
   end;
end;

function TwtSGSqlUpdate.GetOperazione: Toperazione;
begin
  Result:= Foperazione;
end;


procedure TwtSGSqlUpdate.DeletePopMenu(Sender: TObject);
begin
  Cancella;
end;


procedure TwtSGSqlUpdate.InsertPopMenu(Sender: TObject);
begin
  Add;
end;

procedure TwtSGSqlUpdate.DoBeforeUpdate(var where: string; var aRow:integer);
begin
  if Assigned(FBeforeUpdate) then
    FBeforeUpdate(Self,Where,aRow);
end;

procedure TwtSGSqlUpdate.DoBeforeDelete(Sender: Tobject; var where: string; var aRow:integer);
begin
 if Assigned(FBeforeDelete) then
    FBeforeDelete(Self,Where,aRow);
end;

procedure TwtSGSqlUpdate.DoBeforeInsert(Sender: Tobject;
  Ffield: TwtListField);
begin
  if Assigned(FBeforeInsert) then
    FBeforeInsert(Self,Ffield);
end;


procedure TwtSGSqlUpdate.SetStatoUpdate(const Value: TStatoUpdate);
begin
  FStatoUpdate := Value;
  // s'e' stata abilitato inserimento abilito sul popmenu Inserisci
  if (csFreeNotification in ComponentState) then
   begin
    //abilita o disabilita il popmenu in base ai permessi dati al stringgrid
    self.PopupMenu.Items[0].Enabled := (stInsert in  FStatoUpdate);
    self.PopupMenu.Items[1].Enabled := (stDelete in  FStatoUpdate);
   end;
end;



procedure TwtSGSqlUpdate.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X: Integer; Y: Integer);
begin
  inherited;
  if (Foperazione = OpInsert) and (EmptyRow(RowCount - 1,0,ColCount-2)) and (Row <> RowCount - 1) then
   begin
     DeleteRow(RowCount - 1);
     Foperazione:= OpBrowse;
   end;
end;


function TwtSGSqlUpdate.ValidateEntry(const ACol, ARow: Integer;
  const OldValue: string; var NewValue: string): boolean;
begin
  Result:=inherited ValidateEntry(ACol, ARow, OldValue, NewValue);
  if (OldValue <> NewValue) and (Cells[ColCount-1,ARow] = '') then
    begin
       Foperazione := OpEdit;
       Cells[ColCount-1,ARow] := 'M'
    end;
end;

procedure TwtSGSqlUpdate.DoPrepareCanvas(aCol, aRow: Integer;
  aState: TGridDrawState);
begin
  inherited DoPrepareCanvas(aCol, aRow, aState);
  if (Cells[ColCount-1,aRow] = 'M') then
        Canvas.Brush.Color := clMoneyGreen // this would highlight also column or row headers
  else if (Cells[ColCount-1,aRow] = 'I') then
        Canvas.Brush.Color := TColor($D1FCF3) // this would highlight also column or row headers
  else if (Cells[ColCount-1,aRow] = 'C') then
        Canvas.Brush.Color := clRed; // this would highlight also column or row headers

end;


procedure Register;
begin
  RegisterComponents('Trita', [TwtSGSqlUpdate]);
end;

end.
