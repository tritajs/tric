unit WTComboBoxSql;

{$MODE Delphi}

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, StdCtrls, Buttons, Forms, Messages,
  Dialogs, LCLIntf, LCLType, LMessages, Graphics, uib, umEdit, LSystemTrita;



type

  { TWTComboBoxSql }

  TWTComboBoxSql = class(TCustomPanel)
  private
    FEdit	    : TEdit;
    FButton	    : TSpeedButton;
    FOnEnter: TNotifyEvent;
    Fsql            : TStrings;
    FPrivForm       : TForm;  //TForm;
    FListBox 	    : TListBox;
    FIBsql          : TUIBQuery;//     TIBQuery ;
    FValueField     : String;
    FLookField      : String;
    FLookDisplay    : String;
    FonChange: TNotifyEvent;
    FCharCase: TEditCharCase;
    FAttrib: TAttrib;
    FonExit: TNotifyEvent;
    FShowFocusColor: boolean;
    FFocusColor: TColor;
    FEditColor: Tcolor;
    FReadOnly: Boolean;
    procedure EditKeyPress(Sender: TObject; var Key: Char);
    procedure EditingDone(Sender: TObject);
    procedure KeyListBox(Sender: TObject; var Key: Word;Shift: TShiftState);
    procedure ClickButton(Sender: TObject);
    procedure DbClickListBox(Sender: TObject);
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMEnabledChanged(var Message: TMessage); message CM_ENABLEDCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure CMEnter(var Message: TCMEnter); message CM_ENTER;
    procedure CMExit (var Message: TCMExit ); message CM_EXIT;
    procedure FillListBox;
    procedure AutoSize;
    procedure AdjustHeight;
    procedure SetItems(const Value: TStrings);
    procedure ShowList;
    function  GetDatabase: TUIBDataBase;
    function  GetTransaction: TUIBTransaction;
    procedure SetDatabase(const Value: TUIBDataBase);
    procedure SetTransaction(const Value: TUIBTransaction);
    procedure CloseListBox( Sender : TObject );
    function  GetValue: String;
    procedure SetValue(const Value: String);
    procedure SetLookDisplay(const Value: String);
    procedure SetLookField(const Value: String);
    procedure SqlChange(Sender : TObject);
    procedure Change;
    procedure Exit;
    procedure SetCharcase(const Value: TEditCharCase);
    procedure SetReadOnly(const Value: Boolean);
    procedure SetTabella; // trova la tabella nell'istruzione sql
  protected
    procedure CreateWnd; override;
    procedure DoExit; override;
    procedure DoEnter; override;
    function  FindFieldValue(RecordPos:Integer; FieldName:string):string;
  public
    tableCBS        :string; // conterra il nome della tabella
    constructor Create ( AOwner : TComponent ); override;
    destructor  Destroy; override;
    function    FindField(FieldName:string):string;   //restituisce il valore del campo trovato
    procedure   SetFocus;override;
    procedure   UpdateRicerca(field:string); //Riaggiorna la ricerca in base al valore del campo edit
    procedure   UpdatedList; // riesegue la ricerca in base al valore dell'edit

  published
    property  Attrib:TAttrib read FAttrib write FAttrib default DefaultAattrib;
//    property  Table:string read Ftable write Ftable ;
    property  Sql: TStrings          read   Fsql         write SetItems;
    property  Database: TUIBDataBase       read GetDatabase write SetDatabase;
    property  Transaction: TUIBTransaction read GetTransaction write SetTransaction;
    property  Text: String  read GetValue write SetValue ;
    property  ValueLookField: String  read FValueField write FValueField ;
    property  LookField: String   read FLookField   Write SetLookField;
    property  LookDisplay: String read FLookDisplay Write SetLookDisplay;
    property  OnChange: TNotifyEvent read FonChange write FonChange;
    property  OnExit: TNotifyEvent read FonExit write FonExit;
    property  OnEnter:TNotifyEvent read FOnEnter write FOnEnter;
    property  ShowFocusColor:boolean read FShowFocusColor write FShowFocusColor;
    property  FocusColor:TColor read FFocusColor write FFocusColor;
    property  ReadOnly:Boolean read FReadOnly write SetReadOnly default False;

    //    property  Text;

 //   property  Ctl3D;
