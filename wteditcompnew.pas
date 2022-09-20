unit wteditcompNew;

{$mode objfpc}{$H+}

interface

uses
  LCLType,LCLIntf,lresources,LCLProc,Classes, SysUtils, LSystemTrita, uibdataset,
  StdCtrls,Graphics, Controls,Dialogs,WDateEdit,uiblib,uib,Menus,DB,wtexpression,Forms;

type

//TBeforeFind =   procedure (Sender: Tobject;var CampiValori,CampiWhere, CampiJoin: string; var CheckFiltro:Boolean = False; var Indice:string = '';Var SelectCustomer:string = '') of object;

  TBeforeFind =   procedure (Sender: Tobject;var CampiValori,CampiWhere, CampiJoin: string; var CheckFiltro:Boolean; var Indice:string; var SelectCustomer:string; var EndOr:string) of object;

  TBeforeUpdate = procedure (Sender: Tobject;var where,CampiValore,Personale: string) of object;
  TBeforeDelete = procedure (Sender: Tobject;var where,Personale:string) of object;
  TBeforeInsert = procedure (Sender: Tobject;var Campi,Valori,Personale:string) of object;
  TStato =        procedure (Sender: Tobject;var Operazione: string) of object;

 const
     ShowStato: array[ TDataSetState] of string = (
 { dsInactive }      'Inattivo',
 { dsBrowse }        'Visualizzazione dati',
 { dsEdit    }       'Modifca',
 { dsInsert   }      'Inserimento',
 { dsSetKey  }       'Setta la Chiave',
 { dsCalcFields}     'Elabora il Campo',
 { dsFilter    }     'Filtro',
 { dsNewValue }      'Nuovo Valore',
 { dsOldValue  }     'Vecchio Valore',
 { dsCurValue }      'Corrente Valore',
 { dsBlockRead }     'Refresh',
 { dsInternalCalc}   'Campo Interno',
 { dsOpening    }    'Apertura',
 {dsRefreshFields}   'Refresh Campo');

 //{ dsRefreshFields } 'dsRefreshFields');

 // contiene il nome delle classi che posso essere utilizzate dal componente
 EnableClassi: array[0..10 ] of string = (
 'TWTComboBox',
 'TWTCheckBox',
 'TWTMemo',
 'TWTComboBoxSql',
 'TumEdit',
 'TumValidEdit',
 'TumNumberEdit',
 'TumDataEdit',
 'TumTimeEdit',
 'TWDateEdit',
 'TWTimage');

 type


  TEditCopy = record // record per copiare il valore dei campi in memoria
    ClassName:ShortString;
    index:    integer;
    Field:    string;    // valore del campo  nel componente 'TWTComboBoxSql'
    value:    string;
  end;


  TEditField = record
    name:      string;
    display:   string;   // valore da visualizzare  nel componente 'TWTComboBoxSql'
    index:     integer;
    value:     string;
    isnull:    boolean; // se il campo contiene un valore nullo
    size:      integer;
    Tipo:      TUIBFieldType;
    ClassName: ShortString;
    TypeFind:  string;
    FieldFiltro:    string; //potrà contere un filtro personalizzato per ogni campo edit
    TabOrder:  integer; // inserisce il numero del tab  che ci permettera di mettere in ordine i campi in base al tab
    Attrib:    TAttrib; //AtInsert, AtUpdate,AtSay,AtClear,AtMake,AtEnable,AtFind,AtPaste,AtProcedure
    Oggetto:   TComponent;
    image:     TMemoryStream; //contiene una eventuale immagine per il componente twtimage
    imageUpdate:Boolean; // viene posta a true quando l'immagine viene modificata
  end;

  { TwtEditCompNew }



  TwtEditCompNew = class(TComponent)
  private
    FBeforeDelete: TBeforeDelete;
    FReturnInsValue: string;
    FSetMaxlength:   Boolean;
    FBeforeFind:     TBeforeFind;
    FBeforeInsert:   TBeforeInsert;
    FBeforeUpdate:   TBeforeUpdate;
    FIBsql:          TUIBQuery;//    esegue le istruzione sql ;
    FIBDataSet:      TUIBDataSet;//  visualizza i dati letti dal database ;
    FItemsComponent: Tstrings;
    EditCopy:        array of TEditCopy;
    FOnContatore:    TNotifyEvent;
    FOnStato:        TStato;
    Ftable:          string;
    FPopupMenu:      TPopupMenu;
    function         FindWinControl(st:string):TWinControl;
    function         GetDataSet: TUIBDataSet;
    procedure        SetDataSet(AValue: TUIBDataSet);
    procedure        SetItemsComponent(AValue: Tstrings);
    procedure SetReturnInsValue(AValue: string);
    procedure        Settable(AValue: string);
    function         WhereToString:string;  // genera un filtro sql  presso dall'array dei campi
    function         GetValueObject(i:integer;classe:string):string; // restituisce il valore degli edit in relazione al tipo di classe
    Procedure        PutValToComponent(Ind:integer;NomeClass,Campo,Valore:string); //Inserisco i dati dentro i vari componenti
    Procedure        InsFieldBlob; // permette di inserire Campi Blob in istruzioni Update ed Insert
    procedure        Aggiorna_TabOrder; // aggiorna il campo Item[x].TabOrder con il TabOrder presente nel programma
    { Private declarations }
  protected
     procedure AddComp(Componente:TComponent);
     procedure AddItem;
     { window proc - called by Windows to handle
        messages passed to our hidden window }
    { Protected declarations }
  public
    filtro:      string;
    FieldCount:  Integer;     //totale dei campi
    Items:       array of TEditField;       // array dei campi
    stato:       TDataSetState;
    Found:       Boolean;  //se la ricerca ha avuto esito positivo riceve un valore True
    contatore:   string; //visualizza i records trovati e quello selezionato es 1/5

    constructor  Create(AOwner: TComponent);override;

    destructor   Destroy; override;
    procedure    EnableEdit (active: Boolean);
    procedure    ReadOnlyEdit (active: Boolean);
    procedure    SayDati;
    procedure    Set_TypeFind(const Field: Array of string);
    procedure    SetMaxlength;  // setta la variabile size di ogni componente in base alla grandezza del campo relativo
    procedure    Clear_Edit;
    procedure    CopyEditValue;
    procedure    PasteEditValue;
    //procedure    DoBeforeFind(var CampiValori,CampiWhere, CampiJoin: string; var CheckFiltro:Boolean = False; var Indice:string = ''; Var SelectCustomer:string = '');

    procedure    DoBeforeFind(var CampiValori,CampiWhere, CampiJoin: string; var CheckFiltro:Boolean; var Indice:string; var SelectCustomer:string; var EndOr:string);


    procedure    DoBeforeInsert(Var Campi,Valori,personale:string);
    procedure    DoBeforeUpdate(Var where,CampiValore,personale: string);
    procedure    DoBeforeDelete(Var where,personale: string);
    procedure    DoContatore;
    procedure    DoStato;
    procedure    Find(esegui:boolean = True);
    procedure    ReadDate; // legge i dati in base al filtro impostato
    procedure    EseguiSelect(st:String); //Esegue la Select Passata come parametro
    procedure    Update;
    procedure    Delete;
    procedure    Insert;
    procedure    Close; // chiude il dataset
    function     Procedure_Sql(NomeProcedura:string;UlterioriValori:array of string):string;  // Crea i valori da lanciare nella store procedura
    function     Indexof(field:string):integer;
    function     FieldValue(Field:string):string;  //restituisce il valore del campo
    function     ProcedureFieldValue(Field:string):string;  //restituisce il valore restituito dalla procedura
    procedure    PutValueField(Field,valore:string); //assegna un valore al campo
    procedure    ShowControl;
    procedure    Next;
    procedure    Prior;
    procedure    Last;
    procedure    First;
    procedure    Refresh; // aggiorna i dati in memoria con quelli presenti nei campi edit;
    procedure    MenuItemClick(Sender: TObject);  //procedura che viene eseguita dal popupmenu
    //    property  Escludi:string  read Fescludi write SetEscludi;
    { Public declarations }
  published
    property  DataSet: TUIBDataSet read GetDataSet write SetDataSet;
    property  Table:string read Ftable write Settable ;
    property  ReturnInsValue:string read FReturnInsValue write SetReturnInsValue;
    property  ItemsComponent: Tstrings read FItemsComponent write SetItemsComponent ;
    property  OnBeforeFind: TBeforeFind read FBeforeFind write FBeforeFind;
    property  OnBeforeInsert: TBeforeInsert read FBeforeInsert write FBeforeInsert;
    property  OnBeforeUpdate: TBeforeUpdate read FBeforeUpdate write FBeforeUpdate;
    property  OnBeforeDelete: TBeforeDelete read FBeforeDelete write FBeforeDelete;
    property  OnContatore:  TNotifyEvent read FOnContatore write FOnContatore;
    property  OnStato: TStato read FOnStato write FOnStato;

    { Published declarations }
  end;

 procedure Register;
