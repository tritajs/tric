unit WTimage;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, ExtCtrls, LSystemTrita, Menus;

type

  { TWTimage }

  TWTimage = class(TCustomPanel)
  private
    FAttrib:    TAttrib;
    FHeightMax: integer;
    FMaxSizeKB: integer;
    FReadOnly:  Boolean;

    FPopupMenu: TPopupMenu;
    FWidthMax: Integer;
    procedure SetReadOnly(AValue: Boolean);
    procedure  InserisciImage(Sender: TObject);
    procedure  CancellaImage(Sender: TObject);  //procedura che viene eseguita dal popupmenu
    procedure  ExpandFoto(Sender: TObject);  //procedura che viene eseguita dal popupmenu
    procedure ResizeImage(WrkPicInp:TPicture; var WrkPicOut:TPicture; aWidth, aHeight:Integer);
    { Private declarations }
  protected
    procedure CreateWnd; override;
    { Protected declarations }
  public
    { Public declarations }
    Fimage:       TImage;
    FStream:      TFileStream;
    modificato:   Boolean;
    constructor   Create ( AOwner : TComponent ); override;
    destructor    Destroy; override;
  published
    { Published declarations }
    property ReadOnly:Boolean read FReadOnly write SetReadOnly;
    property MaxSizeKB:integer read FMaxSizeKB Write  FMaxSizeKB;
    property Attrib:TAttrib read FAttrib write FAttrib  default DefaultAattrib;
    property WidthMax:Integer  read FWidthMax write FWidthMax;
    property HeightMax:integer read FHeightMax write FHeightMax;
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property BorderSpacing;
    property BevelInner;
    property BevelOuter;
    property BevelWidth;
    property BidiMode;
    property BorderWidth;
    property BorderStyle;
    property Caption;
    property ChildSizing;
    property ClientHeight;
    property ClientWidth;
    property Color;
    property Constraints;
    property DockSite;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property FullRepaint;
    property ParentBidiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property UseDockManager default True;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDockDrop;
    property OnDockOver;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnGetSiteInfo;
    property OnGetDockCaption;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnResize;
    property OnStartDock;
    property OnStartDrag;
    property OnUnDock;
  end;

procedure Register;

implementation

procedure Register;
begin
  {$I wtimage_icon.lrs}
  RegisterComponents('Trita',[TWTimage]);
end;

{ TWTimage }

constructor TWTimage.Create(AOwner: TComponent);
Var  MenuItem: TMenuItem;
begin
  inherited Create(AOwner);
  FAttrib := DefaultAattrib;
  FAttrib:= FAttrib - [AtFind];
  Fimage := TImage.Create(self);
  Fimage.Parent := self;
  FReadOnly:= False;
  Fimage.Align:= alClient;
  Fimage.Stretch:= True;
  modificato:= False;
  FWidthMax:= 256;
  FHeightMax:= 329;
  FMaxSizeKB:=  15;
  FPopupMenu :=  TPopupMenu.Create(self);

  MenuItem :=    TMenuItem.Create(FPopupMenu);
  MenuItem.Caption:= 'Inserisci Immagine';
  MenuItem.name:= 'Inserisci';
  MenuItem.OnClick:= @InserisciImage;
  FPopupMenu.Items.Add(MenuItem);


  MenuItem :=    TMenuItem.Create(FPopupMenu);
  MenuItem.Caption:= 'Cancella Immagine';
  MenuItem.name:= 'Cancella';
  MenuItem.OnClick:= @CancellaImage;
  FPopupMenu.Items.Add(MenuItem);

  MenuItem :=    TMenuItem.Create(FPopupMenu);
  MenuItem.Caption:= 'Ingransci Immagine';
  MenuItem.name:= 'Ingrandisci';
  MenuItem.OnClick:= @ExpandFoto;

  FPopupMenu.Items.Add(MenuItem);
  Fimage.PopupMenu:= FPopupMenu;
end;

destructor TWTimage.Destroy;
begin
  Fimage.Free;
  FStream.Free;
  inherited Destroy;
