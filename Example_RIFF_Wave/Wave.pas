{ Cette unit� permet de lire un fichier wav (WAVE). La classe TWave s'appuie
  elle-m�me sur la classe TRIFF pour extraire les informations du fichier,
  puis les envoie au pilote multim�dia pour la lecture.

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

{ Cr�ation de l'objet WAVE }
constructor TWave.Create(const FilePath: String);
begin
 inherited Create;
 { On cr�e l'objet RIFF associ� au fichier WAVE }
 FRIFF := TRIFF.Create(FilePath);
 { On extrait le format du fichier WAVE (identificateur "fmt ") }
 FHeader := FRIFF.GetChunk('fmt ', FHeaderSize);
 { On ouvre un p�riph�rique audio de sortie avec ce format }
 waveOutOpen(@FHOut, WAVE_MAPPER, FHeader, 0, 0, 0);
 { On remplit le header WAVE }
 FHdr.lpData := FRIFF.GetChunk('data', FHdr.dwBufferLength);
 FHdr.dwBytesRecorded := FHdr.dwBufferLength;
 FHdr.dwFlags := 0;
 { On pr�pare ce header avec la fonction eponyme }
 waveOutPrepareHeader(FHOut, @FHdr, SizeOf(FHdr));
end;

{ Lecture du fichier WAVE }
procedure TWave.Play;
begin
 { On arr�te tout }
 Stop;
 { Puis on envoie le fichier au pilote multim�dia }
 waveOutWrite(FHOut, @FHdr, SizeOf(FHdr));
end;

{ Arr�t de la lecture }
procedure TWave.Stop;
begin
 { Ceci arr�te tout le son sur notre p�riph�rique }
 waveOutReset(FHOut);
end;

{ Lib�ration de l'objet WAVE }
destructor TWave.Destroy;
begin
 { On arr�te la lecture }
 Stop;
 { On "d�pr�pare" le header, c'est important }
 waveOutUnprepareHeader(FHOut, @FHdr, SizeOf(FHdr));
 { On ferme le p�riph�rique audio de sortie }
 waveOutClose(FHOut);
 { On lib�re l'objet RIFF }
 FRIFF.Free;
 inherited Destroy;
end;

{ R�cup�ration du code d'erreur RIFF }
function TWave.GetError: Longword;
begin
 Result := FRIFF.RIFFError;
end;

end.