//    property  Caption;
    property  Cursor;
    property  CharCase: TEditCharCase read FCharCase write SetCharcase;
    property  Enabled;
    property  Font;
    property  ParentColor;
//    property  ParentCtl3D;
    property  ParentFont;
    property  ParentShowHint;
    property  ShowHint;
    property  TabOrder;
    property  TabStop;
    property  Visible;
    property  OnClick;
  //  property  OnExit;
    property  OnMouseDown;
    property  OnMouseMove;
    property  OnMouseUp;
    property  OnResize;
    property  OnStartDrag;
end;

procedure Register;

implementation
//{$R *.RES}
procedure Register;
begin
  RegisterComponents('Trita', [TWTComboBoxSql]);
end;

{ TWTComboBoxSql }

constructor TWTComboBoxSql.Create(AOwner: TComponent);
begin
 	inherited Create( AOwner );
        Alignment:= taCenter;
        BevelOuter:= bvNone;
        BevelInner:= bvNone;
        BorderStyle:= bsNone;
        caption:= '';
	Height		      	   := 20;
	Width 		       	   := 230;
        FAttrib                    :=  DefaultAattrib;
        SetSubComponent(true);
	Fsql   	                   := TStringList.Create;
	TStringList(Fsql).OnChange := SqlChange;

	FEdit	 	           := TEdit.Create(Self);
	FEdit.Parent  	 	   := Self;
	FEdit.ParentColor          := false;
	FEdit.color	     	   := clWhite;
	Fedit.Text		   := '';
        FEdit.OnKeyPress           := EditKeyPress;
        FEdit.OnEditingDone:=EditingDone;
        FEdit.Caption              :='';
     //   FEdit.Left:= left - 2;
        FFocusColor:= $00F7E0D5;
        FShowFocusColor:= True;

      	FButton                    := TSpeedButton.Create(Self);
	with FButton do
	begin
       //  FButton.LoadGlyphFromLazarusResource('dbnavcancel');
         //  Glyph.LoadFromResourceName(HInstance, 'TwEditComp');
	  Parent  	      := Self;
	  FButton.Width	      := 22;
	  FButton.Height      := Self.Height -2 ; //Self.Height-2;
	  FButton.Top	      := Self.Top + 1  ;//Self.Top+2;
	  NumGlyphs 	      := 1;
	  Layout	      := blGlyphRight;
          Caption:= '...';
	  OnClick 	      := ClickButton;
	end;

        FIBsql:=  TUIBQuery.Create(self);            //TIBQuery.Create(Self);
	// Create a form with its contents
	FPrivForm 	    	:= TForm.Create(Nil);
	FPrivForm.Color 	:= clWindow;
        FPrivForm.Caption:= '';
	// Create ListBox
	FListBox                := TListBox.Create( FPrivForm );
	FListBox.Parent         := FPrivForm;
//	FListBox.Columns	:= FColumns;
	FListBox.Align 		:= alClient;
	FListBox.OnKeyDown      := KeyListBox;
        FListBox.OnDblClick     := DbClickListBox;



end;

destructor TWTComboBoxSql.Destroy;
begin
 	FEdit.free;
	FButton.Free;
	FListBox.Free;
	Fsql.Free;
        FPrivForm:= Nil;
        FIBsql.Free;
	inherited Destroy;
end;



procedure TWTComboBoxSql.CreateWnd;
begin
  inherited;
  AutoSize;
  SetTabella;
end;



procedure TWTComboBoxSql.AdjustHeight;
Var
	DC: HDC;
	SaveFont: HFont;
	I: Integer;
	SysMetrics, Metrics: TTextMetric;
