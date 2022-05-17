unit WTStringGridSql;

interface

uses
  {$IFDEF MSWINDOWS} Windows,Variants, {$ENDIF} SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, UIB,LSystemTrita,WTComboBoxSql,WTCheckBox,umEdit,StdCtrls,UIBlib,
  WTEditComp,WTComboBox,LCLIntf,LCLType,LResources,WDateEdit,wtList;


type
  TattribCell = record
   align: TAlignment;
   Value: string;
   Name: string;
   color: Tcolor;
  end;
  // definisce un puntatore a metodo per l'evento onFound
  TFoundEvent = procedure(Sender: TObject; Found:Boolean) of object;

  { TwtStringGridSql }


  TwtStringGridSql = class(TStringGrid)
  private
    FActive: Boolean;
    FAutosizeCol: Boolean;
    Fsql: TStrings;
    FfieldsExcluded: TStrings;
    FContatore: Boolean;
    FHeaderColumn: string;
    FWidthCols: array of integer;
    FShowHeader: Boolean;
    FShowNull: Boolean;
    FColOrder: Boolean;
    FDecimalColumn: string;
    fEventFound: TFoundEvent;
    procedure SetActive(const Value: Boolean);

    procedure CaricaGrid;
    procedure SetContatore(const Value: Boolean);
    procedure SetFieldsExcluded(AValue: TStrings);
    procedure SqlChange(Sender : TObject);
    procedure SetSql(const Value: Tstrings);
    function  GetDatabase: TUIBDataBase;
    function  GetTransaction: TUIBTransaction;
    procedure SetDatabase(const Value: TUIBDataBase);
    procedure SetTransaction(const Value: TUIBTransaction);
    procedure SetHeaderColumn(const Value: string);
    function  CheckField(StrSql,field:string):string;
    procedure SetDecimalColumn(const Value: string);
    { Private declarations }
  protected
    FIBsql: TUIBQuery; //   TIBQuery;
    procedure IntestaGrid;virtual;
    procedure DrawCell(ACol: Integer; ARow: Integer; ARect: TRect;
      AState: TGridDrawState); override;
   { Protected declarations }
//    procedure  ClearRow(ARow: Integer); //Pulisce e cancella una riga
  public
    CellAttrib:TattribCell;
    Ffields:TwtListField;  // conterra il nome e il tipo del campo del record
    Found: Boolean; // viene posto a true quando la ricerca ha avuto successo
    constructor Create (AOwner: TComponent); override;
    procedure   CreateWnd; override;
    destructor  Destroy; override;
//    procedure   DeleteRow(ARow: Longint); override;
//    procedure   ClearGrid; dynamic;
    function    EmptyRow(PosRow:integer = 0;daCol:integer = 0; aCol:integer = 0):Boolean;  // Controlla se la riga è vuota
    procedure   RowToEdit(Controllo:TComponent);overload;    //I valori della riga vengono inseriti nei componenti edit del panel
    procedure   EditToRow(Controllo:TComponent; OperazioneSql:ToperazioneSQL);overload;//Inserisce i valori dei campi edit contenuti nella Form nella riga
    function    ValueColName(nome:string;PosRow:integer = 0):String;  // restituisce il valore della cella cercata in base al nome
    function    PosCol(nome:string):Integer; // restituisce il numero della colonna in base al nome
    { Public declarations }
  published
    property Database: TUIBDataBase read GetDatabase write SetDatabase;
    property Transaction: TUIBTransaction read GetTransaction write SetTransaction;
    property Active:Boolean read FActive write SetActive default  False;
    property Contatore: Boolean Read FContatore Write SetContatore;
    property ColOrder: Boolean Read FColOrder Write FColOrder default True ;

    property Sql:TStrings Read Fsql write Setsql;
    property FieldsExcluded:TStrings Read FfieldsExcluded write SetFieldsExcluded;
    property HeaderColumn: string Read FHeaderColumn write SetHeaderColumn; // Nasconde le colonne non desiderate
    property DecimalColumn:string Read FDecimalColumn write SetDecimalColumn; // mette i decimali nella colonna specificata
    property ShowNull: Boolean Read FShowNull Write FShowNull default True; // Mostra nella cella Null quando il campo è tale
    property AutoSizeCol: Boolean Read FAutosizeCol Write FAutosizeCol default True; // stabilisce automaticamente la grandezza della colonna
    property OnFound: TFoundEvent read fEventFound write fEventFound;
    property ShowHeader: Boolean Read FShowHeader Write FShowHeader default True; //visualizza o no la prima riga
    { Published declarations }
  end;

 procedure Register;

