unit LSystemTrita;

interface

uses SysUtils,UIBlib,UIB,uibdataset,Dialogs,Graphics;

type
  TAttribKind = (AtInsert,AtUpdate,AtSay,AtClear,AtMake,AtEnable,AtFind,AtPaste,AtProcedure);
  TAttrib = set of TAttribKind;
  TAttribSql = (AsqlVirgola,AsqlDecimali,AsqlApici,AsqlUpper);
  TSetAttribSql = set of TAttribSql;
  // TFindType = (=,=>,=<,Strating,Containing,Like);
  TNumberSunday = array of Integer;
  ToperazioneSQL = (dsStart, dsFind, dsEdit, dsInsert, dsCancel, dsBrowse);
  TComandoSql = (Open,Execute,ExecuteSql);
//  function CharInPixel(const st: string; width:integer;const Font:TFont): Integer; // Restituisce il numero di caratteri che possono essere inseriti
                                                                                  //  in una grandezza espressa in pixel imbase al font
  function day(data:string):string;
  function EseguiSQL(IbQuery:TUIBQuery; st:string; Esegui:TComandoSql; errore:string):Boolean;
  function EseguiSQLDS(IbQuery:TUIBDataSet; st:string; Esegui:TComandoSql; errore:string):Boolean;
  function CellToRange(cell: integer): string;
  procedure SundaysOfMonth(Year, Month: Word; Var Sunday:TNumberSunday);
  function CompareMonthYear(data1,data2: Double): Boolean; //controlla se il mese e l'anno delle due date sono uguali
  function DateDB(data:string;apici:Boolean = False):string;
  Function FindTable(st:string):string;
  Function FoundStr(SourceStr, TargetStr: string): Boolean;
  Function NameOfMonth(st:string):string;
  Function IsNumeric(st:string):boolean; //controlla se la variabile contiene un valore numerico
  Function InsDecimal(st:string):string; // inserisci i decimali in un numero;
  Function CheckValueDB(Value:string;tipo:TUIBFieldType):string; //controlla i dati del valore e li trasforma in base al tipo di dato
  Function DMYtoStr(day,month,year:string):TDateTime;
  Function Ch_apostrofo(const st: string): string;
  function StrToTime(ora: string): string; // visualizza la stringa nel formato hh:mm
  function StrToSql(st:string;tipo:TUIBFieldType; CharEnd:string):string; // trasforma una stringa per adattarla a un campo sql es: ' lo trasforma in '', data in una data compatibile per sql
  function CalcTime(time1, time2, operatore: string; ShowZero:boolean = True): string; //Somma o sottrae due ore
  function RoundTime(time:string;min:smallint = 30):string; //restituisce il valore time arrotondato per eccesso n relazione al numero dato
  function OreTime(time:string):integer; // restituisce le ore di un campo time
  function MinutiTime(time:string):integer; // restituisce il valore dei minuti di un campo time
  function AddValIntoSql(Value:string;AttribSql:TSetAttribSql;ValueNull:String = 'Null'):string;



  const DefaultAattrib = [AtInsert,AtUpdate,AtSay,AtClear,AtMake,AtEnable,AtFind,AtPaste,AtProcedure];
  const  MonthNames:array[1..12] of string = ('Jan','Feb','Mar','Apr','May','Jun',
                                              'Jul','Aug','Sep','Oct','Nov','Dec');

  const  MonthNameLong:array[1..12] of string = ('Gennaio','Febbraio','Marzo','Aprile','Maggio','Giugno',
                                                'Luglio','Agosto','Settembre','Ottobre','Novembre','Dicembre');


implementation

uses DateUtils;


// Restituisce il numero di caratteri che possono essere inseriti
// in una grandezza espressa in pixel imbase al font
{function CharInPixel(const st: string; width:integer;const Font:TFont): Integer;
Var len,c:integer;
    CharWidth:integer;
    CharPixel:TBitmap;
begin
 CharPixel:= TBitmap.Create;
 CharPixel.Canvas.Font.Assign(Font);
 Result := 0;
 len:= length(st);
 for c:= 1 to len do
  begin
    CharWidth:=  CharPixel.Canvas.TextWidth(st[c]);
    if width >= CharWidth then
     begin
       width:= width - CharWidth;
       Result := Result + 1;
     end
    else
     break;
  end;
end; }



Function  NameOfMonth(st:string):string;
Var NumMonth:Integer;
 begin
  NumMonth:= StrToInt(Copy(st,4,2));
  if NumMonth in [0..12]  then
    Result :=  MonthNameLong[NumMonth]
  else
    Result := ''
 end;



Function FindTable(st:string):string;
 Var PosFrom:integer;
     PosSpace:integer;
     StrDaFrom:string;
