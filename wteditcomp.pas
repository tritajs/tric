unit wtEditComp;

{$mode objfpc}{$H+}

interface

uses
  LCLType,LCLIntf,lresources,LCLProc,Classes, SysUtils, LSystemTrita, uibdataset,
  StdCtrls,Graphics, Controls,Dialogs,WDateEdit;

type
  TEditCopy = record // record per copiare il valore dei campi in memoria
    ClassName:ShortString;
    index:    integer;
    Field:    string;    // valore del campo  nel componente 'TWTComboBoxSql'
    value:    string;
  end;

  Tnomi =    record
     id:     string;    // Nome del Componente
     display:string;   // valore da visualizzare  nel componente 'TWTComboBoxSql'
     field:  string;
  end;

  TEditField = record
    name:      Tnomi;
    index:     integer;
    value:     string;
    size:      integer;
//    Tipo:   TUIBFieldType;
    ClassName: ShortString;
    TypeFind:  string;
    TabOrder:  integer; // inserisce il numero del tab  che ci permettera di mettere in ordine i campi in base al tab
    Attrib:    TAttrib; //AtInsert, AtUpdate,AtSay,AtClear,AtMake,AtEnable,AtFind,AtPaste,AtProcedure
  end;

  { TwtEditComp }

  TwtEditComp = class(TComponent)
  private
    FItemsComponent: Tstrings;
    EditCopy:        array of TEditCopy;
    procedure        CreateObjFromCont;
    procedure        SetItemsComponent(const Value: Tstrings); //crea oggetti presi dai control specificati
    procedure        ItemsChange(sender: TObject);
    { Private declarations }
  protected
    procedure AddComp;
    { Protected declarations }
  public
    EditCount:   Integer;
    EditComp:    array of TEditField;
    operazione:  ToperazioneSQL;
    constructor  Create(AOwner: TComponent);override;
    destructor   Destroy; override;
    procedure    EnableEdit (active: Boolean);
    procedure    ReadOnlyEdit (active: Boolean);
    procedure    SayDati(const Query: TUIBDataSet);
    procedure    Set_TypeFind(const Field: Array of string);
    procedure    Clear_Edit;
    procedure    CopyEditValue;
    procedure    PasteEditValue;
    function     Update_Sql(tabella:string;  where: string): string;
    function     Find_Sql(tabella: string; CampiValori,CampiWhere, CampiJoin: array of string; CheckFiltro:Boolean = False; Indice:string = ''):string;
    function     Insert_Sql(tabella: string; CampiValori: array of string):string;
    function     Procedure_Sql(NomeProcedura:string;UlterioriValori:array of string):string;  // Crea i valori da lanciare nella store procedura
    function     Indexof(field:string):integer;
    procedure    ShowControl;
    procedure    Refresh; // aggiorna i dati in memoria con quelli presenti nei campi edit;
    //    property  Escludi:string  read Fescludi write SetEscludi;
    { Public declarations }
  published
    property ItemsComponent: Tstrings read FItemsComponent write SetItemsComponent;
    { Published declarations }
  end;

 procedure Register;
implementation
 uses WTComboBoxSql,WTCheckBox,WTMemo,umEdit,WTComboBox;

{ TwtEditComp }


constructor TwtEditComp.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  operazione := dsBrowse;
  FItemsComponent := TStringList.Create;
//  TStringList(FItemsComponent).OnChange := ItemsChange;
  AddComp;
end;


destructor TwtEditComp.Destroy;
begin
  FItemsComponent.Free;
  inherited;
end;

procedure TwtEditComp.CreateObjFromCont;
var  i,x: integer;
     WinControl:TWinControl;