implementation



{ TwtStringGridSql }

constructor TwtStringGridSql.Create(AOwner: TComponent);
begin
  inherited Create (AOwner);
  DefaultRowHeight:= 18;
  Fsql   := TStringList.Create;
  FfieldsExcluded:= TStringList.Create;

  TStringList(Fsql).OnChange :=@SqlChange;
  FIBsql := TUIBQuery.Create(Self);
  Found:= False;
  FShowNull:= True;
  FColOrder := True;
  FShowHeader:= True;
  FixedCols:= 0;
  FAutosizeCol:= True;
  Ffields:= TwtListField.Create;

//  Contatore:= False;
end;

procedure TwtStringGridSql.CreateWnd;
begin
  inherited CreateWnd;
  Clean;
  RowCount:=2;
end;

destructor TwtStringGridSql.Destroy;
begin
  FIBsql.Free;
  Fsql.Free;
  Ffields.Free;
  FfieldsExcluded.Free;
  inherited Destroy;
end;

procedure TwtStringGridSql.IntestaGrid;
Var x,y,TotFields:integer;
begin
 if not Active then FIBsql.Open;
 TotFields:= FIBsql.Fields.FieldCount;
 if (TotFields > 0) then
  begin
   //Columns.Clear;
   RowCount:=2;
   FixedRows:=1;
   //se non devo visualizzare la riga di intestazione
   if not FShowHeader then
     RowHeights[0] := 0;
   // azzero l'array che contiene i campi
   Ffields.clear;
   if (Columns.Count = 0) then // se non sono state create colonne dall'utente
     begin
       for x:= 0 to  TotFields - 1 do
        begin
         //addizione la colonna
         Columns.Add;
         Columns[x].Title.Alignment:= taCenter;
         Columns[x].Title.Caption:= FIBsql.Fields.AliasName[x];
         Columns[x].MaxSize:= FIBsql.Fields.SQLLen[x];

         // inserisco i dati nella riga di confronto
         if FfieldsExcluded.IndexOf(FIBsql.Fields.AliasName[x]) = -1 then // se il nome del campo non è presente nella lista del tstrings fieldsExcluded assegna ffield.enable a True
           Ffields.add(FIBsql.Fields.AliasName[x],'',FIBsql.Fields.FieldType[x],FIBsql.Fields.SQLLen[x],x,True)
         else
            Ffields.add(FIBsql.Fields.AliasName[x],'',FIBsql.Fields.FieldType[x],FIBsql.Fields.SQLLen[x],x,False);

         // controllo se la riga deve essere visualizzata
         if FoundStr(FIBsql.Fields.AliasName[x],HeaderColumn)  then // se il nome della colonna
           Columns[x].Visible:= False;
        end;
      //  if FAutosizeCol then
           AutoSizeColumns;
     end
     else //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>Quando sono state create le colonne dall'utente
       begin
         for y:= 0 to Columns.Count-1 do
           begin
             Ffields.add(UpperCase(Columns[y].Title.Caption),'',uftUnKnown,0,-1,False);  //nuovo campo virtuale
             for x:= 0 to  TotFields - 1 do
               begin
                 if FIBsql.Fields.AliasName[x] = UpperCase(Columns[y].Title.Caption) then    // se c'è corrispondenza tra campo e il nome colonna modifico i dati dal campo virtuale
                   begin
                     Ffields.Items[Ffields.Count-1].Value:='';
                     Ffields.Items[Ffields.Count-1].tipo:= FIBsql.Fields.FieldType[x];
                     Ffields.Items[Ffields.Count-1].size:= FIBsql.Fields.SQLLen[x];
                     Ffields.Items[Ffields.Count-1].indexField:= x;
                     if FfieldsExcluded.IndexOf(FIBsql.Fields.AliasName[x]) = -1 then // se il nome del campo non è presente nella lista del tstrings fieldsExcluded assegna ffield.enable a True
                       Ffields.Items[Ffields.Count-1].Enable:= True
                     else
                       Ffields.Items[Ffields.Count-1].Enable:= False;
                     Break;
                   end;
               end;
           end;
       end;
  end;