implementation
 uses WTComboBoxSql,WTCheckBox,WTMemo,umEdit,WTComboBox,WTimage;

{ TwtEditComp }


constructor TwtEditCompNew.Create(AOwner: TComponent);
Const operatori : array [0..6] of string = ('=','>','<','<>','starting','Containing','libero');
var x:integer;
    MenuItem: array [0..6] of TMenuItem;
begin
  inherited Create(AOwner);
  stato :=                 dsInactive;
  FItemsComponent :=       TStringList.Create;
  FIBDataSet :=            TUIBDataSet.Create(Self);
  FIBsql :=                TUIBQuery.Create(Self);
  Found:=                  False;
  FieldCount:= 0;
  // Create hidden window using WndMethod as window proc
  // creo il popmenu che poi utilizzerò per gestire le condizioni di ricerca
  FPopupMenu :=            TPopupMenu.Create(Self);
  for x := Low(MenuItem) to High(MenuItem) do
  begin
    MenuItem[x] :=         TMenuItem.Create(Self);
    MenuItem[x].Caption:=  operatori[x];
    MenuItem[x].name:=     'MI'+inttostr(x);
    MenuItem[x].OnClick:=  @MenuItemClick;
  end;
  FPopupMenu.Items.Add(MenuItem);
//  TStringList(FItemsComponent).OnChange := @ItemsChange;
  FPopupMenu.AutoPopup:=False;
  FSetMaxlength:= False;
//  DefaultFormatSettings.ShortDateFormat:='DD-MM-YYYY';
end;


destructor TwtEditCompNew.Destroy;
begin
  FItemsComponent.Free;
//  FIBDataSet.Free;
  FIBDataSet:= nil;
  FIBsql.Free;
  FPopupMenu.Free;
  inherited;
end;

function TwtEditCompNew.FindWinControl(st: string): TWinControl;
Var I:integer;
begin
  result:=  Nil;//  Null;// NullDockSite;
  for I := 0 to Owner.ComponentCount - 1 do
    begin
      if UpperCase(Owner.Components[I].Name) = UpperCase(st) then
        if Owner.Components[I] is TWinControl then
          begin
            result:= Owner.Components[I] as TWinControl;
            break;
           end;
     end;
end;


function TwtEditCompNew.GetDataSet: TUIBDataSet;
begin
 Result:= FIBDataSet;
end;


procedure TwtEditCompNew.SetDataSet(AValue: TUIBDataSet);
begin
   FIBDataSet := AValue;
   AddItem; // creo array dei componenti
end;


procedure TwtEditCompNew.SetItemsComponent(AValue: Tstrings);
begin
  FItemsComponent.Assign(AValue);
end;

procedure TwtEditCompNew.SetReturnInsValue(AValue: string);
begin
  if FReturnInsValue=AValue then Exit;
  FReturnInsValue:=AValue;
end;

procedure TwtEditCompNew.Settable(AValue: string);
begin
  if Ftable= AValue then Exit;
  Ftable:=   UpperCase(AValue);
end;


procedure TwtEditCompNew.AddItem;
var  i,x: integer;
     WinControl:TWinControl;

//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
begin

if FieldCount = 0 then
 begin
  if ItemsComponent.Count = 0  then
    begin
      for i:= 0 to Owner.ComponentCount -1  do
         addComp(Owner.Components[i]);
    end
  else
    begin
     for x:= 0 to ItemsComponent.Count -1 do
       begin
        WinControl:=  FindWinControl(ItemsComponent.Strings[x]);
        if WinControl <> Nil (*NullDockSite*) then
         begin
           for i:= 0 to WinControl.ControlCount - 1 do
               addComp(WinControl.Controls[i]);
         end;
      end;
    end;
 end;
end;


procedure TwtEditCompNew.AddComp(Componente:TComponent);
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  function CheckClass(classe:string):boolean; // controlla il nome della classe con l'elenco delle classi che possono essere abilitate
   var x:integer;
  begin
     Result:= False;;
     for x := Low(EnableClassi) to High(EnableClassi) do
       if classe = EnableClassi[x] then
        Result:= True;
   end;
  //>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
begin

  if CheckClass(Componente.ClassName) then  // se la classe è una di quelle giuste la inserisccco
    begin
      Inc(FieldCount);
      SetLength(Items, FieldCount);
      Items[FieldCount - 1].ClassName:=    Componente.ClassName;
      Items[FieldCount - 1].index:=        Componente.ComponentIndex;
      Items[FieldCount - 1].name:=         UpperCase(Componente.Name);
      Items[FieldCount - 1].display:=      UpperCase(Componente.Name);
      Items[FieldCount - 1].TypeFind:= '=';
      Items[FieldCount - 1].FieldFiltro:= '';
      // Creazione degli attributi per i vari campi
      //
      if Items[FieldCount - 1].ClassName = 'TWTComboBoxSql' then
        begin
          Items[FieldCount - 1].display :=
             UpperCase(TWTComboBoxSql(Componente).LookDisplay);
          Items[FieldCount - 1].Attrib :=    TWTComboBoxSql(Componente).attrib;
          Items[FieldCount - 1].TabOrder:=   TWTComboBoxSql(Componente).TabOrder;
           Items[FieldCount - 1].Tipo:= uftInteger;
        end;
      //
      if Pos(Items[FieldCount - 1].ClassName,
              'TumEdit;TumDataEdit;TumNumberEdit;TumValidEdit;TumTimeEdit') > 0  then
        begin
            Items[FieldCount - 1].Attrib := TumEdit(Componente).attrib;
            if Pos(Items[FieldCount - 1].ClassName, 'TumEdit;TumValidEdit') > 0  then
              begin
               Items[FieldCount - 1].TypeFind:= TumEdit(Componente).TypeFind;
                Items[FieldCount - 1].Tipo:= uftVarchar;
              end;

            Items[FieldCount - 1].TabOrder := TumEdit(Componente).TabOrder;
            // assegno il popupmenu con i filtri al componente
            TumEdit(Componente).PopupMenu:= FPopupMenu;
        end;
     //
      if Items[FieldCount - 1].ClassName = 'TWTMemo' then
       Begin
         Items[FieldCount - 1].Attrib := TWTMemo(Componente).attrib;
         Items[FieldCount - 1].TypeFind:= TWTMemo(Componente).TypeFind;
         Items[FieldCount - 1].TabOrder := TWTMemo(Componente).TabOrder;
         // assegno il popupmenu con i filtri al componente
         TWTMemo(Componente).PopupMenu:= FPopupMenu;
          Items[FieldCount - 1].Tipo:= uftVarchar;
       end;
    //
      if Items[FieldCount - 1].ClassName = 'TWTCheckBox' then
        begin
          Items[FieldCount - 1].Attrib :=  TWTCheckBox(Componente).attrib;
          Items[FieldCount - 1].TabOrder:= TWTCheckBox(Componente).TabOrder;
        end;
   //
      if Items[FieldCount - 1].ClassName = 'TWTComboBox' then
        begin
          Items[FieldCount - 1].Attrib :=  TWTComboBox(Componente).attrib;
          Items[FieldCount - 1].TabOrder:= TWTComboBox(Componente).TabOrder;
        end;
  //
      if Items[FieldCount - 1].ClassName = 'TWTimage' then
        begin
          Items[FieldCount - 1].TabOrder:= TWTimage(Componente).TabOrder;
          Items[FieldCount - 1].Attrib :=  TWTimage(Componente).attrib;
          Items[FieldCount - 1].image := TMemoryStream.Create;
          Items[FieldCount - 1].imageUpdate:= False;
        end;
  //
      if Items[FieldCount - 1].ClassName = 'TWDateEdit' then
         begin
           Items[FieldCount - 1].Attrib :=  TWDateEdit(Componente).attrib;
           Items[FieldCount - 1].TabOrder:= TWDateEdit(Componente).TabOrder;
           Items[FieldCount - 1].Tipo:= uftDate;

           // assegno il popupmenu con i filtri al componente
          TWDateEdit(Componente).PopupMenu:= FPopupMenu;
        end;
     end;