end;

procedure TWTimage.CreateWnd;
begin
  inherited CreateWnd;
end;


procedure TWTimage.SetReadOnly(AValue: Boolean);
begin
  if FReadOnly=AValue then Exit;
  FReadOnly:=AValue;
end;

procedure TWTimage.InserisciImage(Sender: TObject);
Var
OD: TOpenDialog;
PicIn,PicOut:TPicture;
begin
  if not FReadOnly then
   begin
      OD:= TOpenDialog.Create(self);
      if OD.Execute then
        try
          begin
            FStream:= TFileStream.Create(OD.FileName, fmOpenRead);
         //   ShowMessage(inttostr(FStream.Size) + '    ' + IntToStr(FMaxSizeKB * 1024));
            if FStream.Size <= (FMaxSizeKB * 1024) then
              begin
                 Fimage.Picture.LoadFromStream(FStream);
                 modificato:= True;
              end
            else
              begin
                 Showmessage('Attenzione le foto devono essere grandi al massimo  ' + IntToStr(FMaxSizeKB)  + ' KB');
                 Fimage.Picture.Clear;
              end;
          end;
        except
          Fimage.Picture.Clear;
       end;
      FreeAndNil(OD);
   end
   else
     Showmessage('Attenzione per inserire o modificare la foto devi prima attivare la modifica o l''inserimento');
end;

//PicIn.LoadFromFile(OD.FileName);
//  ResizeImage(PicIn,PicOut,FWidthMax,FHeightMax);
//Fimage.Picture.Clear;
//Fimage.Picture.Assign(PicOut);
//           Fimage.Picture.LoadFromFile(OD.FileName);

//PicIn:= TPicture.Create;
//PicOut:= TPicture.Create;

//FreeAndNil(PicIn);
//FreeAndNil(PicOut);


procedure TWTimage.CancellaImage(Sender: TObject);
begin
 if not FReadOnly and not Fimage.Picture.Bitmap.Empty then
   begin
      Fimage.Picture.Clear;
      modificato:= True;
   end
 else
  begin
    if Fimage.Picture.Bitmap.Empty then
      Showmessage('Attenzione non è presente nessuna foto')
    else
      Showmessage('Attenzione per cancellare devi prima attivare la modifica');
  end;
end;

procedure TWTimage.ExpandFoto(Sender: TObject);
Var FPrivForm       : TForm;  //TForm;
    FPrivImage: TImage;
    vSize:Double;
    temp:TMemoryStream;
begin
  FPrivForm := TForm.Create(self);
  FPrivForm.BorderIcons:=[biSystemMenu,biMaximize];
  FPrivForm.Position:= poDesktopCenter;
//  FPrivForm.VertScrollBar.Visible:=True;
//  ShowMessage(inttostr(Fimage.Picture.Width) + '  ' + inttostr(Fimage.Picture.Height));
 if (Fimage.Picture.Width > 100) or (Fimage.Picture.Height > 100) then
    begin
      FPrivForm.Width:= Fimage.Picture.Width + 2;
      FPrivForm.Height:= Fimage.Picture.Height + 2;
    end
  else
    begin
      FPrivForm.Width:=  122;
      FPrivForm.Height:= 122;
    end;
  FPrivImage:= TImage.Create(FPrivForm);
  FPrivImage.Parent:= FPrivForm;
  FPrivImage.Align:= alClient;
  FPrivImage.Stretch:= True;
  FPrivImage.Picture.Assign(Fimage.Picture);
  temp:= TMemoryStream.Create;
  FPrivImage.Picture.SaveToStream(temp);
  vSize:= (temp.Size / 1024);
  FPrivForm.Caption:= 'KB  '+ FormatFloat(',.00',vsize) + ' width ' + IntToStr(Fimage.Picture.Width) + ' Heigth ' + IntToStr(Fimage.Picture.Height);
  FPrivForm.ShowModal;
  FPrivImage.Free;
  FPrivForm.Free;
  temp.free;