end;

procedure TwtStringGridSql.CaricaGrid;
Var
x,y,TotFields:integer;
st:string;
begin
  TotFields:= FIBsql.Fields.FieldCount;
  Row:= 2;
  while not FIBsql.Eof do
   begin
     for x:= 0 to Ffields.Count - 1 do
       begin
         if Ffields.Items[x].indexField > -1 then  //se indexField è maggiore di -1 significa che esiste il campo nella tabella
           begin
              y:= Ffields.Items[x].indexField; //la y rappresenta la posizione del campo nella tabella
              st:= FIBsql.Fields.AsString[y]; //st contiene il valore del campo
              if (FIBsql.Fields.IsNull[y]) and (FShowNull) then
                st:='<null>'
              else if FoundStr(FIBsql.Fields.AliasName[y],FDecimalColumn) then // se nel campo FDecimalColumn è contenuto il nome gli assegno i decimali
                begin
                   st:=  InsDecimal(st);
                   Columns[x].Alignment:= taRightJustify;    //se il campo è di tipo decimale lo allineo a destra
                end;
              Cells[x+FixedCols,Row] := st;
           end;
       end;
     FIBsql.Next;
     if not FIBsql.Eof then
       begin
         RowCount:= RowCount + 1;
         Row:= RowCount;
       end;
   end;
   if (AutoSizeCol) then  AutoSizeColumns;
    Row:= 1;
end;



procedure TwtStringGridSql.SetActive(const Value: Boolean);
begin
  if Value then
  begin
   Found := False;
   if SQL.Text <> '' then
    begin
     //controllo se il campo da visualizzare è presente nell' istruzione sql
     FIBsql.Close;
     //se esistzone dei parametri esegue una ricerca con parametri
     if FIBsql.Params.FieldCount > 0 then FIBsql.Params.AsString[0]:= Text;
     // trova la posizione del campo da visualizzare
     FIBsql.Open;
     IntestaGrid;
     // se sono statitrovati dei records
     if FIBsql.Fields.RecordCount > 0 then
      begin
        Found:= True;
        CaricaGrid;
        FActive := True;
      end
     else
      begin
       FActive := False;
       Found:= False;
      end;
      // eseguo l'evento onfound da attivare dopo la ricerca dei dati
      if Assigned(fEventFound) then
       fEventFound(Self,Found);
    end;
  end
  else
   begin
     FActive := False;
     Clean;
     RowCount:=2;
   end;

 Col:= 0 // porto il cursore alla colonna 1
end;

procedure TwtStringGridSql.SetContatore(const Value: Boolean);
begin
{  FContatore := Value;
  Active:= False;
  if value then
   FixedCols:= 1
  else
   FixedCols:= 0;
  IntestaGrid;}
end;

procedure TwtStringGridSql.SetFieldsExcluded(AValue: TStrings);
Var x:integer;
begin
 for x:= 0 to AValue.Count -1 do
   AValue.Strings[x]:= UpperCase(AValue.Strings[x]);
 FfieldsExcluded.Assign(AValue);