end;




function TwtEditCompNew.WhereToString: string;
Var i:integer;
    st:string;
begin
 st:= '';
 for i := 0 to FieldCount -1 do
  begin
    if (AtUpdate in  Items[i].attrib) then
      begin
        if Items[i].isnull then
          st:= st + Items[i].name  + ' is null and '
        else
          st:= st + Items[i].name + '= ''' + CheckValueDB(Items[i].Value,Items[i].Tipo) + ''' and ';
      end;
  end;
  Result := copy(st,0,length(st) - 5); // levo l'ultimo and
 end;


// setta la lunghezza dei componenti testo con la relativa lunghezza del campo del record
procedure TwtEditCompNew.SetMaxlength;
Var i: integer;
    st,TipoDato:string;

begin
st:=      ' SELECT r.RDB$FIELD_NAME AS field_name, ';
st:= st + '   r.RDB$DESCRIPTION AS field_description, ';
st:= st +   '   r.RDB$DEFAULT_VALUE AS field_default_value, ';
st:= st +   '   r.RDB$NULL_FLAG AS field_not_null_constraint,  ';
st:= st +   '   f.RDB$FIELD_LENGTH AS field_length, ';
st:= st +   '   f.RDB$FIELD_PRECISION AS field_precision, ';
st:= st +   '   f.RDB$FIELD_SCALE AS field_scale, ';
st:= st +   '   CASE f.RDB$FIELD_TYPE  ';
st:= st +   '     WHEN 261 THEN ''BLOB''   ';
st:= st +   '     WHEN 14 THEN ''CHAR''     ';
st:= st +   '     WHEN 40 THEN ''CSTRING''  ';
st:= st +   '     WHEN 11 THEN ''D_FLOAT''  ';
st:= st +   '     WHEN 27 THEN ''DOUBLE''   ';
st:= st +   '     WHEN 10 THEN ''FLOAT''    ';
st:= st +   '     WHEN 16 THEN ''INT64''    ';
st:= st +   '     WHEN 8 THEN ''INTEGER''   ';
st:= st +   '     WHEN 9 THEN ''QUAD''      ';
st:= st +   '     WHEN 7 THEN ''SMALLINT''  ';
st:= st +   '     WHEN 12 THEN ''DATE''     ';
st:= st +   '     WHEN 13 THEN ''TIME''     ';
st:= st +   '     WHEN 35 THEN ''TIMESTAMP'' ';
st:= st +   '     WHEN 37 THEN ''VARCHAR''   ';
st:= st +   '     ELSE ''UNKNOWN''  ';
st:= st +   '   END AS field_type,  ';
st:= st +   '   f.RDB$FIELD_SUB_TYPE AS field_subtype, ';
st:= st +   '   coll.RDB$COLLATION_NAME AS field_collation, ';
st:= st +   '   cset.RDB$CHARACTER_SET_NAME AS field_charset   ';
st:= st +   ' FROM RDB$RELATION_FIELDS r  ';
st:= st +   ' LEFT JOIN RDB$FIELDS f ON r.RDB$FIELD_SOURCE = f.RDB$FIELD_NAME ';
st:= st +   ' LEFT JOIN RDB$COLLATIONS coll ON f.RDB$COLLATION_ID = coll.RDB$COLLATION_ID  ';
st:= st +   ' LEFT JOIN RDB$CHARACTER_SETS cset ON f.RDB$CHARACTER_SET_ID = cset.RDB$CHARACTER_SET_ID ';
st:= st +   ' WHERE r.RDB$RELATION_NAME= ''' + Table + ''' ';
st:= st +   'ORDER BY r.RDB$FIELD_POSITION';
 (* TUIBFieldType = (uftUnKnown, uftNumeric, uftChar, uftVarchar, uftCstring, uftSmallint,
    uftInteger, uftQuad, uftFloat, uftDoublePrecision, uftTimestamp, uftBlob, uftBlobId,
    uftDate, uftTime, uftInt64, uftArray {$IFDEF IB7_UP}, uftBoolean{$ENDIF}
    {$IFDEF FB25_UP}, uftNull{$ENDIF}); *)
  if not (Assigned(FIBsql.DataBase) AND Assigned(FIBsql.Transaction)) then
   begin
     if (Assigned(FIBDataSet.Database) AND Assigned(FIBDataSet.Transaction)) then
      begin
        FIBsql.DataBase:=      FIBDataSet.Database;
        FIBsql.Transaction:=   FIBDataSet.Transaction;
      end
     else
      begin
        showmessage(' attenzione non è stato assegnato al dset il Database o il Transaction');
        exit;
      end;
    end;
 filtro:=st;
 FIBsql.SQL.Text:= st;
 FIBsql.Open;
 while not FIBsql.Eof do
  begin
   for i := 0 to FieldCount - 1 do
     begin
       if Items[i].name = Trim(FIBsql.Fields.ByNameAsAnsiString['FIELD_NAME']) then
         begin
          TipoDato:= Trim(FIBsql.Fields.ByNameAsString['FIELD_TYPE']);
           if TipoDato = 'BLOB'      then  Items[i].Tipo:= uftBlobId;
           if TipoDato = 'CHAR'      then  Items[i].Tipo:= uftChar;
           if TipoDato = 'CSTRING'   then  Items[i].Tipo:= uftCstring;
           if TipoDato = 'D_FLOAT'   then  Items[i].Tipo:= uftDoublePrecision;
           if TipoDato = 'DOUBLE'    then  Items[i].Tipo:= uftDoublePrecision;
           if TipoDato = 'FLOAT'     then  Items[i].Tipo:= uftFloat;
           if TipoDato = 'INT64'     then  Items[i].Tipo:= uftInt64;
           if TipoDato = 'INTEGER'   then  Items[i].Tipo:= uftInteger;
           if TipoDato = 'QUAD'      then  Items[i].Tipo:= uftQuad;
           if TipoDato = 'SMALLINT'  then  Items[i].Tipo:= uftSmallint;
           if TipoDato = 'DATE'      then  Items[i].Tipo:= uftDate;
           if TipoDato = 'TIME'      then  Items[i].Tipo:= uftTime;
           if TipoDato = 'TIMESTAMP' then  Items[i].Tipo:= uftTimestamp;
           if TipoDato = 'VARCHAR'   then  Items[i].Tipo:= uftVarchar;
           if TipoDato = 'UNKNOWN'   then  Items[i].Tipo:= uftUnKnown;
           // assegno alla proprieta max dei componenti la grandezza del campo
           Items[i].size:= FIBsql.Fields.ByNameAsInteger['FIELD_LENGTH'];
           if (Pos(Items[i].ClassName,'TumEdit;TumValidEdit') > 0) and (Items[i].Tipo in [uftChar,uftCstring,uftVarchar])  then
              TumEdit(Owner.Components[Items[i].index]).MaxLength:= FIBsql.Fields.ByNameAsInteger['FIELD_LENGTH'];
           if Items[i].ClassName = 'TWTMemo' then
               TWTMemo(Owner.Components[Items[i].index]).MaxLength:= FIBsql.Fields.ByNameAsInteger['FIELD_LENGTH'];
         end;
      end;
    FIBsql.Next;
  end;
 FSetMaxlength:= True;
end;



procedure TwtEditCompNew.Clear_Edit;
Var i: integer;
begin
 for i := 0 to FieldCount - 1 do
   begin
     // se possiede l'attributo di cancellazione esegue l'operazione
    if AtClear in  Items[i].Attrib then
      begin
        Items[i].value :=  '';
        Items[i].isnull:= False;
        Items[i].FieldFiltro:= '';
        TCustomEdit(Owner.Components[Items[i].index]).Hint:='';  //cancello i suggerimenti del filtro
        if Items[i].ClassName = 'TWTCheckBox' then
          TWTCheckBox(Owner.Components[Items[i].index]).Checked:= False
        else if Items[i].ClassName = 'TWTComboBoxSql' then
         begin
           TWTComboBoxSql(Owner.Components[Items[i].index]).ValueLookField:= '';
           TWTComboBoxSql(Owner.Components[Items[i].index]).Text:= '';
         end
        else if Items[i].ClassName = 'TWTComboBox' then
         begin
           TWTComboBox(Owner.Components[Items[i].index]).Text:= '';
           TWTComboBox(Owner.Components[Items[i].index]).ItemIndex:= -1;
         end
        else if Items[i].ClassName = 'TWDateEdit' then
          TWDateEdit(Owner.Components[Items[i].index]).Text:= ''
        else if Items[i].ClassName = 'TWTimage' then
           TWTimage(Owner.Components[Items[i].index]).Fimage.Picture.Clear
        else
          TCustomEdit(Owner.Components[Items[i].index]).Text:= '';
      end;
   end;
end;


procedure TwtEditCompNew.EnableEdit(active: Boolean);
Var i: integer;
begin
//assegno il database al componente quary che effettuera le operazioni d'aggiornamento
 with owner do
  begin
    for i:= 0 to FieldCount - 1 do
      begin
       if AtEnable in  Items[i].Attrib then
         begin
           if Items[i].ClassName = 'TWDateEdit' then
             TWDateEdit(Components[Items[i].index]).Enabled:= active
           else if Items[i].ClassName = 'TWTimage' then
             TWTimage(Components[Items[i].index]).Enabled:= active
           else
             TCustomEdit(Components[Items[i].index]).Enabled:= active;
         end;
      end;
  end;
end;


procedure TwtEditCompNew.ReadOnlyEdit(active: Boolean);
Var attrib:TAttribKind;

procedure elabora;
 Var i: integer;
begin
   for i:= 0 to FieldCount - 1 do
    begin
     if (attrib in  Items[i].attrib) then
       begin
         if Items[i].ClassName = 'TWTMemo' then
           TMemo(Owner.Components[Items[i].index]).ReadOnly := active;
         if Items[i].ClassName = 'TWTCheckBox' then
           TWTCheckBox(Owner.Components[Items[i].index]).ReadOnly:= active;
         if Items[i].ClassName = 'TWTComboBoxSql' then
           TWTComboBoxSql(Owner.Components[Items[i].index]).Readonly:= active;
         if Pos(Items[i].ClassName,'TumEdit;TumDataEdit;TumNumberEdit;TumValidEdit;TumTimeEdit') > 0  then
           TEdit(Owner.Components[Items[i].index]).ReadOnly := active;
         if Items[i].ClassName = 'TWTComboBox' then
           TWTComboBox(Owner.Components[Items[i].index]).ReadOnly := active;
         if Items[i].ClassName = 'TWDateEdit' then
           TWDateEdit(Owner.Components[Items[i].index]).ReadOnly := active;
         if Items[i].ClassName = 'TWTimage' then
           TWTimage(Owner.Components[Items[i].index]).ReadOnly := active;
      end;
   end;
 end;

begin
  if active then    //disabilito tutti gli edit che sono stati creati
    begin
      attrib:=AtMake;
      elabora;
    end
  else
    begin
      case stato of  // in base alla variabile stato abilito solo gli edit che hanno attibuto attivo
        dsEdit:   attrib:=  AtUpdate;
        dsInsert: attrib:=  AtInsert;
        dsFilter: attrib:=  AtFind;
      end;
      elabora;
    end;
end;


function TwtEditCompNew.GetValueObject(i: integer; classe: string): string;
begin
 result:= '';
 // In Base al tipo di componente seleziono la proprietà;
 if Classe = 'TWDateEdit' then
  begin
   result:=  TWDateEdit(Owner.Components[Items[i].index]).Text;
   if Length(Trim(result)) < 6 then   result := '' // vuol dire che il campo data è vuoto
      else result:= Copy(result,1,2) + FormatSettings.DateSeparator + Copy(result,4,2) + FormatSettings.DateSeparator + Copy(result,7,4); //                   DateToStr(TWDateEdit(Owner.Components[Items[i].index]).Date);
  end
 else if Items[i].ClassName = 'TumDataEdit' then
  begin
   result:=  TumDataEdit(Owner.Components[Items[i].index]).ValueIB;
   if result = '__-__-____' then result := ''; // vuol dire che il campo data è vuoto
  end
 // se il componente è di tipo TimeEdit
 else if Items[i].ClassName = 'TumTimeEdit' then
  begin
   result:=  TumTimeEdit(Owner.Components[Items[i].index]).Text;
   if result = '00:00' then result := ''; // vuol dire che il campo time è vuoto
  end
 // se il componente è di tipo checkbox
 else if Items[i].ClassName = 'TWTCheckBox' then
   begin
     if TWTCheckBox(Owner.Components[Items[i].index]).Checked then
       result:= TWTCheckBox(Owner.Components[Items[i].index]).ValueChecked
     else
       if stato <> dsFilter then
        result:= TWTCheckBox(Owner.Components[Items[i].index]).ValueUnchecked;
   end
 // se il componente è di tipo ComboBox
 else if Items[i].ClassName = 'TWTComboBox' then
   begin
     result:= IntToStr(TWTComboBox(Owner.Components[Items[i].index]).ItemIndex);
     if result = '-1' then result := ''; // se l'indice è -1 vul dire che non è stato selezionato nulla
   end
 // se il componente è di tipo TWTComboBoxSql
 else if Items[i].ClassName = 'TWTComboBoxSql' then
    result:=  TWTComboBoxSql(Owner.Components[Items[i].index]).ValueLookField

 // se il componente è di tipo TWTimage
 else if (Items[i].ClassName = 'TWTimage') then
   begin
     if TWTimage(Owner.Components[Items[i].index]).modificato then
       begin
         result:=  'BLOB';
       end;
   end
 else
   begin
      result:= TCustomEdit(Owner.Components[Items[i].index]).Text;
    //  result:= StringReplace(result,'''','''''',[rfReplaceAll]); //aggiusto eventuali apostrofi
   end;

end;



// con il parametro CampiValore passo dei campi + il relativo valore non presenti nella form
// con il parametro CapiWhere aggingo altre condizioni di filtro
// con il parametro CampiJoin collego dei campi presenti in altre tabelle
// se la variabile CheckFiltro è posta a True anche se non esiste nessun filtro, attivo la ricerca totale dei dati

procedure TwtEditCompNew.Find(esegui:boolean = True);
Var st,st1:string;
    i,max: integer;
    campi:string;
    ValueField: string;
    ricerca:string;
    join: array of string;
    field1,field2:string;
    CampiValori,CampiWhere, CampiJoin: string;
    CheckFiltro:Boolean;
    EndOr:string;
    Indice,SelectCustomer:string;
begin
 if not FSetMaxlength then SetMaxlength; //se la variabile FSetMaxLength è falso lancio la funzione SetMaxLength
 campi:= '';
 found:= False;
 contatore:='';
 CheckFiltro:= false;
 SelectCustomer:= '';
 ricerca:= ' Where ';
 CampiValori:= '';
 CampiWhere:= '';
 CampiJoin:='';
 filtro:= '';
 EndOr:= 'AND';
 DoBeforeFind(CampiValori, CampiWhere, CampiJoin, CheckFiltro, Indice, SelectCustomer,EndOr);

 if SelectCustomer = '' then
   begin
     // inserisco i campi aggiuntivi restituiti alla procedure DoBeforeFind
     if CampiValori <> '' then
       campi := campi + AnsiUpperCase(CampiValori);
     st:= 'Select ';
      // crea i campi da visualizzare
     for i := 0 to FieldCount - 1 do
      begin
       if Items[i].ClassName = 'TWTComboBoxSql' then   // collego le tabelle dei campi
         begin
           with TWTComboBoxSql(Owner.Components[Items[i].index]) do
           begin
            st:= st + table + '.' +  self.Items[i].name + ',';
            st:= st + tableCBS + '.' +  LookDisplay + ',';
            field1:=  table + '.'  +  self.Items[i].name;
            field2:=  tableCBS + '.'  +  LookField;
            //aumento di un elemento l'array join
            max:= High(join) + 2;
          //  if max = -1 then max := 1 else max := max + 1;
            SetLength(join, max);
            join[max - 1] := ' left join ' + tableCBS + ' on  ( ' +  field1  + ' = ' +  field2 + ') ';
           end;
        end
        else
          if AtFind in  Items[i].Attrib then
            st:= st + table + '.' + Items[i].name + ',';

        // se sono state passate altre condizioni join le inserisco
      end;
      st:= st + campi;
      //se l'ultimo carattere è una virgola, la levo
      if RightStr(st,1) = ',' then
        st:= copy(st,1,length(st)-1);
      // la table
      st:= st + ' from ' + table;
   end
   else // eseguo la select personalizzata assegnata al parametro selectcustomer
      st:= SelectCustomer;
   // compilazione del filtro
   for i:= 0 to FieldCount - 1 do
     begin
       ValueField:= GetValueObject(i,Items[i].ClassName);
       // crea le istruzione per l'operatore where
       // se l'operature e null
       if Items[i].TypeFind = 'Null' then
         begin
          ricerca:= ricerca + table + '.' + Items[i].name + '  is null AND ' ;
         end
      else
         begin
          if (Trim(ValueField) <> '') or (Items[i].fieldfiltro <> '') then
            begin
             if  AtFind in  Items[i].attrib  then
               begin
                 CheckFiltro:= True;
                 if Items[i].fieldfiltro = '' then
                   begin
                     // unisco il campo + tipo di filtro e valore da ricercare
                     ricerca:= ricerca + table + '.' + Items[i].name + ' ' + Items[i].TypeFind + ' ' ;
                     ricerca:= ricerca + '''' + CheckValueDB(ValueField,Items[i].Tipo) + '''';
                   end
                 else // inserisco in contenuto della ricerca libera sul campo
                   ricerca:= ricerca + Items[i].fieldfiltro;
                ricerca:= ricerca + ' ' + EndOr + ' ' ;
               end;
            end;
         end;
       end;
   // inserisco i join creati
   if High(join) > -1 then
     for i := Low(join) to High(join) do
       st:= st + join[i];
   // inserisco eventuali altri join passati come parametro
   if CampiJoin <> '' then
     st:= st + CampiJoin;
   // se vi sono campi da ricercare
   if ricerca <> ' Where ' then
     st:= st + ricerca;
   // s'è sono state aggiunte altre condizioni di ricerca, le inserisco
   if CampiWhere <> '' then
     begin
        CheckFiltro:= True;
         if ricerca <> ' Where ' then
           st:= st + CampiWhere
         else
           st:= st + ' where ' + CampiWhere;
     end;
     // controllo l'esistenza di and come fine stringa
     st1 := copy(st,length(st)-4,4);
     if st1 = ' AND' then
         st:=  copy(st,1,length(st)-4)
     else
       begin
        // controllo l'esistenza di OR come fine stringa
        st1 := copy(st,length(st)-3,3);
        if st1 = ' OR' then
          st:=  copy(st,1,length(st)-3)
       end;

     //se ci sono campi indice
     if Indice <> '' then
        st:= st + Indice;
   if CheckFiltro then // se questa variabile è false non ricerco nessun dato
    begin
      filtro:= st;
    //  ShowMessage(filtro);
      if esegui then //esegui l'istruzione sql
         ReadDate;
    end;
end;



procedure TwtEditCompNew.ReadDate;

begin
  FIBDataSet.SQL.Text:= filtro;
  FIBDataSet.Close;
  FIBDataSet.Open;
  FIBDataSet.Last;
  if  FIBDataSet.RecordCount > 0 then
    begin
      found:=True;
      FIBDataSet.First;
      SayDati;
      contatore:=  IntToStr(FIBDataSet.RecNo) + '/' + IntToStr(FIBDataSet.RecordCount);
      DoContatore;
 //        if FSetMaxLength then SetMaxlength; // setto la lunghezza dei campi
    end
  else
    ShowMessage('Attenzione Ricerca Fallita: ' );
end;


procedure TwtEditCompNew.EseguiSelect(st: String);
begin
  filtro:= st;
  ReadDate;
end;



function TwtEditCompNew.Indexof(field: string): integer;
Var i: integer;
begin
field:= UpperCase(field);
result:= -1;
 for i:= 0 to FieldCount - 1 do
   begin
     if  Items[i].name = field then
       begin
         result := i;
         exit;
       end;
   end;
end;

function TwtEditCompNew.FieldValue(Field: string): string;
Var pos:integer;
begin
  pos := Indexof(Field);
  if  pos > -1 then
    Result := Items[pos].value
  else
    Result := '';
end;

//restituisce il valore di ritorno di una procedura
function TwtEditCompNew.ProcedureFieldValue(Field: string): string;
Var x:integer;
begin
 result:= '';
 for x:= 0 to FIBsql.Fields.FieldCount -1  do
   begin
     if FIBsql.Fields.AliasName[x] = Field then
       begin
         result:= FIBsql.Fields.AsString[x];
         exit;
       end;
   end;
end;

procedure TwtEditCompNew.PutValueField(Field, valore: string);
Var pos:integer;
begin
 pos := Indexof(Field);
 if  pos > -1 then
    Items[pos].value := valore;
end;


procedure TwtEditCompNew.Insert;
Var st:string;
     i: integer;
campi: string;
valori: string;
personale:string;
ValueField: string;
TempComp:TComponent;
begin
 if not FSetMaxlength then SetMaxlength; //se la variabile FSetMaxLength è falso lancio la funzione SetMaxLength
  campi:= '';valori:= '';personale:= '';
  DoBeforeInsert(Campi,Valori,personale);
  if personale = '' then
    begin
      if campi <> ''  then
        begin
          campi := campi + ','; //se la variabile non è vuota aggiungo la virgola finale
           valori:= valori + ',';
        end;
      st:= 'Insert into ' + table ;
      // Inserisce i campi che contengono elementi inseriti negli edit box
      for i := 0 to FieldCount - 1 do
        begin
          // controlla se il campo ha gli attributi per eseguire l'inserimento
          if  AtInsert in Items[i].attrib then
            begin
              ValueField:= GetValueObject(i,Items[i].ClassName);
              if Trim(ValueField) <> '' then
                begin
                  campi:= campi +  Items[i].name + ',';
                  valori:= valori + '''' +  CheckValueDB(ValueField,Items[i].Tipo) + ''','
               end;
            end;
        end;
      //levo le ultime virgole da escludere
      campi:= copy(campi,1,length(campi)-1);
      valori:= copy(valori,1,length(valori)-1);
      st:= st + ' (' + campi + ') ' + 'Values (' + valori +')';
      if FReturnInsValue <> '' then
        st:= st + ' RETURNING ' + FReturnInsValue;
      filtro:= st;
  //    showmessage(st);
      if (campi <> '') then
        begin
         FIBsql.SQL.Text:= filtro;
         FIBsql.Execute;
         //s'è stato inserito il nome di un campo da restituire il suo valore dopo l'inserimento
         if FReturnInsValue <> '' then
           begin
              ValueField:= FIBsql.Fields.ByNameAsString[FReturnInsValue];
              TempComp:= Owner.FindComponent(FReturnInsValue);
              if(TempComp) <> nil Then
                 TCustomEdit(Owner.FindComponent(FReturnInsValue)).Text:=  ValueField;
           end;
         FIBsql.Close(etmCommitRetaining);
       end;
    end
  else
   begin
     filtro := personale;
     FIBsql.SQL.Text:= filtro;
     FIBsql.Open;
     FIBsql.Close(etmCommitRetaining);
    end;
 end;

