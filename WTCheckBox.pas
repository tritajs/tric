unit WTCheckBox;

interface

uses
  {$IFDEF FPC}   LCLIntf, LCLType, lMessages, lresources, {$ELSE}   Windows, Variants, {$ENDIF}
   Messages, SysUtils, Classes, Graphics, Controls, Forms,   StdCtrls,
   Dialogs,  LSystemTrita;
type

  { TWTCheckBox }

  TWTCheckBox = class(TCheckBox)
  private
    FAttrib: TAttrib;
    FShowFocusColor: boolean;
    FFocusColor: TColor;
    FEditColor: Tcolor;
    FReadOnly: Boolean;
    FValueChecked: string;
    FValueUnchecked: string;

    procedure SetReadOnly(const Value: Boolean);
    // procedure WMMouseUp(var Message : TLMMouseEvent) message WM_MOUSEENTER;
    procedure DoChange(var Msg); message LM_CHANGED;
    procedure SetValueChecked(AValue: String);
    procedure SetValueUnchecked(AValue: String);
  { Private declarations }
  protected
    Procedure Toggle; Override;
    { Protected declarations }
  public
     constructor Create (AOwner: TComponent); override;
     procedure DoEnter; override;
     procedure DoExit; override;
     { Public declarations }
  published
   property Attrib:TAttrib read FAttrib write FAttrib  default DefaultAattrib;
   property ShowFocusColor:boolean read FShowFocusColor write FShowFocusColor;
   property FocusColor:TColor read FFocusColor write FFocusColor;
   property ReadOnly:Boolean read FReadOnly write SetReadOnly;
   property ValueChecked:String read FValueChecked write SetValueChecked;
   property ValueUnchecked:String read FValueUnchecked write SetValueUnchecked;

  { Published declarations }
  end;

 procedure Register;

implementation


{ TWTCheckBox }


constructor TWTCheckBox.Create(AOwner: TComponent);
begin
 inherited;
 FAttrib := DefaultAattrib;
 FFocusColor:= $00F7E0D5;
 FShowFocusColor:= True;
 FValueChecked:= 'T' ;
 FValueUnchecked:= 'F';
end;

procedure TWTCheckBox.DoEnter;
begin
 inherited;
 if ShowFocusColor then
   begin
     FEditColor:= TWTCheckBox(Self).Color;
     TWTCheckBox(Self).Color := FFocusColor;
   end;
end;

procedure TWTCheckBox.DoExit;
begin
  inherited;
  if ShowFocusColor then
     TWTCheckBox(Self).Color := FEditColor;
end;


procedure TWTCheckBox.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
end;

procedure TWTCheckBox.DoChange(var Msg);
begin
  if FReadOnly then
    Checked:= not Checked;
  DoClickOnChange;
end;

procedure TWTCheckBox.SetValueChecked(AValue: String);
begin
  if FValueChecked=AValue then Exit;
   FValueChecked:=AValue;
end;

procedure TWTCheckBox.SetValueUnchecked(AValue: String);
begin
  if FValueUnchecked=AValue then Exit;
  FValueUnchecked:=AValue;
end;


procedure TWTCheckBox.Toggle;
begin
  If Not FReadOnly Then
    Inherited Toggle;
end;





procedure Register;
begin
  RegisterComponents('Trita', [TWTCheckBox]);
end;

end.