end;


procedure TwtStringGridSql.SqlChange(Sender: TObject);

begin
  FIBsql.SQL.Assign(Fsql);
end;


procedure TwtStringGridSql.SetSql(const Value: Tstrings);
begin
  Fsql.Assign(Value);
end;

function TwtStringGridSql.GetDatabase: TUIBDataBase;
begin
 Result:= FIBsql.DataBase;
end;

function TwtStringGridSql.GetTransaction: TUIBTransaction;
begin
 Result:= FIBsql.Transaction;
end;

procedure TwtStringGridSql.SetDatabase(const Value: TUIBDataBase);
begin
 FIBsql.DataBase:= Value;
end;

procedure TwtStringGridSql.SetTransaction(const Value: TUIBTransaction);
begin
 FIBsql.Transaction := Value;
end;

procedure TwtStringGridSql.SetHeaderColumn(const Value: string);
begin
  FHeaderColumn := UpperCase(Value);
end;


// Contralla l'struzione sql se i campi sono modificati con l'istruzione AS
function TwtStringGridSql.CheckField(StrSql, field: string): string;
Var PosField:integer;
    NewField:string;
    FieldTemp:string;
  // funzione che ricerca il campo precedente
  function PrecField:string;
  Var x:integer;
   begin
     for x:= PosField - 1 downto 0 do // vado a ritroso finchè non trovo un carattere
      begin
       if StrSql[x] <> ' ' then
        begin
         PosField := x;
         Break;
        end;
      end;
     NewField:= ''; // azzero il campo per inserire quello nuovo
     for x:= PosField  downto 0 do // una volta trovato l'inizio del campo vado a ritroso
      begin                        // finchè non trovo uno spazio o la virgola
       if (StrSql[x] = ' ') or (StrSql[x] = ',') then
        begin
         PosField := x;
         Break;
        end
       else
         Newfield:= StrSql[x] + Newfield
      end;
     result:= NewField;
    end;
begin
 field:= UpperCase(field); // trasformo in maiuscolo sia il campo che l'istruzione sql
 StrSql:= UpperCase(StrSql);
 NewField:='';
 StrSql:= Copy(StrSql,7,Pos('FROM',StrSql) - 7); // Prendo la stringa che va dal Select al From
 PosField:= Pos(field + ' ',StrSql); // controllo se il nome è seguito da uno spazio
 if PosField = 0 then // se non è seguito da uno spazio
   PosField:= Pos(field + ',',StrSql);// controllo il nome s'è seguito da una virgola
 FieldTemp:= PrecField;
 if FieldTemp = 'AS' then
   Result:= PrecField // se il campo precedente è AS, prende la stringa precedente ad AS
 else if Pos('.',FieldTemp) > 0 then
   Result:= FieldTemp + field // se il campo precedente contiene un punto vuol dire ch'è l'alias della tabella
 else
  Result:= field;
end;