procedure TwtEditCompNew.Close;
begin
  FIBDataSet.Close;
end;


procedure TwtEditCompNew.SayDati;
Var i: integer;
    x:integer;
    //Stream :TMemoryStream;
begin
 // cancello i dati contenuti negli edit
 Clear_Edit;
 for i := 0 to FieldCount - 1 do
   begin
     // controlla se il campo ha gli attributi per eseguire la visualizzazione
    if AtSay in  Items[i].attrib then
      begin
       for x:= 0 to FIBDataSet.FieldCount -1 do
         begin
          //se esiste corrispondenza tra il nome del campo e il nome del componente assegno il valore
          if  (FIBDataSet.Fields[x].DisplayName  = Items[i].name) or  (FIBDataSet.Fields[x].DisplayName  = Items[i].display) then
            begin
              if FIBDataSet.Fields[x].IsNull then
                 Items[i].isnull:= True
              else
                begin
                  PutValToComponent(i,Items[i].ClassName,FIBDataSet.Fields[x].DisplayName,FIBDataSet.Fields[x].AsString);
                  Items[i].isnull:= False;
                end;
            end
         end;
      end;
   end;
end;



procedure TwtEditCompNew.PutValToComponent(Ind:integer;NomeClass, Campo, Valore: string);
Var temp:string;
    lung:integer;