begin
  // levo eventuali carriege return e line feed
  st := StringReplace(st,#13,' ',[rfReplaceAll]);
  st := StringReplace(st,#10,' ',[rfReplaceAll]);
  // trasformo tutto in minuscolo
  st:= LowerCase(st);
  PosFrom:= Pos('from',st);
  StrDaFrom:= Copy(st,PosFrom + 5,30);
  PosSpace:= Pos(' ',StrDaFrom);
  if PosSpace = 0 then
     Result:= StrDaFrom
  else
     Result:= Copy(StrDaFrom,1,PosSpace -1);
end;

// Controlla se una stringa è contenuta in un altra separata da virgole
Function FoundStr(SourceStr, TargetStr: string): Boolean;
Var lung,x:integer;
    st:string;
begin
 lung:= length(TargetStr);
 result := False;
 if lung = 0 then exit;
 if length(SourceStr) = 0 then exit;
 for x := 1 to lung do
  begin
    if  TargetStr[x] = ',' then
     begin
       if st = SourceStr then // Controllo
        begin
          result := True;
          exit;
        end
       else
        st:= '';
     end
    else
     st:= st + TargetStr[x];
  end;
 if st = SourceStr then
   result := True;

end;

// ritorna il giorna in lettere di una data
function day(data:string):string;
 const days: array[1..7] of string = ('Lunedì','Martedì','Mercoledì',
                                      'Giovedì','Venerdì','Sabato',
                                      'Domenica');
 Var NrDay:integer;
 begin
   NrDay:= DayOfTheWeek(StrtoDate(data));
   day:= days[NrDay];
 end;

 //
function EseguiSQL(IbQuery:TUIBQuery; st:string;Esegui:TComandoSql; errore:string):Boolean;
begin
 IbQuery.SQL.Clear;
 IbQuery.SQL.Add(st);
 result:= true;
 try
   case Esegui of
    Open :
     begin
      IbQuery.Open;
      if IbQuery.Fields.RecordCount = 0 then
       result := false;
     end;
    Execute :
     begin
       IbQuery.Execute;
       IbQuery.Close();
     end;
    ExecuteSql : IbQuery.ExecSQL;
   end;
 except
   on e: Exception do
    begin
     Showmessage(e.Message +  'Errore: ' + errore);
     result:= false;
    end;
 end;
end;
//
function EseguiSQLDS(IbQuery:TUIBDataSet; st:string;Esegui:TComandoSql; errore:string):Boolean;
begin
 IbQuery.SQL.Clear;
 IbQuery.SQL.Add(st);
 result:= true;
 try
   case Esegui of
    Open :
     begin
      IbQuery.Open;
      if IbQuery.RecordCount = 0 then
       result := false;
     end;
    Execute :
     begin
       IbQuery.Execute;
       IbQuery.Close;
     end;

    ExecuteSql : IbQuery.ExecSQL;
   end;
 except
   on e: Exception do
    begin
     Showmessage(e.Message +  'Errore: ' + errore);
     result:= false;
    end;
 end;
end;
//
function CellToRange(cell: integer): string;
Var resto,quoziente:integer;
begin
 quoziente:= cell div 26;
 resto:= cell mod 26;
 if cell < 27  then
  Result:= chr(64 + cell)
 else if cell < 53 then
  begin
    if resto = 0 then resto := 26;
    Result:= 'A'+ chr(64 + resto)
  end
 else
  begin
    if resto = 0 then
     begin
       resto := 26;
       Dec(quoziente);
     end;
     Result:= chr(64 + quoziente) + chr(64 +resto);
  end;
end;

procedure SundaysOfMonth(Year, Month: Word; Var Sunday:TNumberSunday);
Var
  data: TDateTime;
  TotSunday, TotDay ,x: integer;
begin
   TotDay:= DaysInAMonth(Year, Month);
   data:= StrToDate( '01/' +
                     IntToStr(Month) + '/' +
                     IntToStr(Year));
   TotSunday:= 0;
   for x := 1 to TotDay do
    begin
     if DayOfTheWeek(data) = 7 then
      begin
       Inc(TotSunday);
       SetLength(Sunday,TotSunday);
       Sunday[TotSunday - 1]:= x;
      end;
     data:= IncDay(data,1);
     end;
end;

function CompareMonthYear(data1,data2: Double): Boolean;
Var Year1, Month1, Day1,Year2, Month2, Day2:word;

begin
 result := False;
 DecodeDate(data1, Year1, Month1, Day1);
 DecodeDate(data2, Year2, Month2, Day2);
 if (Year1 = Year2) and (Month1 = Month2) then
    result := True;
end;

function Isnumeric(st:string):Boolean;
Var x,lung:integer;
 const FValidChars = '0123456789.-';
begin
  result:= True;
  lung:= length(st);
  if lung = 0 then result:= False; // se il valore è vuoto non è un numero
  for x := 1 to lung do
   begin
     if pos(st[x],FValidChars) = 0 then
       begin
         Result:= False;
         Break;
       end
   end;
  //se il risultato è vero controllo il primo carattere o l'ultimo se non sono numeri il risultato è falso
  if Result then
    begin
      if (pos(st[lung],'0123456789') = 0) or (pos(st[1],'0123456789') = 0) then
         Result:= False;
     end;
end;

function InsDecimal(st: string): string;
Var x,lung:integer;
    intero,decimale:string;
begin
if st <> '' then
 begin
   lung:= length(st);
   for x:= lung downto 1 do
    begin
      if st[x] = DecimalSeparator then
       begin
         decimale:= intero;
         intero:= '';
       end
      else
        intero := st[x] + intero;
    end;
    if decimale = '' then decimale:= '00';
    if Length(decimale) = 1 then decimale := decimale + '0';
    result:= intero + DecimalSeparator + decimale;
  end;
end;


function DateDB(data:string;apici:Boolean):string;
Var
 mese,st,anno: string;
 leng:word;
begin
 Result:= 'null';
 leng:= length(Trim(data));
 if (leng > 7) and (data[3] in ['.','/','-'])  then
  begin
    st:= 'null';
    if (copy(data,4,1) <> '-') and  (copy(data,5,1) <> '-') then
      begin
       mese:= Copy(data,4,2);
       anno:= Copy(data,7,4);
       if Length(anno) = 2 then anno:= '20' + anno;
       st:= Copy(data,1,2)+ '/' + MonthNames[strtoint(mese)] + '/' +  anno;
       if apici then
         st:= '''' + st + '''';
      end;
    Result := st;
  end;
end;


Function CheckValueDB(Value:string;tipo:TUIBFieldType):string;
begin
    (* TUIBFieldType = (uftUnKnown, uftNumeric, uftChar, uftVarchar, uftCstring, uftSmallint,
    uftInteger, uftQuad, uftFloat, uftDoublePrecision, uftTimestamp, uftBlob, uftBlobId,
    uftDate, uftTime, uftInt64, uftArray {$IFDEF IB7_UP}, uftBoolean{$ENDIF} *)
 if tipo in [uftDate,uftTime,uftTimestamp]   then   Result:= DateDB(value)
 else if tipo in [uftDoublePrecision,uftFloat,uftNumeric,uftSmallint,uftInteger,uftInt64]   then   Result:= StringReplace(value,',','.',[rfReplaceAll])
 else if tipo in [uftChar,uftCstring,uftVarchar] then   Result:= StringReplace(value,'''','''''',[rfReplaceAll])
 else
   Result:= value;
end;

// permette di trasformare una stringa per adattarla a un campo sql con relativi apici
function StrToSql(st: string; tipo: TUIBFieldType; CharEnd: string): string;
begin
 result := '''';
 result:= result + CheckValueDB(st,tipo);
 if CharEnd <> '' then
   result:= result + CharEnd;
end;



Function DMYtoStr(day,month,year:string):TDateTime;
Var giorno:string;
begin
 if Length(day) = 1 then
    giorno:=  '0'+ day + '/'
 else
  giorno:= day + '/';
 if Length(month) = 1 then
    giorno:= giorno +  '0' + month + '/'
 else
    giorno:= giorno +  month + '/';
 giorno:= giorno +  year;

 Result:= StrToDate(giorno);

end;

function Ch_apostrofo(const st: string): string;
var Lung,x:smallint;
    temp:string;
begin
  lung:= length(st);
  result:= '';
  temp:= '';
  for x:= 1 to lung do
     begin
        if st[x] = '''' then
          temp:= temp + '''' + ''''
        else
          temp:= temp + st[x];
     end;
result:= temp;
end;

function StrToTime(ora: string): string;
Var lung:smallint;
begin
 lung:= Length(ora);
 case lung of
    0: ora := '';
    1: ora := '0' + ora + ':00';
    2: ora := ora + ':00';
    3: ora := '0' + copy(ora,1,1) + ':' + copy(ora,3,1) + '0';
    4: begin // controllo la posizione dellla virgola
         if pos(',',ora) = 2 then
            ora := '0' + copy(ora,1,1) + ':' + copy(ora,3,2)
         else
            ora := copy(ora,1,2) + ':' + copy(ora,4,1) + '0';
       end;
    5: ora := copy(ora,1,2) + ':' + copy(ora,4,2);
 end;
 result:= ora;
end;

// restituisce il valore delle ore di un campo time
function OreTime(time:string):integer;
Var Orario: Double;
begin
 if time = '' then
   time := '00' + DecimalSeparator + '00'; // se il parametro ricevuto è vuoto, lo trasformo in hh.mm
 time:= StringReplace(time,':',DecimalSeparator,[]); // sostituisco eventualmente  i due punti  con la virgola (separatore decimale)
 orario:= StrToFloat(time);  //Trasformo Il campo stringa in uno float;
 Result:= Trunc(orario); // restituisce l'ore del campo time
end;

// restituisce il valore dei minuti di un campo time
function MinutiTime(time:string):integer;
Var orario: Double;
    ore:integer;
begin
 if time = '' then
   time := '00' + DecimalSeparator + '00'; // se il parametro ricevuto è vuoto, lo trasformo in hh.mm
 time:= StringReplace(time,':',DecimalSeparator,[]); // sostituisco eventualmente  i due punti  con la virgola (separatore decimale)
 orario:= StrToFloat(time);  //Trasformo Il campo stringa in uno float;
 ore:= Trunc(orario);
 Result:= Round((orario - ore) * 100); // restituisce l'ore del campo time
end;

function AddValIntoSql(Value: string; AttribSql: TSetAttribSql;
  ValueNull: String): string;
begin
  if Value <> '' then
    begin
      if AsqlDecimali in AttribSql then // se il valore e di tipo decimale controllo se il separatore decimale è un punto
       value := StringReplace(Value,',','.',[rfReplaceAll])
      else
        value:= Ch_apostrofo(value); //controllo se ci sono degli apostrofi

      if AsqlUpper in AttribSql then //trasformo tutto in maiuscolo
        value:= UpperCase(value);

      if AsqlApici in AttribSql then //aggiungo gli apici prima e dopo il valore
        value:= '''' + value + '''';
      if AsqlVirgola in AttribSql then //aggiungo dopo il valore la virgola
        value:=  value + ',';
      result := value;
    end
  else
    begin
      if AsqlVirgola in AttribSql then //aggiungo dopo il risultato la virgola
        Result := ValueNull + ','
      else
        Result := ValueNull;

    end;
end;







function CalcTime(time1, time2, operatore: string; ShowZero:boolean = True): string;
Var min1,min2,tmin1,tmin2,ora1,ora2 :double;
    ore,minuti,TotMin:integer;
begin
 result:= '';
 TotMin:= 0;
 // calcolo i secondi per ogni orario
 ora1:=  OreTime(time1);
 min1:=  MinutiTime(time1);
 tmin1:=  ora1 * 60 + min1; // trasformo le ore in minuti e le aggiungo ai suoi minuti
 ora2:=  OreTime(time2);
 min2:=  MinutiTime(time2);
 tmin2:=  ora2 * 60 + min2; // trasformo le ore in minuti e le aggiungo ai suoi minuti
 // eseguo il calcolo in base all'operatore
 if operatore = '+' then  TotMin:= Trunc(tmin1 + tmin2);
 if operatore = '-' then  TotMin:= Trunc(tmin1 - tmin2);
 // se il risultato è solo minuti, controllo se il valore è negativo
 if ((TotMin > -60) and (Totmin < 60) and (TotMin <> 0)) then
   begin
    if TotMin < 0 then // significa che ha un valore negativo
     result:= '-00:' + Format('%.2d',[ABS(TotMin)])
    else
     result:= '00:' + Format('%.2d',[TotMin]);
    exit;
   end;
 // ritrasformo i minuti in hh:mm
 ore:=  Trunc(TotMin / 60);
 minuti:= ABS(TotMin - (ore * 60));
 if ShowZero then // ritorno come risultato il numero anche s'è zero
     result:= Format('%-.2d',[ore]) + ':' + Format('%.2d',[Minuti])
 else  // altrimenti controllo il numero, s'è zero non lo restituisco altrimenti si
   if (ore <> 0) or (minuti <> 0) then
    result:= Format('%-.2d',[ore]) + ':' + Format('%.2d',[Minuti]);
end;

// arrotonda i minuti all'ora successiva o precedente in relazione al
// valore del parametro minutes
function RoundTime(time:string;min:smallint = 30):string;
Var ore,minuti:integer;
begin
 ore:= OreTime(time);
 //Determino i minuti
 minuti:= MinutiTime(Time);
 if minuti <> 0 then  // se i minuti sono diversi da zero
    begin
      // se i minuti del valore time sono >= all'argomento min incremento le ore di uno
      if minuti >= min then Inc(ore);
      result:= Format('%-.2d',[ore]) + ':00';
    end
  else
    result:= time;
end;

end.