begin
        DC := GetDC(0);
	GetTextMetrics(DC, SysMetrics);
	SaveFont := SelectObject(DC, Font.Handle);
	GetTextMetrics(DC, Metrics);
	SelectObject(DC, SaveFont);
	ReleaseDC(0, DC);
	if NewStyleControls then
	begin
		I := 6;
		I := GetSystemMetrics(SM_CYBORDER) * I;
	end else
	begin
		I := SysMetrics.tmHeight;
		if I > Metrics.tmHeight then I := Metrics.tmHeight;
		//I := I div 4 + GetSystemMetrics(SM_CYBORDER) * 4;

                I := I div 4 + GetSystemMetrics(SM_CYBORDER) * 2;

	end;
	Height := Metrics.tmHeight + I;
end;

procedure TWTComboBoxSql.AutoSize;
begin
        AdjustHeight;
 	FButton.Height	:= Height  - 2;//Height-2;
        FEdit.Height	:= Height;
 	FEdit.width	:= Width - FButton.Width-3;
 	FButton.Left	:= FEdit.width + 1;
end;



procedure TWTComboBoxSql.CMEnabledChanged(var Message: TMessage);
begin
 	inherited;
	FButton.Enabled := Enabled;
	FEdit.Enabled   := Enabled;
end;

procedure TWTComboBoxSql.CMFontChanged(var Message: TMessage);
begin
  inherited;
  AutoSize;
  invalidate;
end;