begin
 // se il componente è TWTComboBoxSql
 if NomeClass = 'TWTComboBoxSql'  then
  begin
   if Items[Ind].display = Campo then
     begin
       TWTComboBoxSql(Owner.Components[Items[Ind].index]).Text:= valore;
     end;
    if Items[Ind].name = Campo  then
     begin
      Items[Ind].value:= valore;
      TWTComboBoxSql(Owner.Components[Items[Ind].index]).ValueLookField:=  valore;
     end;
  end
  // se il componente è TWTCheckBox
  else if NomeClass = 'TWTCheckBox'  then
   begin
    if Items[Ind].name = campo then
     begin
       temp:= valore;
       if temp = 'T' then
         TWTCheckBox(Owner.Components[Items[Ind].index]).Checked:= True
       else
         TWTCheckBox(Owner.Components[Items[Ind].index]).Checked:= False;
       Items[Ind].value:=  temp;
     end;
   end
  // se il componente è tipo TWTDateEdit
  else if NomeClass = 'TWDateEdit'  then
  begin
   if Items[Ind].name = campo then
    begin
       temp:= copy(valore,1,2) + FormatSettings.DateSeparator + copy(valore,4,2) + FormatSettings.DateSeparator + copy(valore,7,4);
       TWDateEdit(Owner.Components[Items[Ind].index]).Text:=  temp;
       Items[Ind].value:= temp;
    end;
  end
  // se il componente è di tipo ComboBox
  else if NomeClass = 'TWTComboBox' then
   begin
   if Items[Ind].name = campo then
    begin
      Items[Ind].value:=  Trim(valore);
      if Items[Ind].value <> '' then
        TWTComboBox(Owner.Components[Items[Ind].index]).ItemIndex:= StrToInt(valore);
    end;
  end
  // se il componente è di tipo TumTimeEdit
  else if NomeClass = 'TumTimeEdit' then
    begin
      // trasformo il numero decimale in una stringa che rappresenta le ore
      temp:= valore;
      lung:= Length(temp);
      case lung of
         0: Items[Ind].value := '00:00';
         1: Items[Ind].value := '0' + temp + ':00';
         2: Items[Ind].value := temp + ':00';
         3: Items[Ind].value := '0' + copy(temp,1,1) + ':' + copy(temp,3,1) + '0';
         4: begin // controllo la posizione dellla virgola
              if pos(',',temp) = 2 then
                 Items[Ind].value := '0' + copy(temp,1,1) + ':' + copy(temp,3,2)
              else
                 Items[Ind].value := copy(temp,1,2) + ':' + copy(temp,4,1) + '0';
            end;
         5: Items[Ind].value := copy(temp,1,2) + ':' + copy(temp,4,2);
      end;
      TCustomEdit(Owner.Components[Items[Ind].index]).Text:= Items[Ind].value;
    end
  // se il componente è di tipo TWTimage
  else if NomeClass = 'TWTimage' then
   begin
     if Items[Ind].name = campo then
       begin
         FIBDataSet.ReadBlob(campo,Items[Ind].image);
         if Items[Ind].image.Size > 0 then
           TWTimage(Owner.Components[Items[Ind].index]).Fimage.Picture.LoadFromStream(Items[Ind].image)
         else
           Items[Ind].image:= Nil;
       end;
   end
  //s'è differente dai componenti precedenti
 else
  begin
   if Items[Ind].name = campo then
    begin
       Items[Ind].value:=  valore;
       TCustomEdit(Owner.Components[Items[Ind].index]).Text:= valore;
    end;
  end;
