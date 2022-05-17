unit WDateEdit;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF FPC} lMessages, {$ELSE}   Windows,,Messages {$ENDIF}
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, EditBtn,
  LSystemTrita,CalendarPopup;

type
  { TWDateEdit }
  TWDateEdit = class(TDateEdit)
  private
    FAttrib: TAttrib;
    FTypeFind: string;
  protected
    procedure EditKeyPress(var Key: char); override;
    procedure EditEditingDone; override;
    procedure ButtonClick; override;
    function CheckData:Boolean;
//    procedure Change; override;
    { Protected declarations }
  public
    dataok:boolean;
    function GetDataDB(apici:Boolean):string;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  published
    property Attrib:TAttrib read FAttrib write FAttrib Default DefaultAattrib;
    property TypeFind:string read FTypeFind write FTypeFind;
    { Published declarations }
  end;

procedure Register;

implementation


{ TWDateEdit }


procedure TWDateEdit.EditKeyPress(var Key: char);
begin
if Key = #13 then
    begin
      if CheckData then
       inherited EditKeyPress(Key);
    end
  else
   inherited EditKeyPress(Key);
end;


procedure TWDateEdit.EditEditingDone;
begin
  if not CheckData then
    begin
      if Visible then SetFocus;
    end
  else
    inherited EditEditingDone;
end;

procedure TWDateEdit.ButtonClick;
begin
 if date < EncodeDate(1900,01,01) then
   Date := SysUtils.Date;
 inherited ButtonClick;
end;


function TWDateEdit.CheckData: Boolean;
Var Year,Month,Day:word;
begin
 result:= True;
 if (TEXT <> '') AND (Text[1] in ['0'..'9']) then
   begin
    Day := StrToIntDef(copy(Text,1,2),0);
    month:= StrToIntDef(copy(Text,4,2),0);
    Year:=StrToIntDef(copy(Text,7,4),0);
    result:=(Year<>0) and (Year > 1900) and (Year < 2200)
             and (Month in [1..12])
           and (Day<>0) and (Day<=MonthDays[IsleapYear(Year),Month]);
    dataok:=result;
   end;
end;

function TWDateEdit.GetDataDB(apici: Boolean): string;
begin
 Result := DateDB(Text,apici);
end;


constructor TWDateEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTypeFind := '=';
  FAttrib := DefaultAattrib;
  Cursor:= crHandPoint;
  DateOrder:= doDMY;
  DefaultToday:= False;
end;

destructor TWDateEdit.Destroy;
begin
  inherited Destroy;
end;


procedure Register;
begin
  RegisterComponents('Trita',[TWDateEdit]);
end;

end.
