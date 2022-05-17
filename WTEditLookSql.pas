unit WTEditLookSql;

interface

uses
  {$IFDEF FPC}   LCLIntf, LCLType, lMessages, lresources, {$ELSE}   Windows, Variants, {$ENDIF}
   Messages, SysUtils, Classes, Graphics, Controls, Forms,   StdCtrls,
   Dialogs,  LSystemTrita,uibdataset,uib,uiblib;

type

  TListBoxForm = class(TForm)
    ListBox1: TListBox;
    procedure ListBox1KeyPress(Sender: TObject; var Key: Char);
    procedure ListBox1DblClick(Sender: TObject);
//    procedure ListBox1Click(Sender: TObject);
  private
    Risultato:string;
    { Private declarations }
  public

    { Public declarations }
  end;

type
//  TLBDir = (lsLeft, lsRight, lsDown, lsUp);

  { TWTEditLookSql }

  TWTEditLookSql = class(TCustomEdit)
  private
    FIBsql:TUIBQuery ;
    FListBox: TListBoxForm;
  //  FBase: TIBBase;
    FAttrib: TAttrib;
    FSql: String;
    FLookField: String;
    FLookDisplay: String;
    FValueField:string;
    FListBoxWidth:integer;
    //    FLBDir: TLBDir;
    FCaption: string;
    OldValueField:string;
    Ftable: string;
    procedure SetSql(const Value: string);
    function  GetDatabase: TUIBDataBase;
    procedure SetDatabase(Value: TUIBDatabase);
    function  GetTransaction: TUIBTransaction;
    procedure SetTransaction(Value: TUIBTransaction);
    procedure SetLookDisplay(const Value: String);
    procedure SetLookField(const Value: String);
    procedure SetListBoxWidth(const Value: Integer);
    { Private declarations }
  protected
    function  GetValue: String;
    procedure SetValue (Value: String);
    function  FindFieldValue(RecordPos:Integer; FieldName:string):string;
     { Protected declarations }
  public
    Field: String;
    procedure  doEnter; override;
    procedure  change; override;
    procedure  WmChar (var Msg: TWmChar); message wm_Char;

    function FindField(FieldName:string):string;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  published
    { Published declarations }
    property Attrib:TAttrib read FAttrib write FAttrib default DefaultAattrib;
    property Caption: string read FCaption Write FCaption;
    property LookField: String read FLookField Write SetLookField;
    property LookDisplay: String read FLookDisplay Write SetLookDisplay;
    property SQL: string Read Fsql write SetSql;
    property Database: TUIBDatabase read GetDatabase write SetDatabase;
    property Transaction: TUIBTransaction read GetTransaction write SetTransaction;
    property Value: String  read GetValue write SetValue ;
    property ValueLookField: String  read FValueField write FValueField ;
    property ListBoxWidth:Integer read FListBoxWidth write SetListBoxWidth default 200;
    property Table:string read Ftable write Ftable ;
    //    property LBDir:TLBDir read FLBDir write FLBDir;
    property AutoSelect;
    property AutoSize;
    property BorderStyle;
    property CharCase;
    property Color;
    property DragCursor;
    property DragMode;
    property Enabled;
    property Font;
    property HideSelection;
    property MaxLength;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
//    property PasswordChar;
    property PopupMenu;
    property ReadOnly;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnChange;
    property OnClick;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
{    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;}
  end;

procedure Register;
implementation


procedure Register;

begin
  RegisterComponents('Trita', [TWTEditLookSql]);
end;


procedure TWTEditLookSql.change;
begin
  // se il valore del componente è diverso da vuoto
  if OldValueField <> '' then
  // se il valore visualizzato è uguale a vuoto
  if Value = '' then ValueLookField := '';
 inherited;
end;

constructor TWTEditLookSql.Create (AOwner: TComponent);
begin
  inherited Create (Owner);
  text := '';
  FIBsql:= TUIBQuery.Create(self);
  FListBox:= TListBoxForm.Create(Owner);
  FListBox.Width := 200;
  FListBox.Caption :=  Caption;
  FAttrib :=  DefaultAattrib;
  //  FBase := TIBBase.Create(Self);
  end;

destructor TWTEditLookSql.Destroy;
begin
  FIBsql.Free;
  FListBox.Free;
//  FBase.Free;
  inherited Destroy;
end;


procedure TWTEditLookSql.doEnter;
begin
  OldValueField := ValueLookField;
  inherited;
end;


function TWTEditLookSql.FindField(FieldName: string): string;
begin
 Try
  Result:= FIBsql.Fields.ByNameAsString[FieldName];
 except
  ShowMessage('Il campo cercato non è presente nella richiesta sql');
 end;
end;