Function FindWinControl(st:string):TWinControl;
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
//>>>>>>>>>>>>>>>>>>>>
begin
 EditCount:= 0;
 for x:= 0 to ItemsComponent.Count -1 do
  begin
   WinControl:=  FindWinControl(ItemsComponent.Strings[X]);
   if WinControl <> Nil (*NullDockSite*) then
    begin
     for i:= 0 to WinControl.ControlCount - 1 do
      begin
       if (WinControl.Controls[i] is TCustomEdit) or (WinControl.Controls[i] is TComboBox) or
          (WinControl.Controls[i] is TCheckBox)or(WinControl.Controls[i] is TWTComboBoxSql) or
          (WinControl.Controls[i] is TMemo) or (WinControl.Controls[i] is TWDateEdit) then
        begin
         Inc(EditCount);
         SetLength(EditComp, EditCount);
         EditComp[EditCount - 1].ClassName:=     WinControl.Controls[i].ClassName;
         EditComp[EditCount - 1].index:=         WinControl.Controls[i].ComponentIndex;
         EditComp[EditCount - 1].name.id:=       UpperCase(WinControl.Controls[i].Name);
         EditComp[EditCount - 1].name.display:=  UpperCase(WinControl.Controls[i].Name);
         EditComp[EditCount - 1].name.field:=    UpperCase(WinControl.Controls[i].Name);
         EditComp[EditCount - 1].TypeFind:= '=';
          // Creazione degli attributi per i vari campi
          //
         if EditComp[EditCount - 1].ClassName = 'TWTComboBoxSql' then
           begin
             EditComp[EditCount - 1].name.display :=
                UpperCase(TWTComboBoxSql(WinControl.Controls[i]).LookDisplay);
             EditComp[EditCount - 1].Attrib :=  TWTComboBoxSql(WinControl.Controls[i]).attrib;
             EditComp[EditCount - 1].TabOrder:= TWTComboBoxSql(WinControl.Controls[i]).TabOrder;
           end;
         //
         if Pos(EditComp[EditCount - 1].ClassName,
                 'TumEdit;TumDataEdit;TumNumberEdit;TumValidEdit;TumTimeEdit') > 0  then
           begin
               EditComp[EditCount - 1].Attrib := TumEdit(WinControl.Controls[i]).attrib;
               if Pos(EditComp[EditCount - 1].ClassName, 'TumEdit;TumValidEdit') > 0  then
                  EditComp[EditCount - 1].TypeFind:= TumEdit(WinControl.Controls[i]).TypeFind;
               EditComp[EditCount - 1].TabOrder:= TumEdit(WinControl.Controls[i]).TabOrder;
           end;
         //
         if EditComp[EditCount - 1].ClassName = 'TWTMemo' then
           Begin
             EditComp[EditCount - 1].Attrib := TWTMemo(WinControl.Controls[i]).attrib;
             EditComp[EditCount - 1].TypeFind:= TWTMemo(WinControl.Controls[i]).TypeFind;
             EditComp[EditCount - 1].TabOrder:= TWTMemo(WinControl.Controls[i]).TabOrder;
           end;
         //
         if EditComp[EditCount - 1].ClassName = 'TWTCheckBox' then
           begin
             EditComp[EditCount - 1].Attrib :=  TWTCheckBox(WinControl.Controls[i]).attrib;
             EditComp[EditCount - 1].TabOrder:= TWTCheckBox(WinControl.Controls[i]).TabOrder;
           end;
         //
         if EditComp[EditCount - 1].ClassName = 'TWTComboBox' then
           begin
             EditComp[EditCount - 1].Attrib :=  TWTComboBox(WinControl.Controls[i]).attrib;
             EditComp[EditCount - 1].TabOrder:= TWTComboBox(WinControl.Controls[i]).TabOrder;
           end;
         //
         if EditComp[EditCount - 1].ClassName = 'TWDateEdit' then
           begin
             EditComp[EditCount - 1].Attrib :=  TWDateEdit(WinControl.Controls[i]).attrib;
             EditComp[EditCount - 1].TabOrder:= TWDateEdit(WinControl.Controls[i]).TabOrder;
           end;
        end;
      end;
    end
   else
    ShowMessage('controllo non presente nella Form!');
  end;
end;

procedure TwtEditComp.AddComp;
var  I:integer;
begin
  EditCount:= 0;
  for i:= 0 to Owner.ComponentCount - 1 do
   begin
    if (Owner.Components[i] is TCustomEdit) or (Owner.Components[i] is TComboBox)
        or (Owner.Components[i] is TCheckBox) or(Owner.Components[i] is TWTComboBoxSql)
        or (Owner.Components[i] is TMemo) or (Owner.Components[i] is TWDateEdit) then
     begin
      Inc(EditCount);
      SetLength(EditComp, EditCount);
      EditComp[EditCount - 1].ClassName:=     Owner.Components[i].ClassName;
      EditComp[EditCount - 1].index:=         Owner.Components[i].ComponentIndex;
      EditComp[EditCount - 1].name.id:=       UpperCase(Owner.Components[i].Name);
      EditComp[EditCount - 1].name.display:=  UpperCase(Owner.Components[i].Name);
      EditComp[EditCount - 1].name.field:=    UpperCase(Owner.Components[i].Name);
      EditComp[EditCount - 1].TypeFind:= '=';
      // Creazione degli attributi per i vari campi
      //
      if EditComp[EditCount - 1].ClassName = 'TWTComboBoxSql' then
        begin
          EditComp[EditCount - 1].name.display :=
             UpperCase(TWTComboBoxSql(Owner.Components[i]).LookDisplay);
          EditComp[EditCount - 1].Attrib :=  TWTComboBoxSql(Owner.Components[i]).attrib;
          EditComp[EditCount - 1].TabOrder:= TWTComboBoxSql(Owner.Components[i]).TabOrder;
        end;
      //
      if Pos(EditComp[EditCount - 1].ClassName,
              'TumEdit;TumDataEdit;TumNumberEdit;TumValidEdit;TumTimeEdit') > 0  then
        begin
            EditComp[EditCount - 1].Attrib := TumEdit(Owner.Components[i]).attrib;
            if Pos(EditComp[EditCount - 1].ClassName, 'TumEdit;TumValidEdit') > 0  then
               EditComp[EditCount - 1].TypeFind:= TumEdit(Owner.Components[i]).TypeFind;
            EditComp[EditCount - 1].TabOrder := TumEdit(Owner.Components[i]).TabOrder;
        end;
     //
      if EditComp[EditCount - 1].ClassName = 'TWTMemo' then
       Begin
         EditComp[EditCount - 1].Attrib := TWTMemo(Owner.Components[i]).attrib;
         EditComp[EditCount - 1].TypeFind:= TWTMemo(Owner.Components[i]).TypeFind;
         EditComp[EditCount - 1].TabOrder := TWTMemo(Owner.Components[i]).TabOrder;
       end;
    //
      if EditComp[EditCount - 1].ClassName = 'TWTCheckBox' then
        begin
          EditComp[EditCount - 1].Attrib :=  TWTCheckBox(Owner.Components[i]).attrib;
          EditComp[EditCount - 1].TabOrder:= TWTCheckBox(Owner.Components[i]).TabOrder;
        end;
   //
      if EditComp[EditCount - 1].ClassName = 'TWTComboBox' then
        begin
          EditComp[EditCount - 1].Attrib :=  TWTComboBox(Owner.Components[i]).attrib;
          EditComp[EditCount - 1].TabOrder:= TWTComboBox(Owner.Components[i]).TabOrder;
        end;
  //
      if EditComp[EditCount - 1].ClassName = 'TWDateEdit' then
         begin
           EditComp[EditCount - 1].Attrib :=  TWDateEdit(Owner.Components[i]).attrib;
           EditComp[EditCount - 1].TabOrder:= TWDateEdit(Owner.Components[i]).TabOrder;
        end;
     end;
   end;