end;

procedure TwtEditCompNew.InsFieldBlob;
Var i:integer;
begin
  for i := 0 to FieldCount - 1 do
    begin
      if Items[i].imageUpdate then
        begin
          FIBsql.ParamsSetBlob(Items[i].name,Items[i].image);
          Items[i].imageUpdate:= False;
          Items[i].image.Clear;
       end;
    end;
end;



procedure TwtEditCompNew.Update;
Var st:string;
    i: integer;
    campi,CampiValore,Personale: string;
    ValueField: string;
    where: string;
    OKfoto:boolean; //controlla s'è presete una foto
begin
   if not FSetMaxlength then SetMaxlength; //se la variabile FSetMaxLength è falso lancio la funzione SetMaxLength
   where:= ''; Personale:= '';
   OKfoto:= false;
   CampiValore:= ''; //conterra i campi e i relativi valore passati eventualmente per parametro
   DoBeforeUpdate(where,CampiValore,Personale);
   if personale = '' then
     begin

       if CampiValore <> '' then CampiValore:= CampiValore + ','; //se sono stati passati dei parametri aggiungo una virgola perchè verrà eliminata successivamente
       // se la variabile where è vuota creo in autometico la condizione where
       if where = '' then   where:= WhereToString;
       campi:= '';
       st:= 'Update ' + table + ' Set ' ;
       // crea i campi da visualizzare
       for i := 0 to FieldCount - 1 do
       begin
        // controlla se il campo ha gli attributi per la modifica
        if AtUpdate in  Items[i].attrib then
          begin
            ValueField:= GetValueObject(i,Items[i].ClassName);
           if Items[i].value <> ValueField then
            begin
              campi:= campi +  Items[i].name + ' = ';
              // se il componente e di tipo TWTComboBoxSql
              if Items[i].ClassName = 'TWTComboBoxSql'  then
               begin
                // se il valore da inserire e vuoto
                 if ValueField = '' then
                  campi := campi + 'null,'
                else
                  campi := campi + '''' +  ValueField  + ''','
               end
              else if Items[i].ClassName = 'TWDateEdit'  then
                begin
                 // se la data è vuota
                 if ValueField = '' then
                   campi:= campi + 'null,'
                 else
                   campi:= campi + '''' + DateDB(ValueField)  + ''','
                end
              else if Items[i].ClassName = 'TumTimeEdit'  then
                begin
                 // se l'ora è vuota
                 if ValueField = '00:00' then
                   campi:= campi + 'null,'
                 else
                   campi:= campi + '''' +  ValueField + ''','
                end
              else if (Items[i].ClassName = 'TWTimage')  then
                begin
                  if TWTimage(Owner.Components[Items[I].index]).Fimage.Picture.Bitmap.Empty then //se il campo twtimage è vuoto vuol dire che è stato cancellato
                     campi:= campi + 'null,'
                  else
                    begin
                      campi:= campi + ':' + Items[i].name + ',';
                      Items[i].imageUpdate:= True;
                      Items[i].image.Clear;
                      Items[i].image.LoadFromStream(TWTimage(Owner.Components[Items[I].index]).FStream);
                      TWTimage(Owner.Components[Items[i].index]).modificato:= False;
                      OKfoto:= True;
                    end;
                end
              else if Items[i].ClassName = 'TumNumberEdit'  then
                begin
                 // se il numero è 0
                 if ValueField = '' then
                   campi:= campi + 'null,'
                 else
                     campi:= campi +  StringReplace(ValueField,',','.',[rfReplaceAll]) + ','                       // perche firebird accetta il punto come separatore decimale
                end
              else
                 campi:= campi + '''' +   CheckValueDB(ValueField,Items[i].Tipo) + ''',';
            end;
          end;
       end;
       campi:= campi + CampiValore;
       if campi <> '' then
         begin
          //levo le ultime virgole da escludere
          campi:= copy(campi,1,length(campi)-1);
          st:= st +  campi + ' where ' + where ;
          filtro:= st;
          FIBsql.SQL.Text:= st;
          if OKfoto then // se un campo TWTimage è stato modificato, inseririsco il campo blob nell''istruzione update
            InsFieldBlob;
         end
       else
         st:= '';

      end
      else
      begin
         filtro:= personale;
         FIBsql.SQL.Text:= st;
      end;
      try
     //   ShowMessage(st);
        FIBsql.Execute;
        FIBsql.Close(etmCommitRetaining);
      except
        ShowMessage('Operazione non eseguita');
      end;