procedure TWTComboBoxSql.SetItems(const Value: TStrings);
begin
// trova dall'istruzione sql il nome della tabella
(* procedure TrovaTable;
    Var PosFrom:integer;
        PosSpace:integer;
        StrDaFrom,st:string;
    begin
      st:= Value.Text;
      // levo eventuali carriege return e line feed
      st := StringReplace(st,#13,' ',[rfReplaceAll]);
      st := StringReplace(st,#10,' ',[rfReplaceAll]);
      PosFrom:= Pos('from',st);
      StrDaFrom:= Copy(st,PosFrom + 5,30);
      PosSpace:= Pos(' ',StrDaFrom);
      if PosSpace = 0 then
        Table:= StrDaFrom
      else
        Table:= Copy(StrDaFrom,1,PosSpace -1);
  end;
begin
  TrovaTable;  *)
  Fsql.Assign(Value);
end;

procedure TWTComboBoxSql.WMSize(var Message: TWMSize);
begin
 	inherited;
	AutoSize;
end;

procedure TWTComboBoxSql.CMEnter(var Message: TCMEnter);
begin
   inherited;
   if FShowFocusColor then
    begin
     FEditColor:= FEdit.Color;
     FEdit.Color := FFocusColor;
    end;
end;

procedure TWTComboBoxSql.CMExit(var Message: TCMExit);
begin
  inherited;
  if FShowFocusColor then
     FEdit.Color := FEditColor;
end;


procedure TWTComboBoxSql.ShowList;
var	ScreenPoint : TPoint;
begin
	if FButton.tag=1 then  // Jan Verhoeven
	begin
		FButton.tag:=0;
		exit
	end;
	// Assign Form coordinate and show
	ScreenPoint    				:= Parent.ClientToScreen( Point( self.Left, self.Top+self.Height ) );
	with FPrivForm do
	begin
		Font 	   			:= self.Font;
		Left  				:= ScreenPoint.X;
		Top   				:= ScreenPoint.Y;
		Width 				:= self.Width;
		BorderStyle 	:= bsNone;
   	OnDeactivate	:= CloseListBox;
	end;
  if FPrivForm.Height + ScreenPoint.y > Screen.Height-20 then
        FPrivForm.Top := ScreenPoint.y-FprivForm.Height-self.height ;
  FListBox.ItemIndex:= 0;
  FPrivForm.ShowModal;
end;

function TWTComboBoxSql.GetDatabase: TUIBDataBase;
begin
 result :=  FIBsql.Database;
end;

function TWTComboBoxSql.GetTransaction: TUIBTransaction;
begin
 result :=  FIBsql.Transaction;
end;

procedure TWTComboBoxSql.SetDatabase(const Value: TUIBDataBase);
begin
 FIBsql.Database:= Value;
end;

procedure TWTComboBoxSql.SetTransaction(const Value: TUIBTransaction);
begin
 FIBsql.Transaction:= Value;
end;

procedure TWTComboBoxSql.CloseListBox(Sender: TObject);
var pt:TPoint;
begin
// code added by Jan Verhoeven
// check if the mouse is over the combobox button
//	pt:=mouse.CursorPos;
//  this doesn't work on delphi 3
	GetCursorPos(pt);
	pt:=FButton.ScreenToClient(pt);
	with Fbutton do
	begin
		if (pt.x>0) and (pt.x<width) and (pt.y>0) and (pt.y<height)
			then tag:=1
			else tag:=0
	end;
	FPrivForm.Close;
end;

function TWTComboBoxSql.GetValue: String;
begin
 result := FEdit.Text;
end;

procedure TWTComboBoxSql.SetValue(const Value: String);
begin
 FEdit.Text := Value;
end;

procedure TWTComboBoxSql.SetLookDisplay(const Value: String);
begin
  FLookDisplay := Value;
end;

procedure TWTComboBoxSql.SetLookField(const Value: String);
begin
  FLookField := Value;
end;

procedure TWTComboBoxSql.SqlChange(Sender: TObject);
begin
 FIBsql.SQL.Assign(Fsql);
 SetTabella;
end;

procedure TWTComboBoxSql.KeyListBox(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 if key = VK_ESCAPE then
   begin
    text:='';
    ValueLookField:= '';
    Change;
    FPrivForm.Close;
   end
 else if key = VK_RETURN then
   begin
     ValueLookField:= FindFieldValue(FListBox.ItemIndex,LookField);
     text:= FListBox.Items[FListBox.ItemIndex];
    // Change;
     FPrivForm.Close;
     //Exit;
   end
  else if (key in [65..90]) or (key in [97..122]) then
   begin
    FPrivForm.Close;
    FEdit.Text:= Chr(key);
    FEdit.SelStart:= 1;
    FEdit.SetFocus;
   end
  else
    inherited;
end;

function TWTComboBoxSql.FindFieldValue(RecordPos: Integer;
  FieldName: string): string;
begin
 //incremento di uno RecordPos in quanto la ListBox ha l'indice che inizia per 0
// Inc(RecordPos);
 FIBsql.Open;
 while not FIBsql.Eof do
  begin
   if FIBsql.Fields.CurrentRecord = RecordPos then
    begin
     result:= FIBsql.Fields.ByNameAsString[FieldName];
     Break;
    end;
   FIBsql.Next;
  end;
end;

procedure TWTComboBoxSql.FillListBox;
begin
 // controlla l'inserimento del comando SQL
 if FIBsql.SQL.Text <> '' then
  begin
   FListBox.Items.Clear;
   FIBsql.Close;
   //se esistone dei parametri esegue una ricerca con parametri
   if FIBsql.Params.FieldCount > 0 then FIBsql.Params.AsString[0]:= text;
   // trova la posizione del campo da visualizzare
   FIBsql.Open;
   // se sono statitrovati dei records
   if FIBsql.Fields.RecordCount > 0 then
    begin
      while not FIBsql.EOF do
       begin
        FListBox.Items.Add(FIBsql.Fields.ByNameAsString[LookDisplay]);
        FIBsql.Next;
       end;
     // controlla s'è stato trovato solo un record
     if FListBox.Count > 1 then
       ShowList
     else
       begin
         ValueLookField:= FIBsql.Fields.ByNameAsString[LookField];
         text:= FIBsql.Fields.ByNameAsString[LookDisplay];
//         Parent.Perform(CM_DIALOGKEY, VK_TAB, 0);
         Change;
   //      Exit;
       end
    end
   else
    begin
      ShowMessage('Dato Non Presente In Archivio');
      Text:='';
    end;

  end;
end;

procedure TWTComboBoxSql.EditKeyPress(Sender: TObject; var Key: Char);
begin
if (Key = #27) then
 begin
  Text:='';
  ValueLookField:= '';
  Change;
 end
 else if ((Key = #13) and not (FReadOnly)) then
  begin
   FillListBox;
   Change;
   key := #0;
   //Parent.Perform(CM_DIALOGKEY, VK_TAB, 0);
  end
 else
  ValueLookField:= ''; // ogni volta che inserisco un carattere cancello il valore
                       // contenuto in valuelookfield
end;

procedure TWTComboBoxSql.EditingDone(Sender: TObject);
begin
  DoExit;
end;


procedure TWTComboBoxSql.ClickButton(Sender: TObject);
begin
 if FPrivForm.Active then
      FPrivForm.Close;
  if not FReadOnly then
   begin
     FEdit.Text:= '';
     FillListBox;
   end;
end;

procedure TWTComboBoxSql.Change;
begin
 if Assigned(FOnChange) then OnChange(Self);
end;

procedure TWTComboBoxSql.Exit;
begin
 if Assigned(FOnExit) then OnExit(Self);
end;


procedure TWTComboBoxSql.DbClickListBox(Sender: TObject);
begin
 ValueLookField:= FindFieldValue(FListBox.ItemIndex,LookField);
 text:= FListBox.Items[FListBox.ItemIndex];
 Change;
 FPrivForm.Close;
end;

procedure TWTComboBoxSql.SetCharcase(const Value: TEditCharCase);
begin
  if FCharCase <> Value then
   begin
    FCharCase := Value;
    FEdit.CharCase:= Value;
   end;
end;

function TWTComboBoxSql.FindField(FieldName: string): string;
begin
   Try
    if Text <> '' then // se nel campo edit del CB c'è un valore lo ricerco
      Result:=  Trim(FIBsql.Fields.ByNameAsString[FieldName])
    else
      Result:= '';
   except
    ShowMessage('Il campo cercato non è presente nella richiesta sql');
   end;
end;

procedure TWTComboBoxSql.DoExit;
begin
  // se hai inserito una stringa e utilizzi il tasto tab per uscire, ricerco il dato inserito
  if ((ValueLookField = '') and (Text <> '') and not (FReadOnly)) then
   begin
     // Controllo se il dato in uscita è un dato contenente in archivio
     FillListBox;
     if (ValueLookField = '') and (FListBox.Count = 0) then
       FEdit.SetFocus;
   end;
  exit;
  inherited ;
end;

procedure TWTComboBoxSql.DoEnter;
begin
 if Assigned(FOnEnter) then OnEnter(Self);
  inherited DoEnter;
end;


// se esiste un valore nel campo edit lo ricerca automaticamente
procedure TWTComboBoxSql.UpdateRicerca(field:string);
begin
  FEdit.Text := field;
   FIBsql.Close;
   //se esistone dei parametri esegue una ricerca con parametri
   if FIBsql.Params.FieldCount > 0 then FIBsql.Params.AsString[0]:= field;
   // trova la posizione del campo da visualizzare
      FIBsql.Open;
      if FIBsql.Fields.RecordCount > 0 then
        begin
          ValueLookField:= FIBsql.Fields.ByNameAsString[LookField];
          Text:= FIBsql.Fields.ByNameAsString[LookDisplay];
          Change;
        end;
end;

//effettuo una nuova ricerca con il valorere dell'edit
procedure TWTComboBoxSql.UpdatedList;
begin
  FillListBox;
end;


procedure TWTComboBoxSql.SetFocus;
begin
  inherited;
  if Focused then   FEdit.SetFocus;

end;


procedure TWTComboBoxSql.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
  FEdit.ReadOnly:= Value;
end;

procedure TWTComboBoxSql.SetTabella;
Var posFrom,x:integer;
    st:string;
begin
 st:= UpperCase(Sql.Text);
 if st <> '' then
  begin
   posFrom:= Pos('FROM',st);
   if posFrom > 0 then
     begin
        st:= Trim(Copy(st,posFrom + 5,100));
        x:= 1;
        tableCBS:='';
        repeat
          tableCBS:= tableCBS + st[x];
          Inc(x);
        until (st[x] = ' ') or (Length(st)+1 = x);
     end;
  end;
end;

end.
