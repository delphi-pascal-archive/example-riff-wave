unit Main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, RIFF, Wave;

type
  TMainForm = class(TForm)
    HeaderLbl: TLabel;
    BrowseBtn: TButton;
    WaveEdit: TEdit;
    OpenDlg: TOpenDialog;
    PlayBtn: TButton;
    StopBtn: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button3Click(Sender: TObject);
    procedure BrowseBtnClick(Sender: TObject);
    procedure PlayBtnClick(Sender: TObject);
    procedure StopBtnClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  MainForm: TMainForm;
  W: TWave;

implementation

{$R *.dfm}

{ Permet de convertir un code d'erreur en texte français, ne fait pas partie du format RIFF }
function WaveError(Error: Longword): String;
begin
 case Error of
  RIFF_SUCCESS: Result := 'Succès';
  RIFF_UNKNOWN_ERROR: Result := 'Erreur inconnue';
  RIFF_CANNOT_OPEN: Result := 'Le fichier n''a pas pu être ouvert';
  RIFF_CANNOT_MAP: Result := 'Le fichier n''a pas pu être mappé en mémoire';
  RIFF_CANNOT_VIEW: Result := 'Le fichier n''a pas pu être lu depuis la mémoire';
  RIFF_INVALID_FORMAT: Result := 'Le format du fichier est invalide';
  RIFF_CHUNK_NOTFOUND: Result := 'Le fichier n''est pas un fichier WAVE valide';
  else Result := 'Erreur inconnue';
 end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if Assigned(W) then W.Free;
end;

procedure TMainForm.Button3Click(Sender: TObject);
begin
 W.Stop;
end;

procedure TMainForm.BrowseBtnClick(Sender: TObject);
begin
 if OpenDlg.Execute then
  begin
   if Assigned(W) then W.Free;
   WaveEdit.Text := '';
   W := TWave.Create(OpenDlg.FileName);
   if W.Error = RIFF_SUCCESS then MessageDlg('File succesfully opened!', mtInformation, [mbOK], 0)
    else raise Exception.Create(Format('Is Error occured: %s.', [WaveError(W.Error)]));
   WaveEdit.Text := ExtractFileName(OpenDlg.FileName);
  end;
end;

procedure TMainForm.PlayBtnClick(Sender: TObject);
begin
 if not Assigned(W) then raise Exception.Create('Vous n''avez pas encore choisi de fichier !');

 W.Play;
end;

procedure TMainForm.StopBtnClick(Sender: TObject);
begin
 if not Assigned(W) then raise Exception.Create('Vous n''avez pas encore choisi de fichier !');

 W.Stop;
end;

end.
