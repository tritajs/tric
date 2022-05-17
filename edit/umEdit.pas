unit umEdit;
interface

uses
  {$IFDEF FPC}   LCLIntf, LCLType, lMessages, lresources, {$ELSE}   Windows, Variants, {$ENDIF}
   Messages, SysUtils, Classes, Graphics, Controls, Forms,   StdCtrls,
    Dialogs,  LSystemTrita;

type
//

  { TumEdit }

  TumEdit = class(TEdit)
  private
    FEditColor:TColor; // contiene il colore impostato all'edit in fase di design
    FColorDisabled: TColor;
    FFocused: Boolean;
    FAttrib: TAttrib;
    FTypeFind: string;
    FShowFocusColor: boolean;
    FFocusColor: TColor;
    procedure SetColorDisabled(Value: TColor);
    procedure CMEnter(var Message:{$IFDEF FPC} TLMEnter {$ELSE} TWMEnter {$ENDIF}); message CM_ENTER;
    procedure CMExit(var Message: {$IFDEF FPC} TLMExit  {$ELSE} TCMExit  {$ENDIF}); message CM_EXIT;
    procedure SetShowFocusColor(const Value: boolean);
  protected
    fCanvas    : TControlCanvas;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Change; override;
    procedure SetFocused(A: Boolean); virtual;
    function  GetCanvas: TCanvas; virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure  CreateWnd; override;
    destructor Destroy; override;
    property Canvas: TCanvas read GetCanvas;
  published
    property Attrib:TAttrib read FAttrib write FAttrib Default DefaultAattrib;
    property TypeFind:string read FTypeFind write FTypeFind;
    property ColorDisabled: TColor read FColorDisabled write SetColorDisabled;
    property ShowFocusColor:boolean read FShowFocusColor write SetShowFocusColor;
    property FocusColor:TColor read FFocusColor write FFocusColor;
  end;
//

  { TumValidEdit }

  TumValidEdit = class(TumEdit)
  private
    fValidChars    : String;
    fValidateChars : Boolean;
    procedure CNChar(var Message: TLMKeyUp); message CN_CHAR;
  public
    constructor Create(AOwner : TComponent);                           override;
  published
    property ValidChars: String read fValidChars write fValidChars;
    property ValidateChars: Boolean read fValidateChars write fValidateChars default True;
  end;
//

  { TumNumberEdit }

  TumNumberEdit = class(TumEdit)
  private
    procedure CNChar(var Message: TLMKeyUp); message CN_CHAR;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  protected
  public
    constructor Create(AOwner : TComponent);  override;
  published
  end;
//
  TValidChars = set of Char;

  { TumDataEdit }

  TumDataEdit = class(TumEdit)
  private
    DataOld:string;
    FOnChange: TNotifyEvent;
    procedure Settext(const Value: TCaption);
    function  Gettext: TCaption;
    procedure CMEnter(var Message: TLMEnter); message CM_ENTER;
  protected
    FValueIB: string;
    CarPos:   integer;
    UltimoCar:string;
    ValidChars: TValidChars;
    procedure CNChar(var Message: TLMKeyUp); message CN_CHAR;
    procedure DoExit;override;
    procedure WMKeyDown(var Message: TLMKeyDown); message WM_KEYDOWN;
    procedure DChanged(Sender: TObject);
    procedure UpdateData(const value: String; const car:string;  pos: integer);
    procedure ValidChar(const pos: integer);
    procedure SetValueIB(const Value: string);
    function  CheckDate:boolean;
  public
    constructor Create(AOwner : TComponent); override;
    procedure ClearDate;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property ValueIB:string read FvalueIB  write SetValueIB;
    property Enabled;
    property Text: TCaption read GetText write SetText;
  end;