procedure TwtStringGridSql.DrawCell(ACol: Integer; ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
//Var r: TRect;
begin
//  CellAttrib.align:= taLeftJustify;
//  if ARow > 0 then // se la riga è maggiore di 0 assegno il valora della cella
//    CellAttrib.Value:= Cells[Acol,ARow]
//  else
//    CellAttrib.Value:='';

//  CellAttrib.Name:=  Cells[Acol,0];
//  CellAttrib.color:= clBlack;
  inherited DrawCell(ACol, ARow, ARect, AState);
//if ARow > 0 then
// begin
//  if Cells[Acol,ARow] = '<null>' then
//     CellAttrib.color := clBlue;
  // assegno valori della cella al field FCellAttrib
//  if (CellAttrib.align <> taLeftJustify) or (CellAttrib.color <> clBlack) then
//   begin
 //    Canvas.Font.Color:= CellAttrib.color;
//     r := ARect;
//     r.Top := r.Top + 2;
//     r.Bottom := r.Bottom - 2;
//     r.left := r.left + 2;
//     r.Right := r.Right - 2;
 //    FillRect(Canvas.Handle, ARect, Canvas.Brush.Handle);
//     if CellAttrib.align =  taRightJustify then
//       DrawText(Canvas.Handle, PChar(CellAttrib.Value), -1, r, DT_RIGHT)
//     else if CellAttrib.align =  taCenter then
//       DrawText(Canvas.Handle, PChar(CellAttrib.Value), -1, r, DT_CENTER)
//     else
//       DrawText(Canvas.Handle, PChar(CellAttrib.Value), -1, r, DT_LEFT);
//   end;
// end;
end;

// inserisce i valori della riga nei componenti controllando solo quelli del Panel
procedure TwtStringGridSql.RowToEdit(Controllo: TComponent);
Var NrCol,NrIndexCB:integer;
    Titolo:string;
    TempControllo: TComponent;
begin
  for NrCol := 0 to ColCount - 1 do
   begin
     titolo:= Columns[NrCol].Title.Caption;
     TempControllo:= Controllo.FindComponent(titolo);
     if TempControllo <> nil then
       begin
         // se il componente è TWTComboBoxSql
       if TempControllo.ClassName = 'TWTComboBoxSql'  then
         begin
          TWTComboBoxSql(TempControllo).ValueLookField:= Cells[NrCol,Row]  ;
          TWTComboBoxSql(TempControllo).Text := Cells[PosCol(TWTComboBoxSql(TempControllo).LookDisplay),Row];
         end
       // se il componente è TWTCheckBox
       else if TempControllo.ClassName = 'TWTCheckBox'  then
         begin
           if Cells[NrCol,Row] = 'T'   then
              TWTCheckBox(TempControllo).Checked := true
           else
             TWTCheckBox(TempControllo).Checked := False
         end
       // se il componente è TWTComboBox
       else if TempControllo.ClassName = 'TWTComboBox' then
         begin
          NrIndexCB:= StrToInt(Cells[NrCol,Row]);
          TWTComboBox(TempControllo).ItemIndex:= NrIndexCB;
         end
      //se il componente e del tipo TWDateEtit
       else if (TempControllo.ClassName = 'TWDateEdit')  then
         begin
           if Cells[NrCol,Row] <> '' then
             TWDateEdit(TempControllo).Date := StrToDate( copy(Cells[NrCol,Row],1,2) + '/' + copy(Cells[NrCol,Row],4,2) + '/' + copy(Cells[NrCol,Row],7,4));
         end
       //s'è differente dai componenti precedenti controllo il nome del componente
       else
         TCustomEdit(TempControllo).Text := Cells[NrCol,Row];
     end;
   end;
end;


// dati presi nella form
procedure TwtStringGridSql.EditToRow(Controllo: TComponent;
  OperazioneSql: ToperazioneSQL);
Var NrCol,NrIndexCB:integer;
    Titolo:string;
    TempControllo:TComponent;
begin
 case OperazioneSql of
  dsCancel:
    begin
      DeleteRow(Row);
      exit;
    end;
  dsInsert:
    begin
    if Cells[0,0] = '' then Active:= True; // Se la tabella non è stata aperta la apro
      if (RowCount > 1) and not(EmptyRow)  then
        begin
          RowCount:= RowCount + 1;
          Row:= RowCount - 1;
        end;
    end;
 end;
 for NrCol := 0 to ColCount - 1 do
   begin
     titolo:= Columns[NrCol].Title.Caption;
     TempControllo:= Controllo.FindComponent(titolo);
     if TempControllo <> nil then
       begin
         // se il componente è TWTComboBoxSql
       if TempControllo.ClassName = 'TWTComboBoxSql'  then
         begin
           Cells[NrCol,Row] := TWTComboBoxSql(TempControllo).ValueLookField;
           Cells[PosCol(TWTComboBoxSql(TempControllo).LookDisplay),Row]:= TWTComboBoxSql(TempControllo).Text ;
         end
       // se il componente è TWTCheckBox
       else if TempControllo.ClassName = 'TWTCheckBox'  then
         begin
           if TWTCheckBox(TempControllo).Checked then
             Cells[NrCol,Row] := 'T'
           else
             Cells[NrCol,Row] := 'F'
         end
       // se il componente è TWTComboBox
       else if TempControllo.ClassName = 'TWTComboBox' then
         begin
           NrIndexCB:= TWTComboBox(TempControllo).ItemIndex;
           Cells[NrCol,Row] :=  TWTComboBox(TempControllo).Items[NrIndexCB]
         end
      //se il componente e del tipo TWDateEtit
       else if (TempControllo.ClassName = 'TWDateEdit')  then
         begin
           if TWDateEdit(TempControllo).Text[1] = ' ' then
             Cells[NrCol,Row] :=''
           else
             Cells[NrCol,Row] := DateToStr(TWDateEdit(TempControllo).Date);//FormatDateTime(DefaultFormatSettings.ShortDateFormat,TWDateEdit(TempControllo).Date);
         end
       //s'è differente dai componenti precedenti controllo il nome del componente
       else if UpperCase(TempControllo.Name) = Titolo  then
             Cells[NrCol,Row] := TCustomEdit(TempControllo).Text;
     end;
   end;
end;


// cerco il numero della colonna in base al nome
function TwtStringGridSql.PosCol(nome: string): Integer;
Var NrCol:Integer;
begin
   nome:= UpperCase(nome);
   // cerco il nome nella riga di intestazione
   result := -1;
   for NrCol := 0 to ColCount - 1 do
     begin
      if  Columns[NrCol].Title.Caption  = nome then
        begin
         Result :=  NrCol;
         break;
        end;
     end;
end;


// restituisco il valore della cella in base al nome e alla riga data
function TwtStringGridSql.ValueColName(nome: string ;PosRow:integer): String;
Var NrCol:integer;
begin
  if PosRow = 0 then PosRow := Row; // se il parametro PosRow è uguale a zero assegno valore riga corrente
   result:= '';
   NrCol:= PosCol(nome);
   if NrCol > -1 then
      result :=  Cells[NrCol,PosRow];
end;


// Controlla se la riga è vuota
function TwtStringGridSql.EmptyRow(PosRow:integer;daCol:integer = 0; aCol:integer = 0):Boolean;
Var NrCol:Integer;
begin
   if PosRow = 0 then PosRow := Row; // se il parametro PosRow è uguale a zero assegno valore riga corrente
   if aCol = 0 then aCol:= ColCount - 1;
   Result := True;
   for NrCol := daCol to aCol do
     begin
      if  Cells[NrCol,PosRow] <> '' then
        begin
         Result := False ;
         break;
        end;
     end;
end;

// Cancella una riga
//procedure TwtStringGridSql.DeleteRow(ARow: Longint);
//begin
// ClearRow(ARow);  //  pulisco la rigo e successivamnete la cancello
// if RowCount > 2 then inherited;
// if ARow < RowCount then // dopo aver cancellato mi posiziono sulla
//   Row:= ARow;            // riga successiva
// Col:= 0; // mi posiziono sulla prima colonna
//end;

//Pulisce la riga corrente
//procedure TwtStringGridSql.ClearRow(ARow: Integer);
//Var NrCol:Integer;
//begin
// for NrCol := 0 to ColCount - 1 do
//     Cells[NrCol,ARow] := ''
//end;

procedure TwtStringGridSql.SetDecimalColumn(const Value: string);
begin
  FDecimalColumn := UpperCase(Value);
end;

procedure Register;
begin
  RegisterComponents('Trita', [TwtStringGridSql]);
end;


end.