end;


procedure TwtEditComp.Clear_Edit;
Var i: integer;
begin
 for i := 0 to EditCount - 1 do
   begin
     // se possiede l'attributo di cancellazione esegue l'operazione
     if AtClear in  EditComp[i].Attrib then
      begin
        EditComp[i].value :=  '';
        if EditComp[i].ClassName = 'TWTCheckBox' then
          TWTCheckBox(Owner.Components[EditComp[i].index]).Checked:= False
        else if EditComp[i].ClassName = 'TWTComboBoxSql' then
         begin
           TWTComboBoxSql(Owner.Components[EditComp[i].index]).ValueLookField:= '';
           TWTComboBoxSql(Owner.Components[EditComp[i].index]).Text:= '';
         end
        else if EditComp[i].ClassName = 'TWTComboBox' then
         begin
           TWTComboBox(Owner.Components[EditComp[i].index]).Text:= '';
           TWTComboBox(Owner.Components[EditComp[i].index]).ItemIndex:= -1;
         end
        else if EditComp[i].ClassName = 'TWDateEdit' then
          TWDateEdit(Owner.Components[EditComp[i].index]).Text:= ''
        else
          TCustomEdit(Owner.Components[EditComp[i].index]).Text:= '';
      end;
   end;
end;


procedure TwtEditComp.EnableEdit(active: Boolean);
Var i: integer;
begin
 with owner do
  begin
    for i:= 0 to EditCount - 1 do
      begin
       if AtEnable in  EditComp[i].Attrib then
         begin
           if EditComp[i].ClassName = 'TWDateEdit' then
             TWDateEdit(Components[EditComp[i].index]).Enabled:= active
          else
             TCustomEdit(Components[EditComp[i].index]).Enabled:= active;
         end;
      end;
  end;
end;


procedure TwtEditComp.ReadOnlyEdit(active: Boolean);
Var i: integer;
begin
  for i:= 0 to EditCount - 1 do
   begin
     if EditComp[i].ClassName = 'TWTMemo' then
       TMemo(Owner.Components[EditComp[i].index]).ReadOnly := active;
     if EditComp[i].ClassName = 'TWTCheckBox' then
       TWTCheckBox(Owner.Components[EditComp[i].index]).ReadOnly:= active;
     if EditComp[i].ClassName = 'TWTComboBoxSql' then
       TWTComboBoxSql(Owner.Components[EditComp[i].index]).Readonly:= active;
     if Pos(EditComp[i].ClassName,'TumEdit;TumDataEdit;TumNumberEdit;TumValidEdit;TumTimeEdit') > 0  then
       TEdit(Owner.Components[EditComp[i].index]).ReadOnly := active;
     if EditComp[i].ClassName = 'TWTComboBox' then
       TWTComboBox(Owner.Components[EditComp[i].index]).ReadOnly := active;
     if EditComp[i].ClassName = 'TWDateEdit' then
       TWDateEdit(Owner.Components[EditComp[i].index]).ReadOnly := active;
   end;
end;

// con il parametro CampiValore passo dei campi non presente nella form
// con il parametro CapiWhere aggingo altre condizioni di filtro
// con il parametro CampiJoin collego dei campi presenti in altre tabelle
// se la variabile CheckFiltro è posta a True anche se non esiste nessun filtro, attivo la ricerca totale dei dati
function TwtEditComp.Find_Sql(tabella: string; CampiValori,CampiWhere,CampiJoin: array of string; CheckFiltro:Boolean;Indice:string): string;
Var st,st1:string;
    i,max: integer;
    campi:string;
    ValueField: string;
    ricerca:string;
    join: array of string;
    field1,field2:string;
    StrWhere:string; //contiene le condizioni where date come argomento
