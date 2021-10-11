{ Cette unité permet de lire un fichier wav (WAVE). La classe TWave s'appuie
  elle-même sur la classe TRIFF pour extraire les informations du fichier,
  puis les envoie au pilote multimédia pour la lecture.

  Auteur : Bacterius

}

unit Wave;

interface

uses MMSystem, RIFF;

type
 TWave = class
 private
  FHOut: Longword;
  FRIFF: TRIFF;
  FHeader: PWAVEFORMATEX;
  FHeaderSize: Longword;
  FHdr: WAVEHDR;
  function GetError: Longword;
 public
  constructor Create(const FilePath: String); reintroduce;
  destructor Destroy; override;
  procedure Play;
  procedure Stop;
  property Error: Longword read GetError;
 end;

implementation

{ Création de l'objet WAVE }
constructor TWave.Create(const FilePath: String);
begin
 inherited Create;
 { On crée l'objet RIFF associé au fichier WAVE }
 FRIFF := TRIFF.Create(FilePath);
 { On extrait le format du fichier WAVE (identificateur "fmt ") }
 FHeader := FRIFF.GetChunk('fmt ', FHeaderSize);
 { On ouvre un périphérique audio de sortie avec ce format }
 waveOutOpen(@FHOut, WAVE_MAPPER, FHeader, 0, 0, 0);
 { On remplit le header WAVE }
 FHdr.lpData := FRIFF.GetChunk('data', FHdr.dwBufferLength);
 FHdr.dwBytesRecorded := FHdr.dwBufferLength;
 FHdr.dwFlags := 0;
 { On prépare ce header avec la fonction eponyme }
 waveOutPrepareHeader(FHOut, @FHdr, SizeOf(FHdr));
end;

{ Lecture du fichier WAVE }
procedure TWave.Play;
begin
 { On arrête tout }
 Stop;
 { Puis on envoie le fichier au pilote multimédia }
 waveOutWrite(FHOut, @FHdr, SizeOf(FHdr));
end;

{ Arrêt de la lecture }
procedure TWave.Stop;
begin
 { Ceci arrête tout le son sur notre périphérique }
 waveOutReset(FHOut);
end;

{ Libération de l'objet WAVE }
destructor TWave.Destroy;
begin
 { On arrête la lecture }
 Stop;
 { On "déprépare" le header, c'est important }
 waveOutUnprepareHeader(FHOut, @FHdr, SizeOf(FHdr));
 { On ferme le périphérique audio de sortie }
 waveOutClose(FHOut);
 { On libère l'objet RIFF }
 FRIFF.Free;
 inherited Destroy;
end;

{ Récupération du code d'erreur RIFF }
function TWave.GetError: Longword;
begin
 Result := FRIFF.RIFFError;
end;

end.