end;


procedure TwtEditCompNew.Delete;
Var where,st,personale:string;
begin
   if not FSetMaxlength then SetMaxlength; //se la variabile FSetMaxLength è falso lancio la funzione SetMaxLength
   where:= ''; st:= ''; personale:= '';
   DoBeforeDelete(where, personale);
   if personale = '' then
     begin
       // se la variabile where è vuota creo in autometico la condizione where
       if where = '' then   where:= WhereToString;
       st:= 'delete from ' + table + ' where '  + where;
       filtro:= st;
       FIBsql.SQL.Text:= st;
     end
     else
      begin
       filtro:= personale;
       FIBsql.SQL.Text:= filtro;
      end;
   try
     FIBsql.Execute;
     FIBsql.Close(etmCommitRetaining);
//     FIBsql.Close(etmCommit);
   except
    ShowMessage('Cancellazione non eseguita');
   end;
end;

procedure TwtEditCompNew.Set_TypeFind(const Field: array of string);
Var i:integer;
    x:integer;
begin
 for i := 0 to FieldCount - 1 do
   begin
    for x:= 0 to high(Field) do
       if Field[x] = Items[i].name then
         Items[i].TypeFind:= Field[x+1];
   end;
end;



procedure TwtEditCompNew.ShowControl;
Var st:string;
     i:integer;
FieldTypes: array [TUIBFieldType] of string =
   ('', 'NUMERIC', 'CHAR', 'VARCHAR', 'CSTRING', 'SMALLINT', 'INTEGER', 'QUAD',
    'FLOAT', 'DOUBLE PRECISION', 'TIMESTAMP', 'BLOB', 'BLOBID', 'DATE', 'TIME',
    'BIGINT' , 'ARRAY'{$IFDEF IB7_UP}, 'BOOLEAN' {$ENDIF}
    {$IFDEF FB25_UP}, 'NULL'{$ENDIF});
begin
 if not FSetMaxlength then SetMaxlength; //se la variabile FSetMaxLength è falso lancio la funzione SetMaxLength
 st:= '';
 for i:= 0 to FieldCount - 1 do
  begin
   st:= st + Items[i].name + ' = ' + Items[i].value + ' tab ' + IntToStr(Items[i].TabOrder) + '  size  ' +IntToStr(Items[i].size) + '  tipo  ' + FieldTypes[Items[i].Tipo];
   if Items[i].isnull then
    st:= st + '< null> ' + #13 +#10
   else
    st:= st + #13 +#10
  end;
 ShowMessage(st);
end;

procedure TwtEditCompNew.Next;
begin
 if not FIBDataSet.Eof then
   begin
    FIBDataSet.Next;
    SayDati;
    contatore:=  IntToStr(FIBDataSet.RecNo) + '/' + IntToStr(FIBDataSet.RecordCount);
    DoContatore;
   end;
end;

procedure TwtEditCompNew.Prior;
begin
 if not FIBDataSet.BOF then
   begin
    FIBDataSet.Prior;
    SayDati;
    contatore:=  IntToStr(FIBDataSet.RecNo) + '/' + IntToStr(FIBDataSet.RecordCount);
    DoContatore;
   end;
end;

procedure TwtEditCompNew.Last;
begin
  if not FIBDataSet.EOF then
   begin
     FIBDataSet.Last;
     SayDati;
     contatore:=  IntToStr(FIBDataSet.RecNo) + '/' + IntToStr(FIBDataSet.RecordCount);
     DoContatore;
   end;
end;

procedure TwtEditCompNew.First;
begin
   if not FIBDataSet.BOF then
     begin
       FIBDataSet.First;
       SayDati;
       contatore:=  IntToStr(FIBDataSet.RecNo) + '/' + IntToStr(FIBDataSet.RecordCount);
       DoContatore;
     end;
end;

procedure TwtEditCompNew.CopyEditValue;
Var i: integer;
begin
 SetLength(EditCopy,FieldCount);
 for i := 0 to FieldCount - 1 do
   begin
     EditCopy[i].ClassName:= Items[i].ClassName;
     if Items[i].ClassName = 'TWTCheckBox' then
       if TWTCheckBox(Owner.Components[Items[i].index]).Checked then
         EditCopy[i].Value:= 'T'
       else
         EditCopy[i].Value:= 'F'
     else if Items[i].ClassName = 'TWTComboBoxSql' then
       begin
         EditCopy[i].Field:=   TWTComboBoxSql(Owner.Components[Items[i].index]).ValueLookField;
         EditCopy[i].Value:=   TWTComboBoxSql(Owner.Components[Items[i].index]).Text;
      end
     else if Items[i].ClassName = 'TWTDateEdit' then
      EditCopy[i].Value:= TWDateEdit(Owner.Components[Items[i].index]).Text

     else if Items[i].ClassName = 'TWTComboBox' then
         EditCopy[i].Value:=   IntToStr(TWTComboBox(Owner.Components[Items[i].index]).ItemIndex)
     else
          EditCopy[i].Value:= TCustomEdit(Owner.Components[Items[i].index]).Text;
   end;
end;

procedure TwtEditCompNew.PasteEditValue;
Var i: integer;
begin
 for i := 0 to FieldCount - 1 do
   begin
    // se possiede l'attributo d'incollaggio
    if AtPaste in  Items[i].Attrib then
     begin
       if EditCopy[i].ClassName = 'TWTCheckBox' then
         if EditCopy[i].value = 'T' then
           TWTCheckBox(Owner.Components[Items[i].index]).Checked := True
         else
           TWTCheckBox(Owner.Components[Items[i].index]).Checked := False
       else if EditCopy[i].ClassName = 'TWTComboBoxSql' then
         begin
           TWTComboBoxSql(Owner.Components[Items[i].index]).ValueLookField := EditCopy[i].Field ;
           TWTComboBoxSql(Owner.Components[Items[i].index]).Text := EditCopy[i].Value;
        end
       else if EditCopy[i].ClassName = 'TumTimeEdit' then
         begin
           TumTimeEdit(Owner.Components[Items[i].index]).Text:= EditCopy[i].Value;
           TumTimeEdit(Owner.Components[Items[i].index]).ValueIB:= Copy(EditCopy[i].Value,1,2) + '.' +
               Copy(EditCopy[i].Value,4,2);
        end
       else if Items[i].ClassName = 'TWTComboBox' then
         TWTComboBox(Owner.Components[Items[i].index]).ItemIndex := StrToInt(EditCopy[i].Value)
       else if Items[i].ClassName = 'TWTDateEdit' then
         TWDateEdit(Owner.Components[Items[i].index]).Text := EditCopy[i].Value
       else
            TCustomEdit(Owner.Components[Items[i].index]).Text:= EditCopy[i].Value;
     end;
   end;