function TWTEditLookSql.FindFieldValue(RecordPos: Integer;
  FieldName: string): string;
begin
 //incremento di uno RecordPos in quanto la ListBox ha l'indice che inizia per 0
 Inc(RecordPos);
 FIBsql.First;
 while not FIBsql.Eof do
  begin
   if FIBsql.Fields.CurrentRecord = RecordPos then
    begin
     result:= FIBsql.Fields.ByNameAsString[FieldName];
     exit;
    end;
   FIBsql.Next;
  end;
end;

function TWTEditLookSql.GetDatabase: TUIBDataBase;
begin
 result :=  FIBsql.Database;
//  result:= FBase.Database;
end;


function TWTEditLookSql.GetTransaction: TUIBTransaction;
begin
 result :=  FIBsql.Transaction;
//    result := FBase.Transaction;
end;

function TWTEditLookSql.GetValue: String;
begin
  Result := Text;
end;


procedure TWTEditLookSql.SetDatabase(Value: TUIBDatabase);
begin
   FIBsql.Database:= Value;
//   FBase.Database := Value;
end;

procedure TWTEditLookSql.SetListBoxWidth(const Value: Integer);
begin
 FListBoxWidth:= Value;
end;

procedure TWTEditLookSql.SetLookDisplay(const Value: String);
begin
  FLookDisplay := Value;
end;

procedure TWTEditLookSql.SetLookField(const Value: String);
begin
  FLookField := Value;
end;

procedure TWTEditLookSql.SetSql(const Value: string);
 // trova dall'istruzione sql il nome della tabella
 procedure TrovaTable;
    Var PosFrom:integer;
        PosSpace:integer;
        StrDaFrom:string;
    begin
      PosFrom:= Pos('from',Value);
      StrDaFrom:= Copy(Value,PosFrom + 5,30);
      PosSpace:= Pos(' ',StrDaFrom);
      if PosSpace = 0 then
        Table:= StrDaFrom
      else
        Table:= Copy(StrDaFrom,1,PosSpace -1);
  end;
begin
  FIBsql.SQL.Clear;
  TrovaTable;
  FIBsql.SQL.Add(Value);
  Fsql := Value;
end;

procedure TWTEditLookSql.SetTransaction(Value: TUIBTransaction);
begin
  FIBsql.Transaction:= Value;
//  FBase.Transaction := Value;
end;

procedure TWTEditLookSql.SetValue (Value: String);
begin
  Text := Value;
end;

procedure TWTEditLookSql.WmChar (var Msg: TWmChar);
Var
 Key:Char;
begin
 Key:= Char(Msg.CharCode);
 if (Msg.CharCode = 27) then
 begin
  Value:= '';
  ValueLookField:= '';
 end;
 if ((Msg.CharCode = 13) and (readonly = false)) then
  begin
   // controlla l'inserimento del comando SQL
   if SQL <> '' then
    begin
     FIBsql.Close;
     //se esistone dei parametri esegue una ricerca con parametri
     if FIBsql.Params.ParamCount > 0 then
     FIBsql.Params.AsString[0]:= Value;
     // trova la posizione del campo da visualizzare
     FIBsql.Open;
     // se sono statitrovati dei records
     if FIBsql.Fields.RecordCount > 0 then
      begin
        FListBox.ListBox1.Items.Clear;
        while not FIBsql.EOF do
         begin
          FListBox.ListBox1.Items.Add(FIBsql.Fields.ByNameAsString[LookDisplay]);
          FIBsql.Next;
         end;
           FListBox.Width:= Self.Width;        //    Width + ListBoxWidth;
           FListBox.Left:=  Self.Left;
           FListBox.Top:=   Self.Top + Self.Height;
           FListBox.ListBox1.ItemIndex:= 0;
           FListBox.ShowModal;
           if FListBox.Risultato = 'Ok' then
             begin
               ValueLookField:= FindFieldValue(FListBox.ListBox1.ItemIndex,LookField);
               value:= FListBox.ListBox1.Items[FListBox.ListBox1.ItemIndex];
             end;
           if FListBox.Risultato = 'Esc' then
             begin
               value:='';
               ValueLookField:= '';
             end;
           FListBox.close;
           if assigned(OnKeyPress) then OnkeyPress(self,Key);
      end
     else
       ShowMessage('Ricerca Fallita');
    end;
  end
  else
   inherited; //KeyPress(self,Key);
end;



procedure TListBoxForm.ListBox1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13  Then
   begin
    Risultato:= 'Ok';
    close;
   end;
  if Key = #27 Then
   begin
    Risultato:= 'Esc';
    close;
   end;
end;


procedure TListBoxForm.ListBox1DblClick(Sender: TObject);
begin
  Risultato:= 'Ok';
  close;
end;






end.