//

  { TumTimeEdit }

  TumTimeEdit = class(TumEdit)
  private
    FOnChange: TNotifyEvent;
    procedure Settext(const Value: TCaption);
    function  Gettext: TCaption;
    procedure CMEnter(var Message: TLMEnter); message CM_ENTER;
  protected
    CarPos:   integer;
    UltimoCar:string;
    ValidChars: TValidChars;
    procedure CNChar(var Message: TLMKeyUp); message CN_CHAR;
    procedure DoExit;override;
    procedure WMKeyDown(var Message: TLMKeyDown); message LM_KEYDOWN;
    procedure DChanged(Sender: TObject);
    procedure UpdateTime(const value: String; const car:string;  pos: integer);
    procedure ValidChar(const pos: integer);
  public
    ValueIB: string;
    constructor Create(AOwner : TComponent); override;
    procedure CreateWnd; override;
  published
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property Enabled;
    property Text: TCaption read GetText write SetText;
  end;






procedure Register;

implementation

const
  MonthNames:array[1..12] of string =
    ('Jan','Feb','Mar','Apr','May','Jun',
    'Jul','Aug','Sep','Oct','Nov','Dec');
{ BONUS numerical transformation routines}

constructor TumEdit.Create(AOwner: TComponent);
begin
  FTypeFind := 'Starting';
  inherited Create(AOwner);
  FAttrib := DefaultAattrib;
  FCanvas := TControlCanvas.Create;
  FCanvas.Control := Self;
  FColorDisabled := clWindow; // though I prefer clBtnFace;
  FFocusColor:= $00F7E0D5;
  FShowFocusColor:= True;
end;

procedure TumEdit.CreateWnd;
begin
  inherited CreateWnd;
  FEditColor:=   Color;
end;

destructor TumEdit.Destroy;
begin
  fCanvas.Free;
  inherited Destroy;
end;

procedure TumEdit.Notification(AComponent: TComponent;
                               Operation : TOperation);
begin
  inherited Notification(AComponent, Operation);
end;

procedure TumEdit.Change;
begin
  inherited Change;
//  Invalidate; {!!! WARNING Bug on loosing focus (KARPOLAN)}
end;

procedure TumEdit.SetFocused(A : Boolean);
begin
  if FFocused = A then
    Exit;
  FFocused := A;
//  Invalidate; {!!! WARNING Bug on loosing focus (KARPOLAN)}
end;

function TumEdit.GetCanvas: TCanvas;
begin
  Result := TCanvas(fCanvas);
end;

procedure TumEdit.SetColorDisabled(Value: TColor);
begin
  if FColorDisabled <> Value then
   begin
    FColorDisabled := Value;
    Invalidate;
   end;
end;

procedure TumEdit.SetShowFocusColor(const Value: boolean);
begin
  FShowFocusColor := Value;
end;


procedure TumEdit.CMEnter(var Message : TLMEnter);
begin
  SetFocused(True);
  if ShowFocusColor then
    begin
      Color := FFocusColor;
    end;
  inherited;
end;

procedure TumEdit.CMExit(var Message : TLMExit);
begin
  SetFocused(False);
  if ShowFocusColor then
     Color := FEditColor;
  inherited;
end;


{ TumValidEdit }

constructor TumValidEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTypeFind := '=';
  fValidateChars := True;
end;