end;


procedure TwtEditCompNew.Refresh;
Var i: integer;
begin
 CopyEditValue;
  for i := 0 to FieldCount - 1 do
   begin
     if Items[i].ClassName = 'TWTCheckBox' then
       if TWTCheckBox(Owner.Components[Items[i].index]).Checked then
         Items[i].Value:= 'T'
       else
         Items[i].Value:= 'F'
     else if Items[i].ClassName = 'TWTComboBoxSql' then
          Items[i].value:=   TWTComboBoxSql(Owner.Components[Items[i].index]).ValueLookField
     else if Items[i].ClassName = 'TWDateEdit' then
         Items[i].Value:=   TWDateEdit(Owner.Components[Items[i].index]).Text
     else if Items[i].ClassName = 'TWTComboBox' then
         Items[i].Value:=   IntToStr(TWTComboBox(Owner.Components[Items[i].index]).ItemIndex)
     else
       Items[i].Value:= TCustomEdit(Owner.Components[Items[i].index]).Text;
   end;
end;


procedure TwtEditCompNew.DoBeforeFind(var CampiValori, CampiWhere,
  CampiJoin: string; var CheckFiltro: Boolean; var Indice: string;
  var SelectCustomer: string; var EndOr:string);
begin
  if Assigned(FBeforeFind) then
    begin
      CheckFiltro := False;
      FBeforeFind(self,CampiValori, CampiWhere, CampiJoin, CheckFiltro, Indice, SelectCustomer, EndOr);
    end;
end;

procedure TwtEditCompNew.Aggiorna_TabOrder;
var x:integer;
    a:TWinControl;
begin
  for x := 0 to FieldCount -1 do
  begin
    a:= nil;
    a:= FindWinControl(Items[x].name);
    if Assigned(a) then
      Items[x].TabOrder:= a.TabOrder;
  end
end;

procedure TwtEditCompNew.DoBeforeInsert(var Campi, Valori, personale: string);
begin
  if Assigned(FBeforeInsert) then
    FBeforeInsert(self, Campi, Valori, Personale);
end;

procedure TwtEditCompNew.DoBeforeUpdate(var where,CampiValore,Personale: string);
begin
  if Assigned(FBeforeUpdate) then
    FBeforeUpdate(self,where,CampiValore,Personale);
end;

procedure TwtEditCompNew.DoBeforeDelete(var where, personale: string);
begin
  if Assigned(FBeforeDelete) then
    FBeforeDelete(self,where, personale);
end;

procedure TwtEditCompNew.DoContatore;
begin
  if Assigned(FOnContatore) then
     FOnContatore(self); // se l'evento OnContarore è stato assegnato lo eseguo
end;

procedure TwtEditCompNew.DoStato;
begin
  if stato = dsFilter then
    FPopupMenu.AutoPopup:= True
  else
    FPopupMenu.AutoPopup:=False;
  if Assigned(FOnStato) then
       FOnStato(self,ShowStato[Stato]); // se l'evento OnContarore è stato assegnato lo eseguo
end;



procedure TwtEditCompNew.MenuItemClick(Sender: TObject);
var operatore,field:string;
     i,PosCompFind:integer;
     Fmwtexpression: TFmwtexpression;
begin
 field:='';
 PosCompFind:=0; //posizione nell'array del componenti che ha il focus
 for i:= 0 to Owner.ComponentCount - 1 do
   begin
    if Owner.Components[i] is TCustomEdit then
      begin
        if TCustomEdit(Owner.Components[i]).Focused then
          begin
             field:= TCustomEdit(Owner.Components[i]).Name;
             PosCompFind:= i;
          end;
      end
    else if Owner.Components[i] is TCustomControl then
      begin
        if TCustomControl(Owner.Components[i]).Focused then
          begin
             field:= TCustomControl(Owner.Components[i]).Name;
             PosCompFind:= i;
          end;
      end;
   end;
  // se nessun oggetto edit ha il fuoco esco dalla procedura
  if field = '' then exit;
  Items[Indexof(Field)].FieldFiltro:= '';
  TCustomEdit(Owner.Components[PosCompFind]).ShowHint:= False;
  TCustomEdit(Owner.Components[PosCompFind]).Hint:='';
  operatore:=  TMenuItem(sender).Caption;
  if  operatore  = 'libero' then   //permette di richiamare una form per costruire un esoressione sul campo
    begin
     Fmwtexpression := TFmwtexpression.Create(Application);
     try
      Fmwtexpression.Ecampo.Text:= Table + '.' + Items[Indexof(Field)].display;
      if Fmwtexpression.ShowModal = mrOk then
        Items[Indexof(Field)].fieldfiltro:= Fmwtexpression.CurrentExpression;
        TCustomEdit(Owner.Components[PosCompFind]).ShowHint:= True;
        TCustomEdit(Owner.Components[PosCompFind]).Hint:= Fmwtexpression.CurrentExpression;
     finally
         Fmwtexpression:= Nil;
         Fmwtexpression.Free;
      end;
    end
   else
     begin
       Items[Indexof(Field)].TypeFind:= operatore;
       TCustomEdit(Owner.Components[PosCompFind]).ShowHint:= True;
       TCustomEdit(Owner.Components[PosCompFind]).Hint:= operatore;
     end;

end;

function TwtEditCompNew.Procedure_Sql(NomeProcedura:string;UlterioriValori:array of string): string;
Var valori,ValueField:string;
    i,PosTab:integer;
    flag:integer = 0;
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  function PosizioneTab(pos:integer):integer; // restituisce l'indice del componente in base al numero di taborder
   var x:integer;                            // questo mi serve per mettere in ordine i campi in base all'ordine del tab
   begin
     result:= 0;
     for x := 0 to FieldCount - 1 do
      if Items[x].TabOrder = pos then
       begin
         Result:= x;
         exit;
       end;
    end;
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
begin
  // se flag è 0 aggiorno i TabOrder
 if flag = 0 then
  begin
    Aggiorna_TabOrder;
    flag:= 1;
  end;
  if not FSetMaxlength then SetMaxlength; //se la variabile FSetMaxLength è falso lancio la funzione SetMaxLength
  // Inserisce i valori contenuti negli edit box
  valori:= '';
  for i := 0 to FieldCount - 1 do
   begin
    PosTab:= PosizioneTab(i);
    // controlla se il campo ha gli attributi per eseguire l'inserimento
    if  AtProcedure in Items[PosTab].attrib then
      begin
        ValueField:= GetValueObject(PosTab,Items[PosTab].ClassName);

        if Trim(ValueField) <> '' then
             valori:= valori + '''' +  CheckValueDB(ValueField,Items[PosTab].Tipo) + ''','
        else
             valori:= valori + 'null,';
      end;
   end;
   // inserisce eventuali ulteriori valori
   I:= 0;
   while  I <=  High(UlterioriValori) do
    begin
      if UlterioriValori[i] <> 'null' then
        valori:= valori + '''' + StringReplace(UlterioriValori[i],'''','''''',[rfReplaceAll]) + ''','
      else
        valori:= valori + UlterioriValori[i] + ',';
      Inc(I);
    end;
   // levo l'ultima virgola
   valori:= copy(valori,1,length(valori)-1);
   Result:= 'select * from ' + NomeProcedura + ' (' + valori + ')';
end;


procedure Register;
begin
  RegisterComponents('Trita', [TwtEditCompNew]);
end;




end.