begin
   // inserisce aggiuntivi campi non presenti negli edit
 if High(CampiValori) > -1 then
  begin
   I:= 0;
   while  I <=  High(CampiValori) do
    begin
      if CampiValori[I] <> '' then
        campi:= campi + AnsiUpperCase(CampiValori[I]) + ',';
      Inc(I);
    end;
  end;
   st:= 'Select ';
   ricerca:= ' Where ';
   // crea i campi da visualizzare
   for i := 0 to EditCount - 1 do
   begin
     // controlla se il campo può essere ricercato
     if AtFind in  EditComp[i].attrib then
      begin
       if EditComp[i].ClassName = 'TWTComboBoxSql' then   // collego le tabelle dei campi
        begin
          with TWTComboBoxSql(Owner.Components[EditComp[i].index]) do
           begin
            st:= st + tabella + '.' + EditComp[i].name.field + ',';
            st:= st + tableCBS + '.' + LookDisplay + ',';
            field1:= tabella + '.' + EditComp[i].name.field;
            field2:= tableCBS + '.' + LookField;
            //aumento di un elemento l'array join
            max:= High(join) + 2;
          //  if max = -1 then max := 1 else max := max + 1;
            SetLength(join, max);
            join[max - 1] := ' left join ' + tableCBS + ' on  ( ' +  field1  + ' = ' +  field2 + ') ';
           end;
        end
       else
        st:= st + tabella + '.' + EditComp[i].name.field + ',';
       // s'è sono state passate altre condizioni join le inserisco
      end;
   end;
   st:= st + campi;
   //levo l'ultima virgola
   st:= copy(st,1,length(st)-1);
   // la tabella
   st:= st + ' from ' + tabella;
   // compilazione del filtro
   for i:= 0 to EditCount - 1 do
     begin
       ValueField:= '';
       // In Base al tipo di componente seleziono la proprietà;
       if EditComp[i].ClassName = 'TWDateEdit' then
        begin
         ValueField:=  TWDateEdit(Owner.Components[EditComp[i].index]).Text;
         if ValueField = '  -  -    ' then   ValueField := ''; // vuol dire che il campo data è vuoto
        end;
       if EditComp[i].ClassName = 'TumDataEdit' then
        begin
         ValueField:=  TumDataEdit(Owner.Components[EditComp[i].index]).ValueIB;
         if ValueField = '__-__-____' then ValueField := ''; // vuol dire che il campo data è vuoto
        end
       // se il componente è di tipo TimeEdit
       else if EditComp[i].ClassName = 'TumTimeEdit' then
        begin
         ValueField:=  TumTimeEdit(Owner.Components[EditComp[i].index]).Text;
         if ValueField = '00:00' then ValueField := ''; // vuol dire che il campo time è vuoto
        end
       // se il componente è di tipo checkbox
       else if EditComp[i].ClassName = 'TWTCheckBox' then
         begin
           if TWTCheckBox(Owner.Components[EditComp[i].index]).Checked then
              ValueField:= TWTCheckBox(Owner.Components[EditComp[i].index]).ValueChecked;
            //ValueField:= 'T'
         end
       // se il componente è di tipo ComboBox
       else if EditComp[i].ClassName = 'TWTComboBox' then
         begin
           ValueField:= IntToStr(TWTComboBox(Owner.Components[EditComp[i].index]).ItemIndex);
           if ValueField = '0' then ValueField := ''; // se l'indice è 0 vul dire che non è stato selezionato nulla
         end
       // se il componente è di tipo TWTComboBoxSql
       else if EditComp[i].ClassName = 'TWTComboBoxSql' then
          ValueField:=  TWTComboBoxSql(Owner.Components[EditComp[i].index]).ValueLookField
       else
         ValueField:=  TCustomEdit(Owner.Components[EditComp[i].index]).Text;
       // crea le istruzione per l'operatore where
       // se l'operature e null
       if EditComp[i].TypeFind = 'Null' then
        begin
          ricerca:= ricerca + Tabella + '.' + EditComp[i].name.id + '  is null AND ' ;
        end
       else
        begin
         if Trim(ValueField) <> '' then
           begin
            if  AtFind in  EditComp[i].attrib  then
             begin
                CheckFiltro:= True;
                // se il componente e di tipo data edit
                ricerca:= ricerca + Tabella + '.' + EditComp[i].name.id + ' ' + EditComp[i].TypeFind + ' ' ;
                ricerca:= ricerca + '''' + StringReplace(ValueField,'''','''''',[rfReplaceAll]);
                ricerca:= ricerca + ''' AND ' ;
             end;
           end;
        end;
     end;
     // inserisco i join creati
     if High(join) > -1 then
      for i := Low(join) to High(join) do
       st:= st + join[i];
     // inserisco eventuali altri join passati come parametro
     if High(CampiJoin) > -1 then
      for i := Low(CampiJoin) to High(CampiJoin) do
       st:= st + CampiJoin[i];
     // se vi sono campi da ricercare
     if ricerca <> ' Where ' then
       st:= st + ricerca;
     // s'è sono state aggiunte altre condizioni di ricerca, le inserisco
     StrWhere:= '';
     if High(CampiWhere) > -1 then
      begin
        CheckFiltro:= True;
        I:= 0;
        while  I <=  High(CampiWhere) do
         begin
          StrWhere:= StrWhere + CampiWhere[i] + '''' + CampiWhere[i + 1] + ''' AND ';
          I:= I + 2;
         end;
         if ricerca <> ' Where ' then
           st:= st + StrWhere
         else
           st:= st + ' where ' + StrWhere;
      end;
      // controllo l'esistenza di and come fine stringa
      st1 := copy(st,length(st)-4,4);
      if st1 = ' AND' then
         st:=  copy(st,1,length(st)-4);
      //se ci sono campi indice
      if Indice <> '' then
        st:= st + Indice;

   if CheckFiltro then // se questa variabile è false non ricerco nessun dato
    result:= st
   else
    result := '';
end;