procedure TumValidEdit.CNChar(var Message: TLMKeyUp);
Var i:integer;
begin
  if ValidateChars and (Char(Message.CharCode) <> #8) then
   begin
    i := Length(FValidChars);
    if i <> 0 then
     for i := 1 to i do
      if fValidChars[i] = Char(Message.CharCode) then inherited
   end
  else inherited;
end;



{ TumNumberEdit }

constructor TumNumberEdit.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FTypeFind := '=';
// if DefaultFormatSettings.DecimalSeparator = '.' then
 Text:= '';
end;




procedure TumNumberEdit.WMPaint(var Message: TWMPaint);
Var
  Rect: TRect;
begin
  inherited;
//   if (Text = '') or (Text = '0')then
   begin
//    Rect := GetClientRect;
//    Canvas.TextRect(Rect,2,2,'0');
   end;

end;

procedure TumNumberEdit.CNChar(var Message: TLMKeyUp);
const
   Kmeno = 45;
   Kpunto = 46; Kvirgola = 44;
function IFDecimalSeparatore:Boolean;    // controlla la presenza dei separatori decimali
Var x,trovati,textleg:integer;
begin
 trovati:= 0;
 textleg:= Length(Text);
 for x := 0 to textleg do
   if Text[x] = DefaultFormatSettings.DecimalSeparator then
    Inc(trovati);
   Result:= trovati > 0;
 end;

begin
  // if Message.CharCode = Kvirgola then Message.CharCode := Kpunto;
   // controllo che il primo carattere sia un numero o un segno meno
   if (Message.CharCode = Kmeno) and (SelStart = 0) then
     inherited
   else if Char(Message.CharCode) = #27 then
     begin
      Text := '';
     end
    else if Char(Message.CharCode) = #8 then
     inherited
   else
    begin
      if (Message.CharCode = Kpunto) and (char(Kpunto) <> DefaultFormatSettings.DecimalSeparator) then
         Message.CharCode := Kvirgola;
      if (Message.CharCode = Kvirgola) and (char(Kvirgola) <> DefaultFormatSettings.DecimalSeparator) then
         Message.CharCode := Kpunto;
      if Char(Message.CharCode) in ['0'..'9',DefaultFormatSettings.DecimalSeparator] then
       // se il carattere inserito è una virgola, controllo s'è stata gia inserita
       begin
        if Char(Message.CharCode) = DefaultFormatSettings.DecimalSeparator then   //se il carattere è di tipo separatore decimale,
          begin                                                                   // controllo s'è stato già inserito
            if IFDecimalSeparatore then
              Message.CharCode :=  0
            else
              inherited
          end
        else
          inherited
       end
      else
        Message.CharCode :=  0
    end;
end;

{ TumDataEdit }
constructor TumDataEdit.Create(AOwner : TComponent);
begin
  inherited Create(AOwner);
  FTypeFind := '=';
  MaxLength:= 10;
  Width:= 90;
  text := '--' + DefaultFormatSettings.DateSeparator + '--'+ DefaultFormatSettings.DateSeparator + '----';
  DataOld:= '';
 // inherited OnChange := DChanged(Self);
end;



function TumDataEdit.CheckDate: boolean;
Var
 i: Integer;
begin
 Result:= True;
 for i:= 1 to 10 do
   begin
    ValidChar(i -1);
    if not (text[i] in ValidChars) then
    begin
     Result:= False;
     exit;
    end;
   end;
end;

procedure TumDataEdit.SetValueIB(const Value: string);
Var
 mese,st: string;
begin
 if (pos('-',value) = 0) and (CheckDate) and (Length(value) = 10)then
  begin
   st:=  '';
   if DataOld = '' then DataOld:= value;
   if (copy(value,4,1) <> '-') and  (copy(value,5,1) <> '-') then
     begin
      mese:= Copy(value,4,2);
      st:= Copy(value,1,2)+ '/' + MonthNames[strtoint(mese)] + '/' +  Copy(value,7,4);
     end;
   FValueIB := st;
  end
 else
   FValueIB := '';
end;

Procedure TumDataEdit.UpdateData(const value: String; const car:string; pos: integer);
Var
 p:Byte;
 st:string;
 temp:string;
begin
 temp:= Text;
 st:= '';
 for p:= 0 to 9 do
   begin
    if pos = p then
     st:= st + car
    else
      st:= st + copy(temp,p + 1,1);
   end;
   Text:= st;
end;


procedure TumDataEdit.ValidChar(const pos: integer);
begin
 case pos of
  0:           ValidChars:= ['0'..'3'];
  2,5:         ValidChars:= [DefaultFormatSettings.DecimalSeparator];
  1,4,7,8,9:   ValidChars:= ['0'..'9'];
  3:           ValidChars:= ['0'..'1'];
  6:           ValidChars:= ['1'..'2'];
 end;
 //Controlla se il primo numero del mese è 1
 if (copy(Text,4,1)  = '1') and (pos = 4)  then
   ValidChars:= ['0'..'2'];
 //Controlla se il primo numero del giorno è 3
 if (copy(Text,1,1)  = '3') and (pos = 1)  then
   ValidChars:= ['0'..'1'];
end;

procedure TumDataEdit.CNChar(var Message: TLMKeyUp);
begin
 if (Char(Message.CharCode) = #8) or (ReadOnly) then
   exit
 else if Char(Message.CharCode) = #27 then
  begin
   Text := '';
   inherited;
  end
 else
  begin
   ValidChar(SelStart); //in base alla posizione del numero del mese
                        //stabilisce le cifre che possono essere inserite
   if (Char(Message.CharCode) in ValidChars) then
     begin
       UltimoCar:= string(Char(Message.CharCode));
       if (SelStart = 2) or (SelStart = 5) then  SelStart := SelStart + 1;
       CarPos:= SelStart;
       UpdateData(Text,UltimoCar,selstart);
       if ((CarPos = 1) or (CarPos = 4) and (CarPos < 10)) then
         selstart:= CarPos + 2
       else
         selstart:= CarPos + 1;
    end;
//    inherited;
  end;
end;

procedure TumDataEdit.DChanged(Sender: TObject);
//label ex;
begin
  if (csDesigning in ComponentState) then Exit;
  if (csLoading in ComponentState) or
     (csReading in ComponentState) then
    begin
     Modified:= False;
     Exit;
    end;
  if Text = '' then
    begin
     Text := '--' + DefaultFormatSettings.DecimalSeparator + '--'+ DefaultFormatSettings.DecimalSeparator + '----';
     modified:= False;
     DataOld:= '';
    end
  else
    begin
      ValueIB:= text;
      if DataOld <> Text then Modified := True;
      if Assigned(FOnChange)  then FOnChange(Sender);
    end;
end;
procedure TumDataEdit.ClearDate;
begin
  Text := '--' + DefaultFormatSettings.DecimalSeparator + '--'+ DefaultFormatSettings.DecimalSeparator + '----';
end;


function TumDataEdit.Gettext: TCaption;
var
  Len: Integer;
begin
  Len := GetTextLen;
  SetString(Result, PChar(nil), Len);
  if Len <> 0 then GetTextBuf(Pointer(Result), Len + 1);
end;

procedure TumDataEdit.Settext(const Value: TCaption);
begin
  if GetText <> Value then
   begin
     SetTextBuf(PChar(Value));
   end;
end;

procedure TumDataEdit.WMKeyDown(var Message: TLMKeyDown);
begin
 if Message.CharCode <> 46 then
   inherited;
end;


procedure TumDataEdit.DoExit;
Var Pos:Integer;
begin
  pos:= SelStart;

 if Text <> '--' + DefaultFormatSettings.DecimalSeparator + '--'+ DefaultFormatSettings.DecimalSeparator + '----' then
    begin
      if not CheckDate then
        begin
         SetFocus;
         ShowMessage('data non valida');
         SelStart:= Pos;
        end;
    end;
    inherited;
end;
procedure TumDataEdit.CMEnter(var Message: TLMEnter);
begin
  inherited;
  SelStart:= 0;
end;


{ TumTimeEdit }


procedure TumTimeEdit.CMEnter(var Message: TLMEnter);
begin
  inherited;
  SelStart:= 0;
end;

constructor TumTimeEdit.Create(AOwner: TComponent);
begin
 inherited Create(AOwner);



//  inherited OnChange := DChanged;
end;

procedure TumTimeEdit.CreateWnd;
begin
  inherited CreateWnd;
  FTypeFind := '=';
  MaxLength:= 5;
  Width:= 60;
  text := '00:00';
  ValueIB:= '';
end;


{function TumTimeEdit.CheckTime: boolean;
Var
 i: Integer;
begin
 Result:= True;
 for i:= 1 to 4 do
   begin
    ValidChar(i - 1);
    if not (text[i] in ValidChars) then
    begin
     Result:= False;
     exit;
    end;
   end;
end; }

procedure TumTimeEdit.DChanged(Sender: TObject);
//label ex;
begin
  if (csDesigning in ComponentState) then Exit;
  if (csLoading in ComponentState) or
     (csReading in ComponentState) then
    begin
     Modified:= False;
     Exit;
    end;
  if Text = '' then
    begin
     Text := '00:00';
     modified:= False;
    end
  else
    begin
      if Assigned(FOnChange)  then FOnChange(Sender);
    end;
end;

procedure TumTimeEdit.DoExit;
begin
    inherited;
end;

function TumTimeEdit.Gettext: TCaption;
var
  Len: Integer;
begin
  Len := GetTextLen;
  SetString(Result, PChar(nil), Len);
  if Len <> 0 then GetTextBuf(Pointer(Result), Len + 1);
end;

procedure TumTimeEdit.Settext(const Value: TCaption);
Var st:string;
begin
  if GetText <> Value then
   begin
     SetTextBuf(PChar(Value));
     st:= Copy(Value,1,2) + '.' + Copy(Value,4,2);
     ValueIB:= st;
   end;
end;

procedure TumTimeEdit.UpdateTime(const value: String; const car: string;
  pos: integer);
Var
 p:Byte;
 st:string;
 temp:string;
begin
 temp:= Text;
 st:= '';
 for p:= 0 to 4 do
   begin
    if pos = p then
     st:= st + car
    else
      st:= st + copy(temp,p + 1,1);
   end;
   Text:= st;
end;

procedure TumTimeEdit.ValidChar(const pos: integer);
begin
 case pos of
  0: ValidChars:= ['0'..'2'];
  1: begin
      if (Text[1] = '0') or (Text[1] = '1') Then
         ValidChars:= ['0'..'9']
      else
         ValidChars:= ['0'..'4'];
     end;
  2:           ValidChars:= [':'];
  3: begin
       if (Text[4] <> '0') Then
         ValidChars:= ['0'..'5']
       else
         ValidChars:= ['0'..'6'];
     end;
  4: begin
      if (Text[4] = '6') Then
         ValidChars:= ['0']
      else
         ValidChars:= ['0'..'9'];
     end;
 end;
end;

procedure TumTimeEdit.CNChar(var Message: TLMKeyUp);
begin
  if (Char(Message.CharCode) = #8) or (ReadOnly) then
    exit
  else if Char(Message.CharCode) = #27 then
   begin
    Text := '00:00';
    inherited;
   end
  else
   begin
    ValidChar(SelStart); //in base alla posizione del numero del mese
                         //stabilisce le cifre che possono essere inserite
    if (Char(Message.CharCode) in ValidChars) then
      begin
        UltimoCar:= string(Char(Message.CharCode));
        if (SelStart = 2) then  SelStart := SelStart + 1;
        CarPos:= SelStart;
        UpdateTime(Text,UltimoCar,selstart);
        if (CarPos = 1)  then
          selstart:= CarPos + 2
        else
          selstart:= CarPos + 1;
     end;
//    inherited;
   end;
end;

procedure TumTimeEdit.WMKeyDown(var Message: TLMKeyDown);
begin
 if Message.CharCode <> 46 then

  inherited;
end;


procedure Register;
begin
  RegisterComponents('Trita', [TumEdit, TumValidEdit,
                                  TumNumberEdit, TumDataEdit, TumTimeEdit]);
end;

initialization
  {$i umedit.lrs}

end.
