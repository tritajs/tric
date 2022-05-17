unit WTComboBox;

interface

uses
    LCLIntf, LCLType, lMessages, lresources,{$IFDEF MSWINDOWS} Windows,Variants, {$ENDIF}
    SysUtils, Classes, Graphics, Controls, Forms,   StdCtrls,
    Dialogs,  LSystemTrita, messages;

type
  TWTComboBox = class(TComboBox)
  private
    FComboBoxColor: Tcolor;
    FReadOnly: Boolean;
    FShowFocusColor: boolean;
    FFocusColor: TColor;
    FAttrib: TAttrib;
    procedure SetReadOnly(const Value: Boolean);
    procedure CMEnter(var Message: TCMEnter); message   CM_ENTER;
    procedure CMExit (var Message: TCMExit ); message CM_EXIT;
    procedure WMLButtonDown(var Message: TWMLButtonDown); message WM_LBUTTONDOWN;
     { Private declarations }
  protected
    procedure KeyPress(var Key: Char); override;
    procedure CreateWnd; override;
    procedure change; override;
    { Protected declarations }
  public
    constructor Create ( AOwner : TComponent ); override;

    { Public declarations }
  published
    property  ShowFocusColor:boolean read FShowFocusColor write FShowFocusColor;
    property  FocusColor:TColor read FFocusColor write FFocusColor;
    property  ReadOnly:Boolean read FReadOnly write SetReadOnly default False;
    property  Attrib:TAttrib read FAttrib write FAttrib default DefaultAattrib;

{ Published declarations }
  end;

   procedure Register;


implementation


{ TWTComboBox }


constructor TWTComboBox.Create(AOwner: TComponent);
begin
  inherited;
  FFocusColor:= $00F7E0D5;
  FShowFocusColor:= True;
  FAttrib           :=  DefaultAattrib;
end;


procedure TWTComboBox.CMEnter(var Message: TCMEnter);
begin
  inherited;
   if FShowFocusColor then
    begin
     FComboBoxColor:= Self.Color;
     Self.Color:= FFocusColor;
    end;
end;

procedure TWTComboBox.CMExit(var Message: TCMExit);
begin
 inherited;
 if (text <> '') and (Items.IndexOf(Text) = -1)  then // se la stringa inserita non corrisponde con uno dei valori del items
  begin
   ItemIndex:= 0;
   SetFocus;
  end
 else
   if FShowFocusColor then Color:= FComboBoxColor;
end;


procedure TWTComboBox.KeyPress(var Key: Char);
begin
 if ReadOnly then
  Key:= #0
 else
 //inherited;
end;

procedure TWTComboBox.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
end;


procedure TWTComboBox.CreateWnd;
begin
  inherited;
  text:= '';
  Items.Add('');
end;

procedure TWTComboBox.change;
begin
///  inherited;
end;

procedure TWTComboBox.WMLButtonDown(var Message: TWMLButtonDown);
begin
 if not ReadOnly then
   inherited;
end;

procedure Register;
begin
  RegisterComponents('Trita', [TWTComboBox]);
end;

initialization

 {$i trita.lrs}


end.