function TwtEditComp.Indexof(field: string): integer;
Var i: integer;
begin
field:= UpperCase(field);
result:= -1;
 for i:= 0 to EditCount - 1 do
   begin
     if  EditComp[i].name.id = field then
       begin
         result := i;
         exit;
       end;
   end;
end;

function TwtEditComp.Insert_Sql(tabella: string; CampiValori: array of string): string;
Var st:string;
     i: integer;
campi: string;
valori: string;
ValueField: string;
begin
   campi:= '';valori:= '';
   st:= 'Insert into ' + tabella ;
   // controlla se i parametri "campivalori" sono pari
 if High(CampiValori) > 0 then
  begin
   if (High(CampiValori) + 1)  mod 2 <> 0 then
     begin
      showmessage('Errore Parametri dispari');
      exit;
     end;
   // inserisce aggiuntivi campi non presenti negli edit
   I:= 0;
   while  I <=  High(CampiValori) do
    begin
      campi:= campi + AnsiUpperCase(CampiValori[I]) + ',';
      Inc(I);
      valori:= valori + '''' + AnsiUpperCase(CampiValori[I]) + ''',';
      Inc(I);
    end;
  end;
   // Inserisce i campi che contengono elementi inseriti negli edit box
   for i := 0 to EditCount - 1 do
   begin
    // controlla se il campo ha gli attributi per eseguire l'inserimento
    if  AtInsert in EditComp[i].attrib then
      begin
       //se il componente e di tipo checkbox assegno a valuefield "T"
       if (EditComp[i].ClassName = 'TWTCheckBox') then
        begin
         if (TWTCheckBox(Owner.Components[EditComp[i].index]).Checked) then
            ValueField:=TWTCheckBox(Owner.Components[EditComp[i].index]).ValueChecked
            //ValueField:= 'T'
         else
            ValueField:=TWTCheckBox(Owner.Components[EditComp[i].index]).ValueUnchecked;
           //ValueField:= 'F'
        end
       // se il componente è di tipo ComboBox
       else if EditComp[i].ClassName = 'TWTComboBox' then
         ValueField:= IntToStr(TWTComboBox(Owner.Components[EditComp[i].index]).ItemIndex)
       else if (EditComp[i].ClassName = 'TWTComboBoxSql') then
         ValueField:=  TWTComboBoxSql(Owner.Components[EditComp[i].index]).Text
       else if EditComp[i].ClassName = 'TWDateEdit'  then
        begin
       //   if TWDateEdit(Owner.Components[EditComp[i].index]).
         ValueField:=  TWDateEdit(Owner.Components[EditComp[i].index]).Text;
         if pos(' ',ValueField) > 0 then
            ValueField:= '';
        end
       else
         ValueField:=  TCustomEdit(Owner.Components[EditComp[i].index]).Text;
       ////////
       if ValueField = '__/__/____' then     ValueField := ''; // vuol dire che il campo data è vuoto
       if ValueField = '00:00' then ValueField := '';
       if Trim(ValueField) <> '' then
         begin
           campi:= campi +  EditComp[i].name.field + ',';
           // se il componente e di tipo TWTComboBoxSql
           if EditComp[i].ClassName = 'TWTComboBoxSql'  then
               valori:= valori + '''' +
               TWTComboBoxSql(Owner.Components[EditComp[i].index]).ValueLookField + ''','
           else if EditComp[i].ClassName = 'TWDateEdit'  then
               valori:= valori + '''' +
               FormatDateTime('DD.MM.YYYY',TWDateEdit(Owner.Components[EditComp[i].index]).Date) + ''','
           else if EditComp[i].ClassName = 'TumDataEdit'  then
               valori:= valori + '''' +
                       TumDataEdit(Owner.Components[EditComp[i].index]).ValueIB+ ''','

           else if EditComp[i].ClassName = 'TumTimeEdit'  then
               valori:= valori +
                       TumTimeEdit(Owner.Components[EditComp[i].index]).ValueIB+ ','

           else if EditComp[i].ClassName = 'TumNumberEdit'  then //sostituisco la virgola con il punto
               valori:= valori + '''' +                          //per eventuali numeri con decimali
                    StringReplace(ValueField,',','.',[rfReplaceAll])+''','
           else
               valori:= valori + '''' +
                    StringReplace(ValueField,'''','''''',[rfReplaceAll])+''',';
         end;
       end;
   end;
   //levo le ultime virgole da escludere
   campi:= copy(campi,1,length(campi)-1);
   valori:= copy(valori,1,length(valori)-1);
   st:= st + ' (' + campi + ') ' + 'Values (' + valori +')';
   result := st;
end;



procedure TwtEditComp.SayDati(const Query: TUIBDataSet);
Var i: integer;
    x,lung:integer;
    temp:string;
