unit WTNavigator;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ComCtrls, wteditcompNew, db;

type

  { TWTNavigator }
  TNavButtonType = (nbtFirst, nbtPrior, nbtNext, nbtLast,
                  nbtInsert, nbtDelete, nbtEdit, nbtPost, nbtCancel, nbtRefresh, nbtFind);
  TNavButtonSet = set of TNavButtonType;
  TNavClickEvent = procedure(Sender: TObject; Button: TNavButtonType) of object;
//  TNavBeforeClickEvent = procedure(Sender: TObject; Var Button: TNavButtonType; Var EseguiPost: Boolean = True) of object;
  TNavBeforeClickEvent = procedure(Sender: TObject; Var Button: TNavButtonType; Var EseguiPost: Boolean) of object;


const
   DefaultNavigatorButtons = [nbtFirst, nbtPrior, nbtNext, nbtLast,
   nbtInsert, nbtDelete, nbtEdit, nbtPost, nbtCancel, nbtRefresh, nbtFind];
   ButtonsShowHint: array[TNavButtonType] of string = (
 { nbtFirst   } 'Primo',
 { nbtPrior   } 'Precedente',
 { nbtNext    } 'Successivo',
 { nbtLast    } 'Ultimo',
 { nbtInsert  } 'Inserimento',
 { nbtDelete  } 'Cancellazione',
 { nbtEdit    } 'Modifica',
 { nbtPost    } 'Conferma',
 { nbtCancel  } 'Annulla',
 { nbtRefresh } 'Refresh',
 { nbtFind    } 'Ricerca');
