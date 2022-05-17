unit wtexpression;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, SynEdit,  Forms, Controls,
  Graphics, Dialogs, StdCtrls, ExtCtrls, Buttons, ButtonPanel, LMessages;

type

  { TFmwtexpression }

  TFmwtexpression = class(TForm)
    ButtonPanel1: TButtonPanel;
    CBoperatore: TComboBox;
    CBdata: TComboBox;
    Ecampo: TEdit;
    Evalore1: TEdit;
    Evalore2: TEdit;
    Evalore: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Lvalore1: TLabel;
    Lvalore2: TLabel;
    Lesempio: TLabel;
    MemoEsempio: TMemo;
    MemoSql: TSynEdit;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Pesempio: TPanel;
    SBand: TSpeedButton;
    SBOK: TSpeedButton;
    SBvalori: TSpeedButton;
    SBor: TSpeedButton;
    SBcancel: TSpeedButton;
    procedure CancelButtonClick(Sender: TObject);
    procedure CBdataChange(Sender: TObject);
    procedure CBoperatoreChange(Sender: TObject);
    procedure EvaloreChange(Sender: TObject);
    procedure FormShortCut(var Msg: TLMKey; var Handled: Boolean);
    procedure FormShow(Sender: TObject);
    procedure SBcancelClick(Sender: TObject);
    procedure SBvaloriClick(Sender: TObject);
    procedure SBandClick(Sender: TObject);
    procedure SBOKClick(Sender: TObject);
    procedure SBorClick(Sender: TObject);
  private
    procedure MakeEspressione;
    procedure ImpostazioneIniziale;
    { private declarations }
  public
    function CurrentExpression:string;
    { public declarations }
  end;



implementation
 Var LogicOperatore:string= '';
     Piuvalori,operatore,campo:string;

{$R *.lfm}

{ TFmwtexpression }

procedure TFmwtexpression.CBoperatoreChange(Sender: TObject);
Var
  idx:integer;
begin
  ImpostazioneIniziale;
  idx:= CBoperatore.ItemIndex;
  operatore:= '';
  case idx of
   0: operatore:= ' = ';
   1: operatore:= ' <> ';
   2: operatore:= ' > ';
   3: operatore:= ' < ';
   4: operatore:= ' >= ';
   5: operatore:= ' <= ';
   6: operatore:= ' CONTAINING ';
   7: begin
       MemoEsempio.Lines.Add('COLORE IN (''BIANCO'',''ROSSO'',''NERO'')');
       operatore:= ' IN ';
       SBvalori.Visible:= True;
      end;
   8: operatore:= ' STARTING ';
   9: begin
       operatore:= ' SUBSTRING ';
       MemoEsempio.Lines.Add(' nome = ''VALTER''' );
       MemoEsempio.Lines.Add(' SUBSTRING(nome from 4 for 2)  RESTITUISCE  ''TE'' ');
       Evalore1.Visible:= True;
       Evalore2.Visible:= True;
       Lvalore1.Visible:= True;
       Lvalore2.Visible:= True;
       Lvalore1.Caption:='dalla posizione numero';
       Lvalore2.Caption:='prendo tot Caratteri';
      end;
   10:begin
        Evalore.Text:= '';
        Evalore.Visible:= False;
        operatore:= ' IS NULL ';
      end;
   11:begin
        Evalore.Text:= '';
        Evalore.Visible:= False;
        operatore:= ' IS NOT NULL ';
      end;
  end;
  if CBdata.ItemIndex < 1 then
    campo:= Ecampo.Text;
  MakeEspressione;
end;


procedure TFmwtexpression.CancelButtonClick(Sender: TObject);
begin
  MemoSql.Text:='';
end;



procedure TFmwtexpression.CBdataChange(Sender: TObject);
begin
  case CBdata.ItemIndex of
   1: campo:= 'extract(DAY from ' + Ecampo.Text + ' ) ';
   2: campo:= 'extract(MONTH from ' + Ecampo.Text + ' ) ';
   3: campo:= 'extract(YEAR from ' + Ecampo.Text + ' ) ';
  end;
  Lesempio.Caption:= campo;
  MakeEspressione;
end;

procedure TFmwtexpression.MakeEspressione;
Var
  idx:integer;
begin
  idx:= CBoperatore.ItemIndex;
  if idx in [0..6,8] then
      Lesempio.Caption:= campo + operatore + '''' + Evalore.Text + ''''
  else if  idx = 7 then
    Lesempio.Caption:= campo + ' IN (' + Piuvalori  + ')'
  else if idx = 9 then
      Lesempio.Caption:= 'SUBSTRING(' + campo + ' FROM '  + Evalore1.Text +
                         ' FOR ' + Evalore2.Text + ') = ' + '''' + Evalore.Text + ''''
  else if idx in [10..11] then
      Lesempio.Caption:= campo + operatore;

end;

procedure TFmwtexpression.ImpostazioneIniziale;
begin
  MemoEsempio.Text:='Esempio';
  SBvalori.Visible:= False;
  Evalore1.Visible:= False;
  Evalore2.Visible:= False;
  Lvalore1.Visible:= False;
  Lvalore2.Visible:= False;
  Evalore.Visible:=  True;
end;

function TFmwtexpression.CurrentExpression: string;
begin
  Result:= MemoSql.Text;
end;


procedure TFmwtexpression.EvaloreChange(Sender: TObject);
begin
  MakeEspressione;
end;

procedure TFmwtexpression.FormShortCut(var Msg: TLMKey; var Handled: Boolean);
begin

end;

procedure TFmwtexpression.FormShow(Sender: TObject);
begin
  SBcancelClick(self);
end;


procedure TFmwtexpression.SBcancelClick(Sender: TObject);
begin
  Piuvalori:= '';
  Lesempio.Caption:='';
  MemoSql.Text:='';
  CBdata.ItemIndex:=0;
  CBoperatore.ItemIndex:=-1;
  Lesempio.Caption:='';
  Evalore.Text:='';
  ImpostazioneIniziale;
end;

procedure TFmwtexpression.SBvaloriClick(Sender: TObject);
begin
 if Evalore.Text <> '' then
   begin
     if Piuvalori = '' then
       Piuvalori:=Piuvalori + '''' + Evalore.Text + ''''
     else
       Piuvalori:=Piuvalori + ',''' + Evalore.Text + '''' ;
     Evalore.Text:='';
     Evalore.SetFocus;
   end;
end;

procedure TFmwtexpression.SBandClick(Sender: TObject);
begin
  LogicOperatore:='AND';
  MemoSql.Lines.Add(Lesempio.Caption + ' AND ');
  Evalore.Text:='';
  Evalore.SetFocus;
end;

procedure TFmwtexpression.SBOKClick(Sender: TObject);
begin
//  if LogicOperatore <> '' then
//     MemoSql.Lines.Add('(' + Lesempio.Caption + '))')
//  else
    MemoSql.Lines.Add(Lesempio.Caption);
    MemoSql.Text:= '(' + Trim(MemoSql.Text) + ')';

end;

procedure TFmwtexpression.SBorClick(Sender: TObject);
begin
  LogicOperatore:='OR';
  MemoSql.Lines.Add(Lesempio.Caption + ' OR');
  Evalore.Text:='';
  Evalore.SetFocus;
end;


end.