begin
 for i := 0 to EditCount - 1 do
   begin
    // controlla se il campo ha gli attributi per eseguire la visualizzazione
    if AtSay in  EditComp[i].attrib then
      begin
        for x:= 0 to Query.FieldCount -1 do
        begin
          // se il componente è TWTComboBoxSql
          if EditComp[i].ClassName = 'TWTComboBoxSql'  then
           begin
            if EditComp[i].name.display = Query.Fields[x].DisplayName then
              begin
               EditComp[i].value:= Query.FieldByName(EditComp[i].name.display).AsString   ;
               TWTComboBoxSql(Owner.Components[EditComp[i].index]).Text:= EditComp[i].value;
              end;
            if EditComp[i].name.field = Query.Fields[x].DisplayName  then
               TWTComboBoxSql(Owner.Components[EditComp[i].index]).ValueLookField:=
               Query.FieldByName(EditComp[i].name.field).AsString;
           end
           // se il componente è TWTCheckBox
           else if EditComp[i].ClassName = 'TWTCheckBox'  then
            begin
             if EditComp[i].name.display = Query.Fields[x].DisplayName then
              begin
                temp:= Query.FieldByName(EditComp[i].name.display).AsString;
                if (temp = 'T') or (temp = '1') then
                  TWTCheckBox(Owner.Components[EditComp[i].index]).Checked:= True
                else
                  TWTCheckBox(Owner.Components[EditComp[i].index]).Checked:= False;
                EditComp[i].value:=  temp;
              end;
            end
           // se il componente è tipo TWTDateEdit
           else if EditComp[i].ClassName = 'TWDateEdit' then
           begin
            if EditComp[i].name.display = Query.Fields[x].DisplayName then
             begin
              TWDateEdit(Owner.Components[EditComp[i].index]).Date:= Query.FieldByName(EditComp[i].name.display).AsDateTime;
              EditComp[i].value:= FormatDateTime(DefaultFormatSettings.ShortDateFormat,Query.FieldByName(EditComp[i].name.display).AsDateTime);
             end;
           end
           // se il componente è di tipo ComboBox
           else if EditComp[i].ClassName = 'TWTComboBox' then
            begin
            if EditComp[i].name.display = Query.Fields[x].DisplayName then
             begin
               EditComp[i].value:=  Query.FieldByName(EditComp[i].name.display).AsString;
               if EditComp[i].value <> '' then
                 TWTComboBox(Owner.Components[EditComp[i].index]).ItemIndex:= StrToInt(EditComp[i].value);
             end;
           end
           // se il componente è di tipo TumTimeEdit
           else if EditComp[i].ClassName = 'TumTimeEdit' then
             begin
               // trasformo il numero decimale in una stringa che rappresenta le ore
               temp:= Query.FieldByName(EditComp[i].name.display).AsString;
               lung:= Length(temp);
               case lung of
                  0: EditComp[i].value := '00:00';
                  1: EditComp[i].value := '0' + temp + ':00';
                  2: EditComp[i].value := temp + ':00';
                  3: EditComp[i].value := '0' + copy(temp,1,1) + ':' + copy(temp,3,1) + '0';
                  4: begin // controllo la posizione dellla virgola
                       if pos(',',temp) = 2 then
                          EditComp[i].value := '0' + copy(temp,1,1) + ':' + copy(temp,3,2)
                       else
                          EditComp[i].value := copy(temp,1,2) + ':' + copy(temp,4,1) + '0';
                     end;
                  5: EditComp[i].value := copy(temp,1,2) + ':' + copy(temp,4,2);
               end;
               TCustomEdit(Owner.Components[EditComp[i].index]).Text:= EditComp[i].value;
             end
          //s'è differente dai componenti precedenti
          else
           begin
            if EditComp[i].name.display = Query.Fields[x].DisplayName then
             begin
               EditComp[i].value:=  Query.FieldByName(EditComp[i].name.display).AsString;
               TCustomEdit(Owner.Components[EditComp[i].index]).Text:= EditComp[i].value;
             end;
           end;
        end;
      end;
   end;
end;

procedure TwtEditComp.Set_TypeFind(const Field: Array of string);
Var i:integer;
    x:integer;
begin
 for i := 0 to EditCount - 1 do
   begin
    for x:= 0 to high(Field) do
       if Field[x] = EditComp[i].name.id then
         EditComp[i].TypeFind:= Field[x+1];
   end;
end;



function TwtEditComp.Update_Sql(tabella: string ; where: string): string;
Var st,temp:string;
    i: integer;
    campi: string;
    ValueField: string;
