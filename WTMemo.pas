unit WTMemo;

interface

uses
  SysUtils, Classes, Controls, StdCtrls,LSystemTrita, Graphics,
  Dialogs,LCLType,LCLIntf,lresources,LCLProc,LMessages;

type
  TWTMemo = class(TMemo)
  private
    Fattrib : TAttrib;
    FTypeFind: string;
    FShowFocusColor: boolean;
    FFocusColor: Tcolor;
    FMemoColor: Tcolor; // conterrà il colore di background del componente qunado riceve il focus
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit (var Message: TCMExit ); message CM_EXIT;
    { Private declarations }
  protected
    { Protected declarations }
  public
   constructor Create(AOwner: TComponent); override;
    { Public declarations }
  published     { Published declarations }
    property Attrib:TAttrib read FAttrib write FAttrib default DefaultAattrib;
    property TypeFind:string read FTypeFind write FTypeFind;
    property ShowFocusColor:boolean read FShowFocusColor write FShowFocusColor;
    property FocusColor:TColor read FFocusColor write FFocusColor;
  end;

procedure Register;

implementation



{ TWTMemo }

procedure TWTMemo.CMEnter(var Message: TCMEnter);
begin
 inherited;
   if FShowFocusColor then
    begin
     FMemoColor:= TMemo(Self).Color;
     TMemo(Self).Color:= FFocusColor; //viene assegnato il colore stabilito per il focus
    end;
end;

procedure TWTMemo.CMExit(var Message: TCMExit);
begin
 inherited;
 if FShowFocusColor then
   TMemo(Self).Color := FMemoColor;// restituisce il colore prima del focus
end;

constructor TWTMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FAttrib := DefaultAattrib;
  FTypeFind := 'Containing';
  FFocusColor:= $00F7E0D5;
  FShowFocusColor:= True;
end;

procedure Register;
begin
  RegisterComponents('Trita', [TWTMemo]);
end;

end.
