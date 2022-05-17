unit wtList;

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,UIBlib,LSystemTrita;

type
  TArrayList = array of array of string;

  { TwtList }

  TwtList = class
  private
   Column: integer;
    { Private declarations }
  protected
    { Protected declarations }
  public
    Index: integer;
    List: TArrayList;
    Count: integer;
    constructor Create;
    procedure add(S:array of string);
    function Value(key: string; posKey,posValue: integer): string;
     function ValueKey(key: string): string;
    procedure clear;
    function indexof(st:string;poscol:integer):integer;
    { Public declarations }
  published
    { Published declarations }
  end;

  // TList Field
  TField  =   record
    Field :   string;
    Value:    string;
    display:  string;   // valore da visualizzare  nel componente 'TWTComboBoxSql'
    index:    integer;
    indexField: integer; //contiene l'indice del campo della tabella
    Tipo:       TUIBFieldType;
    size:       integer;
    Enable:     Boolean;  //controlla se deve essere utilizzato

  end;
  TArrayField = array of TField;

  { TwtListField }

  TwtListField = class
    private
     fcount: integer;
     function GetCount: Integer;
    protected
    public
     Items : TArrayField;
     constructor Create;
     procedure add(field,value:string; tipo:TUIBFieldType; size,indexField:integer; Enable:boolean = True);
     procedure clear;
     procedure ClearValues; // pulisce tutti i valori contenuti nei campi value dell'array utile per inserire nuovi valori
     function IndexField(st:string): Integer; // restituisce il record relativo al campo cercato
     function IndexTipo(st:string):TUIBFieldType; // restituisci il tipo di campo
     function FieldToString:string;
     function ValueToString:string;
     function WhereToString:string;
     property Count: Integer read GetCount;
  end;


implementation


{ TwtList }
constructor TwtList.Create;
begin
  Count:= 0;
  Column:= 1;
end;

procedure TwtList.add(S:array of string);
Var i:integer;
begin
 Count:= Count + 1;
 Index:= Count - 1;
 if Column < (High(S) + 1) then // se il numero degli Open Array parameters è
    Column:= High(S) + 1;       // maggio del numero di Column lo inserisco nella
 SetLength(List,Count,Column);// variabile Column
 for I := 0 to High(S) do
   List[Count-1,I]:= S[I];
end;

//   restituisce il valore di una cella della matrice in base alla posizione della colonna
function TwtList.Value(key: string; posKey,posValue: integer): string;
Var pos:integer;
begin
  pos:= indexof(key,posKey);
  if pos > -1 then
     result:= List[pos][posValue]
  else
     result := '';
end;

function TwtList.ValueKey(key: string): string;
Var pos:integer;
begin
 pos:= indexof(key,0);
 if pos > -1 then
    result:= List[pos][1]
 else
    result := '';
end;

procedure TwtList.clear;
begin
  SetLength(List,0,0);
  Count:= 0;
end;


function TwtList.indexof(st: string; poscol: integer): integer;
Var i:integer;
begin
  result := -1;
  Index :=  -1;
  if poscol >= Column then
    Showmessage ('Warning! il numero di colonna sulla quale si ' +#13+
                 'vuole effetuare la ricerca è maggiore di quelle presenti')
  else
   for i := 0 to Count -1 do
    begin
     if List[i,poscol] = st then
      begin
       Index := i;
       result:= i;
      end;
    end;
end;


{ TListField }

function TwtListField.GetCount: Integer;
begin
  Result:= fcount;
end;

constructor TwtListField.Create;
begin
 fcount:= 0;
end;

procedure TwtListField.add(field, value: string; tipo: TUIBFieldType; size,
  indexField: integer; Enable: boolean);
begin
 fcount:= fcount + 1;
 SetLength(Items,fcount);
 Items[fcount - 1].Field:=  field;
 Items[fcount - 1].value:=  value;
 Items[fcount - 1].Tipo:=   tipo;
 Items[fcount - 1].size:=   size;
 Items[fcount - 1].index:=  fcount;
 Items[fcount - 1].indexField:= indexField ;
 Items[fcount - 1].Enable:= Enable;
end;

procedure TwtListField.clear;
begin
 SetLength(Items,0);
 fcount:= 0;
end;

procedure TwtListField.ClearValues;
Var i:integer;
begin
 for i := 0 to fcount -1 do
   begin
     Items[i].Value := '';
  //   Items[i].Enable := True;
   end;
end;



function TwtListField.IndexField(st: string): Integer;
Var i:integer;
begin
 result := -1;
 for i := 0 to fcount -1 do
   if Items[i].Field = st then  result:= i;
end;

function TwtListField.IndexTipo(st: string): TUIBFieldType;
Var i:integer;
begin
 result := uftUnKnown;
 for i := 0 to fcount -1 do
   if Items[i].Field = st then  result:= Items[i].Tipo;
end;

function TwtListField.FieldToString: string;
Var i:integer;
    st:string;
begin
 st:= '';
 for i := 0 to fcount -1 do
  begin
   if Items[i].Enable then
     st:= st + Items[i].Field  + ',';
  end;
 Result := copy(st,0,length(st) - 1); // levo l'ultima virgola
end;


function TwtListField.ValueToString: string;
Var i:integer;
    st:string;
begin
 st:= '';
 for i := 0 to fcount -1 do
   if Items[i].Enable then
     st:= st + '''' + CheckValueDB(Items[i].Value, Items[i].Tipo) + ''',';
 Result := copy(st,0,length(st) - 1); // levo l'ultima virgola
end;

function TwtListField.WhereToString: string;
Var i:integer;
    st:string;
begin
 st:= '';
 for i := 0 to fcount -1 do
  begin
    if Items[i].Enable then // se il campo è abilitato
      begin
        if Items[i].Value = '<null>' then
            st:= st + Items[i].Field  + ' is null and '
        else
            st:= st + Items[i].Field + '= ''' + CheckValueDB(Items[i].Value,Items[i].Tipo) + ''' and ';
      end;
  end;
 Result := copy(st,0,length(st) - 4); // levo l'ultimo and

end;


end.