begin
   campi:= '';
   st:= 'Update ' + tabella + ' Set ' ;
   // crea i campi da visualizzare
   for i := 0 to EditCount - 1 do
   begin
    // controlla se il campo ha gli attributi per la modifica
    if AtUpdate in  EditComp[i].attrib then
      begin
        //se il componente e di tipo checkbox assegno a valuefield "T"
        if (EditComp[i].ClassName = 'TWTCheckBox') then
         begin
          if TWTCheckBox(Owner.Components[EditComp[i].index]).Checked  then
             ValueField:=TWTCheckBox(Owner.Components[EditComp[i].index]).ValueChecked
            //ValueField:= 'T'
          else
             ValueField:=TWTCheckBox(Owner.Components[EditComp[i].index]).ValueUnchecked;
            //ValueField:= 'F'
         end
        else if EditComp[i].ClassName = 'TWTComboBox' then
          ValueField:= IntToStr(TWTComboBox(Owner.Components[EditComp[i].index]).ItemIndex)
        else if EditComp[i].ClassName = 'TWTComboBoxSql'  then
         ValueField:= TWTComboBoxSql(Owner.Components[EditComp[i].index]).Text
        else
         ValueField:=  TCustomEdit(Owner.Components[EditComp[i].index]).Text;
  //      if ValueField = '--/--/----' then ValueField := '';
        if EditComp[i].value <> ValueField then
        begin
          campi:= campi +  EditComp[i].name.field + ' = ';
          // se il componente e di tipo TWTComboBoxSql
          if EditComp[i].ClassName = 'TWTComboBoxSql'  then
           begin
            // se il valore da inserire e vuoto
            if TWTComboBoxSql(Owner.Components[EditComp[i].index]).ValueLookField = '' then
              campi := campi + 'null,'
            else
              campi := campi + '''' +
              TWTComboBoxSql(Owner.Components[EditComp[i].index]).ValueLookField + ''','
           end
          else if EditComp[i].ClassName = 'TWDateEdit'  then
            begin
             // se la data è vuota
          //   if TumDataEdit(Owner.Components[EditComp[i].index]).ValueIB = '' then
             if ValueField = '__/__/____' then
               campi:= campi + 'null,'
             else
             campi:= campi + '''' +
             FormatDateTime('DD.MM.YYYY',TWDateEdit(Owner.Components[EditComp[i].index]).Date) + ''','
            end
          else if EditComp[i].ClassName = 'TumTimeEdit'  then
            begin
             // se l'ora è vuota
             if ValueField = '00:00' then
               campi:= campi + 'null,'
             else
               campi:= campi + '''' +
                     TumTimeEdit(Owner.Components[EditComp[i].index]).ValueIB+ ''','
            end
          else if EditComp[i].ClassName = 'TumNumberEdit'  then
            begin
             // se la numero è 0
             if TumNumberEdit(Owner.Components[EditComp[i].index]).Text = '' then
               campi:= campi + '0,'
             else
               begin
                 temp:= TumNumberEdit(Owner.Components[EditComp[i].index]).Text;
                 temp:= StringReplace(temp,',','.',[rfReplaceAll]); // se esiste sostituisco la virgola con il punto
                 campi:= campi +  temp + ','                       // perche firebird accetta il punto come separatore decimale
               end;
            end
          else
             campi:= campi + '''' +
                    StringReplace(ValueField,'''','''''',[rfReplaceAll])+''',';
        end;
      end;
   end;
   //levo le ultime virgole da escludere
   if campi <> '' then
     begin
      campi:= copy(campi,1,length(campi)-1);
      st:= st +  campi + ' where ' + where ;
     end
   else
     st:= '';
   result := st;
end;



procedure TwtEditComp.SetItemsComponent(const Value: Tstrings);
begin
  FItemsComponent.Assign(Value);
end;


procedure TwtEditComp.ItemsChange(sender: TObject);
begin
  if ItemsComponent.Count > 0 then
    CreateObjFromCont
  else
    AddComp;
end;

procedure TwtEditComp.ShowControl;
Var st:string;
     i:integer;
begin
 st:= '';
 for i:= 0 to EditCount - 1 do
   st:= st + EditComp[i].name.id + ' = ' + EditComp[i].value + ' tab ' + IntToStr(EditComp[i].TabOrder) + #13 +#10;
 ShowMessage(st);
end;

procedure TwtEditComp.CopyEditValue;
Var i: integer;
begin
 SetLength(EditCopy,EditCount);
 for i := 0 to EditCount - 1 do
   begin
     EditCopy[i].ClassName:= EditComp[i].ClassName;
     if EditComp[i].ClassName = 'TWTCheckBox' then
       if TWTCheckBox(Owner.Components[EditComp[i].index]).Checked then
         EditCopy[i].Value:= TWTCheckBox(Owner.Components[EditComp[i].index]).ValueChecked
       else
         EditCopy[i].Value:= TWTCheckBox(Owner.Components[EditComp[i].index]).ValueUnchecked
     else if EditComp[i].ClassName = 'TWTComboBoxSql' then
       begin
         EditCopy[i].Field:=   TWTComboBoxSql(Owner.Components[EditComp[i].index]).ValueLookField;
         EditCopy[i].Value:=   TWTComboBoxSql(Owner.Components[EditComp[i].index]).Text;
      end
     else if EditComp[i].ClassName = 'TWTDateEdit' then
      EditCopy[i].Value:= TWDateEdit(Owner.Components[EditComp[i].index]).Text

     else if EditComp[i].ClassName = 'TWTComboBox' then
         EditCopy[i].Value:=   IntToStr(TWTComboBox(Owner.Components[EditComp[i].index]).ItemIndex)
     else
          EditCopy[i].Value:= TCustomEdit(Owner.Components[EditComp[i].index]).Text;
   end;
end;

procedure TwtEditComp.PasteEditValue;
Var i: integer;
begin
 for i := 0 to EditCount - 1 do
   begin
    // se possiede l'attributo d'incollaggio
    if AtPaste in  EditComp[i].Attrib then
     begin
       if EditCopy[i].ClassName = 'TWTCheckBox' then
         if EditCopy[i].value = TWTCheckBox(Owner.Components[EditComp[i].index]).ValueChecked then
           TWTCheckBox(Owner.Components[EditComp[i].index]).Checked := True
         else
           TWTCheckBox(Owner.Components[EditComp[i].index]).Checked := False
       else if EditCopy[i].ClassName = 'TWTComboBoxSql' then
         begin
           TWTComboBoxSql(Owner.Components[EditComp[i].index]).ValueLookField := EditCopy[i].Field ;
           TWTComboBoxSql(Owner.Components[EditComp[i].index]).Text := EditCopy[i].Value;
        end
       else if EditCopy[i].ClassName = 'TumTimeEdit' then
         begin
           TumTimeEdit(Owner.Components[EditComp[i].index]).Text:= EditCopy[i].Value;
           TumTimeEdit(Owner.Components[EditComp[i].index]).ValueIB:= Copy(EditCopy[i].Value,1,2) + '.' +
               Copy(EditCopy[i].Value,4,2);
        end
       else if EditComp[i].ClassName = 'TWTComboBox' then
         TWTComboBox(Owner.Components[EditComp[i].index]).ItemIndex := StrToInt(EditCopy[i].Value)
       else if EditComp[i].ClassName = 'TWTDateEdit' then
         TWDateEdit(Owner.Components[EditComp[i].index]).Text := EditCopy[i].Value
       else
            TCustomEdit(Owner.Components[EditComp[i].index]).Text:= EditCopy[i].Value;
     end;
   end;