end;

procedure TWTimage.ResizeImage(WrkPicInp: TPicture; var WrkPicOut: TPicture;
  aWidth, aHeight: Integer);
 var Bmp:TBitmap;
     RectPart, RectDest, RectResized:TRect;
     WrkPropWidth, WrkPropHeight:Integer;
 begin
   //Calcolo i valori che serviranno per ridimensionare l'immagine in larghezza
   if (WrkPicInp.Bitmap.Width > aWidth) then begin
     //Se l'immagine deve essere rimpicciolita ...
     WrkPicOut.Bitmap.Width:=WrkPicInp.Bitmap.Width;
     WrkPropWidth:=Round(WrkPicInp.Bitmap.Width * WrkPicInp.Bitmap.Width / aWidth);
   end else begin
     //Se l'immagine deve essere ingrandita ...
//     WrkPicOut.Bitmap.Width:=aWidth;
//     WrkPropWidth:=Round(WrkPicInp.Bitmap.Width);
   end;

   //Calcolo i valori che serviranno per ridimensionare l'immagine in altezza
   if (WrkPicInp.Bitmap.Height > aHeight) then begin
     //Se l'immagine deve essere rimpicciolita ...
     WrkPicOut.Bitmap.Height:=WrkPicInp.Bitmap.Height;
     WrkPropHeight:=Round(WrkPicInp.Bitmap.Height * WrkPicInp.Bitmap.Height / aHeight);
   end else begin
       //Se l'immagine deve essere ingrandita ...
 //    WrkPicOut.Bitmap.Height:=aHeight;
 //    WrkPropHeight:=Round(WrkPicInp.Bitmap.Height);
   end;

   //Ora che ho tutto ciò che mi serve, posso fare il ridimensionamento vero e proprio
   Bmp:=TBitmap.Create;
   try
     Bmp.Width:=WrkPropWidth;
     Bmp.Height:=WrkPropHeight;
     RectPart:=Rect(0, 0, WrkPicInp.Bitmap.Width, WrkPicInp.Bitmap.Height);
     RectDest:=Rect(0, 0, WrkPicInp.Bitmap.Width, WrkPicInp.Bitmap.Height);
     Bmp.Canvas.CopyRect(RectPart, WrkPicInp.Bitmap.Canvas, RectDest);

     WrkPicOut.Bitmap.SetSize(WrkPicOut.Bitmap.Width, WrkPicOut.Bitmap.Height);
     RectResized:=Rect(0, 0, WrkPicOut.Bitmap.Width, WrkPicOut.Bitmap.Height);
     WrkPicOut.Bitmap.Canvas.StretchDraw(RectResized, Bmp);

     //Se l'immagine è stata rimpicciolita, la parte che eccede le dimensioni finali è tutta nera.
     //Esempio: immagine originale 200 * 200, io ho scelto di farla diventare
     //         50 * 50. A questo punto ho un'immagine di dimensione 200 * 200,
     //         con l'immagine rimpicciolita che occupa i primi 50 * 50 pixel. Il
     //         resto dell'immagine è tutto nero.
     //Faccio in modo di salvare solo la porzione di immagine che serve a me (Nell'esempio
     //qui sopra, 50 * 50)
     RectPart:=Rect(0, 0, aWidth, aHeight);
     RectDest:=RectPart;
     Bmp.Width:=aWidth;
     Bmp.Height:=aHeight;
     Bmp.Canvas.CopyRect(RectPart, WrkPicOut.Bitmap.Canvas, RectDest);
     WrkPicOut.Bitmap.SetSize(aWidth, aHeight);
     WrkPicOut.Bitmap.Assign(Bmp);

     //Rendo trasparente lo sfondo finale dell'immagine, che altrimenti sarebbe nero
     //WrkPicOut.Bitmap.Transparent:=True;
     //WrkPicOut.Bitmap.TransparentMode:=tmFixed;
   finally
     FreeAndNil(Bmp);
   end;
end;



end.