type

  TWTNavigator = class(TToolBar)
  private
     FEditCompNew: TwtEditCompNew;
     FImageList: TImageList;
     FOnNavBeforeClick: TNavBeforeClickEvent;
     FOnNavClick: TNavClickEvent;
     FVisibleButtons: TNavButtonSet;
     procedure LoadImages;
     procedure UpdateButtons;
     procedure SetEditNewComp(AValue: TwtEditCompNew);
     procedure NewBtnClick(Sender: TObject);  //procedura che viene eseguita dal popupmenu
     procedure SetVisibleButtons(AValue: TNavButtonSet);
     function  StrToEnum(st:string):TNavButtonType;
     function  EnumToStr(st:TNavButtonType):string;

     { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
     constructor  Create ( AOwner : TComponent ); override;
     procedure    CreateWnd; override;
     destructor   Destroy; override;
     procedure    DoClick(Button: TNavButtonType);
//     procedure    DoBeforeClick(var Button: TNavButtonType; Var EseguiPost: Boolean = True);
     procedure    DoBeforeClick(var Button: TNavButtonType; Var EseguiPost: Boolean);

     procedure    stato (stato:TDataSetState);
     procedure    ActiveButton(Tasto:string);
     procedure EnableButtons;
  published
    { Published declarations }
     property     EditCompNew:TwtEditCompNew read FEditCompNew write SetEditNewComp;
     property     VisibleButtons: TNavButtonSet read FVisibleButtons
                             write SetVisibleButtons default DefaultNavigatorButtons;
     property     OnClick: TNavClickEvent read FOnNavClick write FOnNavClick;
     property     OnBeforeClick: TNavBeforeClickEvent read FOnNavBeforeClick write FOnNavBeforeClick;
  end;


procedure Register;




implementation
(*TDataSetState = (dsInactive, dsBrowse, dsEdit, dsInsert, dsSetKey,
   dsCalcFields, dsFilter, dsNewValue, dsOldValue, dsCurValue, dsBlockRead,
   dsInternalCalc, dsOpening) *)

procedure Register;
begin
  RegisterComponents('Trita',[TWTNavigator]);
end;

{ TWTNavigator }


constructor TWTNavigator.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Align:= alNone;
  Flat:=True;
  ShowHint:=True;
  AutoSize:=True;
  EdgeBorders:=[];
  FImageList:= TImageList.Create(self);
  Images:=FImageList;
  LoadImages;
  FVisibleButtons:=DefaultNavigatorButtons;
  UpdateButtons;
end;

procedure TWTNavigator.CreateWnd;
begin
  inherited CreateWnd;
  if assigned(FEditCompNew) then
    begin
      FEditCompNew.Clear_Edit;
      FEditCompNew.ReadOnlyEdit(True);
      FEditCompNew.stato:= dsInactive;
      EnableButtons;  // in base alla variabile stato abilito determinati bottoni
    end
  else
    begin
      ShowMessage('Attenzione non hai associato l''oggetto EditCompNew');
    end;
end;

destructor TWTNavigator.Destroy;
begin
  inherited Destroy;
 // FImageList.free;
end;

procedure TWTNavigator.DoClick(Button: TNavButtonType);
begin
  if Assigned(FOnNavClick) then
     FOnNavClick(Self,Button);
end;

procedure TWTNavigator.DoBeforeClick(var Button: TNavButtonType;
  var EseguiPost: Boolean);
begin
   if Assigned(FOnNavBeforeClick) then
     FOnNavBeforeClick(Self,Button,EseguiPost);
end;


//permette di abilitari i bottoni in base all'operazione che si vuole svolgere su db
procedure TWTNavigator.stato(stato: TDataSetState);
begin
  FEditCompNew.stato:= stato;
  EnableButtons;
  if stato in [dsEdit, dsInsert] then
     FEditCompNew.ReadOnlyEdit(False);
end;

procedure TWTNavigator.ActiveButton(Tasto:string);
Var button:TObject;
begin
 button:= self.FindChildControl(Tasto);
 NewBtnClick(button);
end;

procedure TWTNavigator.LoadImages;
begin
  FImageList.AddLazarusResource('DBNavFirst');
  FImageList.AddLazarusResource('DBNavPrior');
  FImageList.AddLazarusResource('DBNavNext');
  FImageList.AddLazarusResource('DBNavLast');
  FImageList.AddLazarusResource('DBNavInsert');
  FImageList.AddLazarusResource('DBNavDelete');
  FImageList.AddLazarusResource('DBNavEdit');
  FImageList.AddLazarusResource('DBNavPost');
  FImageList.AddLazarusResource('DBNavCancel');
  FImageList.AddLazarusResource('DBNavRefresh');
  FImageList.AddLazarusResource('DBNavFind');
end;

procedure TWTNavigator.UpdateButtons;
var
  newbtn: TToolButton;
  lastbtnidx: integer;
  CurButtonType: TNavButtonType;
begin
  for CurButtonType := Low(TNavButtonType) to High(TNavButtonType) do
   begin
     newbtn :=  TToolButton.Create(Self);
     newbtn.Name:=ButtonsShowHint[CurButtonType];
     lastbtnidx := ButtonCount - 1;
     if lastbtnidx > -1 then
       newbtn.Left := Buttons[lastbtnidx].Left + Buttons[lastbtnidx].Width
     else
       newbtn.Left := 0;
     newbtn.ImageIndex:= Ord(CurButtonType);
  //   newbtn.Enabled:=False;
     newbtn.Hint:= ButtonsShowHint[CurButtonType];
     newbtn.Parent := Self;
     newbtn.OnClick:= @NewBtnClick;
  end;

end;

procedure TWTNavigator.SetEditNewComp(AValue: TwtEditCompNew);
begin
  if FEditCompNew=AValue then Exit;
     FEditCompNew:=AValue;
end;

procedure TWTNavigator.NewBtnClick(Sender: TObject);
Var NomeBottone:string;
    StatoBefore, StatoTemp:TDataSetState;
    TempBottone: TNavButtonType;
    EseguiPost: Boolean;
procedure CheckButton;
   begin
     FEditCompNew.stato:= dsBrowse;
     Buttons[Ord(nbtFirst)].Enabled:=  True;
     Buttons[Ord(nbtPrior)].Enabled:=  True;
     Buttons[Ord(nbtNext)].Enabled:=   True;
     Buttons[Ord(nbtLast)].Enabled:=   True;
     if FEditCompNew.DataSet.EOF then
       begin
         Buttons[Ord(nbtNext)].Enabled:=   False;
         Buttons[Ord(nbtLast)].Enabled:=   False;
        end;
     if FEditCompNew.DataSet.BOF then
       begin
         Buttons[Ord(nbtFirst)].Enabled:=  False;
         Buttons[Ord(nbtPrior)].Enabled:=  False;
       end;
   end;
begin
 StatoBefore :=  FEditCompNew.stato;
 NomeBottone:= TToolButton(Sender).Name;
 TempBottone := StrToEnum(NomeBottone);
 EseguiPost:= True;
 DoBeforeClick(TempBottone, EseguiPost);
 if Not EseguiPost then
    exit;
 NomeBottone:= EnumToStr(TempBottone);

 if NomeBottone = 'Primo' then
   begin
     FEditCompNew.First;
     CheckButton;
   end
 else if NomeBottone = 'Precedente' then
   begin
     FEditCompNew.Prior;
     CheckButton;
   end
 else if NomeBottone = 'Successivo' then
    begin
      FEditCompNew.Next;
      CheckButton;
    end
 else if NomeBottone = 'Ultimo' then
    begin
      FEditCompNew.Last;
      CheckButton;
    end
 else if NomeBottone = 'Inserimento' then
    begin
      FEditCompNew.stato:= dsInsert;
      EnableButtons;
      FEditCompNew.Clear_Edit;
      FEditCompNew.ReadOnlyEdit(False);
    end
 else if NomeBottone = 'Cancellazione' then
    begin
      if MessageDlg('Confermi la cancellazione di ', mtConfirmation, [mbYes, mbNo], 0) = mrYes then
        begin
          FEditCompNew.stato:= dsInactive;
          FEditCompNew.Delete;
          EnableButtons;
          FEditCompNew.Clear_Edit;
          FEditCompNew.ReadOnlyEdit(False);
        end;
    end
 else if NomeBottone = 'Modifica' then
    begin
      FEditCompNew.stato:= dsEdit;
      EnableButtons;
      FEditCompNew.ReadOnlyEdit(False);
    end
 else if NomeBottone = 'Conferma' then
    begin
      FEditCompNew.ReadOnlyEdit(True);
      case FEditCompNew.stato of
        dsFilter:
          begin
            FEditCompNew.Find;
            if FEditCompNew.Found then
              begin
               FEditCompNew.stato:= dsBrowse;
               EnableButtons;
               if FEditCompNew.DataSet.RecordCount= 1 then //se il record trovato è uno solo disabilito i tasti di navigazione
                 begin
                      Buttons[Ord(nbtFirst)].Enabled:=  False;
                      Buttons[Ord(nbtPrior)].Enabled:=  False;
                      Buttons[Ord(nbtNext)].Enabled:=   False;
                      Buttons[Ord(nbtLast)].Enabled:=   False;
                 end;
              end
            else
              begin
                FEditCompNew.stato := dsInactive;
                EnableButtons;
              end;
          end;
        dsInsert:
          begin
            try
               FEditCompNew.Insert;
               FEditCompNew.stato:= dsBrowse;
               EnableButtons;
               FEditCompNew.Refresh;
            except
               on E: Exception do
                 begin
                   FEditCompNew.ReadOnlyEdit(False);
                   NomeBottone:= 'Refresh';
                   ShowMessage(E.Message);
                 end;
            end;
          end;
        dsEdit:
         begin
          try
             FEditCompNew.Update;
             FEditCompNew.stato:= dsBrowse;
             EnableButtons;
             FEditCompNew.Refresh;
          except
             on E: Exception do
               begin
                ShowMessage(E.Message);
                FEditCompNew.ReadOnlyEdit(False);
                NomeBottone:= 'Refresh';
               end;
          end;
         end;
      end;
    end
 else if NomeBottone = 'Annulla' then
    begin
      FEditCompNew.ReadOnlyEdit(True); // rendo gli edit in sola lettura
      case FEditCompNew.stato of
       dsEdit:
        begin
          FEditCompNew.SayDati;
          FEditCompNew.stato:= dsBrowse;
        end;
       dsInsert,dsFilter:
        begin
          FEditCompNew.stato:= dsInactive;
          FEditCompNew.Clear_Edit;
        end;
      end;
      EnableButtons;
    end
 else if NomeBottone = 'Refresh' then
   begin
     FEditCompNew.stato:= dsBrowse;
     FEditCompNew.SayDati;
     FEditCompNew.ReadOnlyEdit(True);
     EnableButtons;
   end
 else if NomeBottone = 'Ricerca' then
    begin
      FEditCompNew.stato := dsFilter;
      EnableButtons;
      FEditCompNew.Clear_Edit;
      FEditCompNew.contatore:='';
      FEditCompNew.DoContatore;
      FEditCompNew.ReadOnlyEdit(False);
      FEditCompNew.Close; // chiude il dataset
    end;
 StatoTemp:= FEditCompNew.stato;     //qteste variabli StatoTemp e StatoBefore servone per eseguire evento OnClick con il valore di stasto prima della pressione di untasto
 FEditCompNew.stato:= StatoBefore;
 DoClick(StrToEnum(NomeBottone));
 FEditCompNew.stato:= StatoTemp;
 FEditCompNew.DoStato;
end;

procedure TWTNavigator.EnableButtons;
begin
  Buttons[Ord(nbtFirst)].Enabled:=  False;
  Buttons[Ord(nbtPrior)].Enabled:=  False;
  Buttons[Ord(nbtNext)].Enabled:=   False;
  Buttons[Ord(nbtLast)].Enabled:=   False;
  Buttons[Ord(nbtInsert)].Enabled:= False;
  Buttons[Ord(nbtDelete)].Enabled:= False;
  Buttons[Ord(nbtEdit)].Enabled:=   False;
  Buttons[Ord(nbtPost)].Enabled:=   False;
  Buttons[Ord(nbtCancel)].Enabled:= False;
  Buttons[Ord(nbtRefresh)].Enabled:=False;
  Buttons[Ord(nbtFind)].Enabled:=   False;
  case FEditCompNew.stato of
    dsInactive:
     begin
       Buttons[Ord(nbtInsert)].Enabled:= True;
       Buttons[Ord(nbtFind)].Enabled:=   True;
     end;
    dsBrowse:
     begin
       Buttons[Ord(nbtFirst)].Enabled:=  True;
       Buttons[Ord(nbtPrior)].Enabled:=  True;
       Buttons[Ord(nbtNext)].Enabled:=   True;
       Buttons[Ord(nbtLast)].Enabled:=   True;
       Buttons[Ord(nbtInsert)].Enabled:= True;
       Buttons[Ord(nbtDelete)].Enabled:= True;
       Buttons[Ord(nbtEdit)].Enabled:=   True;
       Buttons[Ord(nbtPost)].Enabled:=   False;
       Buttons[Ord(nbtCancel)].Enabled:= True;
       Buttons[Ord(nbtRefresh)].Enabled:=True;
       Buttons[Ord(nbtFind)].Enabled:=   True;
     end;
    dsFilter,dsInsert:
     begin
      Buttons[Ord(nbtPost)].Enabled:=   True;
      Buttons[Ord(nbtCancel)].Enabled:= True;
     end;
    dsEdit:
     begin
       Buttons[Ord(nbtPost)].Enabled:=   True;
       Buttons[Ord(nbtCancel)].Enabled:= True;
       Buttons[Ord(nbtRefresh)].Enabled:= True;
     end;
  end;
end;

procedure TWTNavigator.SetVisibleButtons(AValue: TNavButtonSet);
var
  CurButton: TNavButtonType;
begin
  if FVisibleButtons=AValue then Exit;
  FVisibleButtons:=AValue;
   for CurButton:=Low(TNavButtonType) to High(TNavButtonType) do
  begin
    Buttons[Ord(CurButton)].Visible:=CurButton in FVisibleButtons;
  end;
end;

function TWTNavigator.StrToEnum(st: string): TNavButtonType;
begin
  if st = 'Primo'         then Result := nbtFirst;
  if st = 'Precedente'    then Result := nbtPrior;
  if st = 'Successivo'    then Result := nbtNext;
  if st = 'Ultimo'        then Result := nbtLast;
  if st = 'Inserimento'   then Result := nbtInsert;
  if st = 'Cancellazione' then Result := nbtDelete;
  if st = 'Modifica'      then Result := nbtEdit;
  if st = 'Conferma'      then Result := nbtPost;
  if st = 'Annulla'       then Result := nbtCancel;
  if st = 'Refresh'       then Result := nbtRefresh;
  if st = 'Ricerca'       then Result := nbtFind;
end;

function TWTNavigator.EnumToStr(st: TNavButtonType): string;
begin
  if st = nbtFirst        then Result := 'Primo';
  if st = nbtPrior        then Result := 'Precedente';
  if st = nbtNext         then Result := 'Successivo';
  if st = nbtLast         then Result := 'Ultimo';
  if st = nbtInsert       then Result := 'Inserimento' ;
  if st = nbtDelete       then Result := 'Cancellazione';
  if st = nbtEdit         then Result := 'Modifica';
  if st = nbtPost         then Result := 'Conferma';
  if st = nbtCancel       then Result := 'Annulla';
  if st = nbtRefresh      then Result := 'Refresh';
  if st = nbtFind         then Result := 'Ricerca';

end;

initialization
 {$I wtnavigatorimages.lrs}
end.