end;


procedure TwtEditComp.Refresh;
Var i: integer;
begin
 for i := 0 to EditCount - 1 do
   begin
     if EditComp[i].ClassName = 'TWTCheckBox' then
       if TWTCheckBox(Owner.Components[EditComp[i].index]).Checked then
         EditComp[i].Value:= TWTCheckBox(Owner.Components[EditComp[i].index]).ValueChecked
       else
         EditComp[i].Value:= TWTCheckBox(Owner.Components[EditComp[i].index]).ValueUnchecked
     else if EditComp[i].ClassName = 'TWTComboBoxSql' then
         EditComp[i].Value:=   TWTComboBoxSql(Owner.Components[EditComp[i].index]).Text
     else if EditComp[i].ClassName = 'TWTDateEdit' then
         EditComp[i].Value:=   TWDateEdit(Owner.Components[EditComp[i].index]).Text
     else if EditComp[i].ClassName = 'TWTComboBox' then
         EditComp[i].Value:=   IntToStr(TWTComboBox(Owner.Components[EditComp[i].index]).ItemIndex)
     else
       EditComp[i].Value:= TCustomEdit(Owner.Components[EditComp[i].index]).Text;
   end;
end;

function TwtEditComp.Procedure_Sql(NomeProcedura:string;UlterioriValori:array of string): string;
Var valori,ValueField:string;
    i,PosTab:integer;
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
  function PosizioneTab(pos:integer):integer; // restituisce l'indice del componente in base al numero di taborder
   var x:integer;                            // questo mi serve per mettere in ordine i campi in base all'ordine del tab
   begin
     result:= 0;
     for x := 0 to EditCount - 1 do
      if EditComp[x].TabOrder = pos then
       begin
         Result:= x;
         exit;
       end;
    end;
//>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
begin
   // Inserisce i campi che contengono elementi inseriti negli edit box
  valori:= '';
  for i := 0 to EditCount - 1 do
   begin
    PosTab:= PosizioneTab(i);
    // controlla se il campo ha gli attributi per eseguire l'inserimento
    if  AtProcedure in EditComp[PosTab].attrib then
      begin
       //se il componente e di tipo checkbox assegno a valuefield "T"
       if (EditComp[PosTab].ClassName = 'TWTCheckBox') then
        begin
         if (TWTCheckBox(Owner.Components[EditComp[PosTab].index]).Checked) then
           ValueField:= TWTCheckBox(Owner.Components[EditComp[PosTab].index]).ValueChecked
         else
           ValueField:= TWTCheckBox(Owner.Components[EditComp[PosTab].index]).ValueUnchecked;
        end
       // se il componente è di tipo ComboBox
       else if EditComp[PosTab].ClassName = 'TWTComboBox' then
         ValueField:= IntToStr(TWTComboBox(Owner.Components[EditComp[PosTab].index]).ItemIndex)
       else if (EditComp[PosTab].ClassName = 'TWTComboBoxSql') then
         ValueField:=  TWTComboBoxSql(Owner.Components[EditComp[PosTab].index]).Text
       else
         ValueField:=  TCustomEdit(Owner.Components[EditComp[PosTab].index]).Text;
       if ValueField = '  -  -    ' then ValueField := '';
        if Trim(ValueField) <> '' then
         begin
           // se il componente e di tipo TWTComboBoxSql
           if EditComp[PosTab].ClassName = 'TWTComboBoxSql'  then
               valori:= valori + '''' +
               TWTComboBoxSql(Owner.Components[EditComp[PosTab].index]).ValueLookField + ''','

           else if EditComp[PosTab].ClassName = 'TWDateEdit'  then
               valori:= valori + '''' +
               FormatDateTime('DD.MM.YYYY',TWDateEdit(Owner.Components[EditComp[i].index]).Date) + ''','
           else if EditComp[PosTab].ClassName = 'TumDataEdit'  then
               valori:= valori + '''' +
                       TumDataEdit(Owner.Components[EditComp[PosTab].index]).ValueIB+ ''','

           else if EditComp[PosTab].ClassName = 'TumNumberEdit'  then //sostituisco la virgola con il punto
               valori:= valori + '''' +                          //per eventuali numeri con decimali
                    StringReplace(ValueField,',','.',[rfReplaceAll])+''','
           else
               valori:= valori + '''' +
                    StringReplace(ValueField,'''','''''',[rfReplaceAll])+''',';
         end
         else // se il componente ha un valore vuoto, gli assegno un valore null
          valori:= valori + 'null,'
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
  RegisterComponents('Trita', [TwtEditComp]);
end;

end.

