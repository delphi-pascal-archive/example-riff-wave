{ Cette unité permet de lire un fichier multimédia RIFF. Le fichier est mappé
  en mémoire, est identifié comme étant bien au format RIFF, puis la fonction
  GetChunk permet de récupérer l'adresse de début et la taille de n'importe-
  quelle section du fichier RIFF.

  Auteur : Bacterius

}

unit RIFF;

interface

uses Windows;

const
 { Les constantes d'erreur, récupérées dans RIFFError }
 RIFF_SUCCESS        = 0; { No error occured }
 RIFF_UNKNOWN_ERROR  = 1; { An unknown error occured }
 RIFF_CANNOT_OPEN    = 2; { The RIFF file couldn't be opened }
 RIFF_CANNOT_MAP     = 3; { The RIFF file couldn't be mapped }
 RIFF_CANNOT_VIEW    = 4; { The RIFF file couldn't be viewed }
 RIFF_INVALID_FORMAT = 5; { The RIFF file has an invalid format }
 RIFF_CHUNK_NOTFOUND = 6; { The RIFF file doesn't contain this chunk }

type
 TRIFFInternal = record
  Handle, Mapped, Size: Longword;
  BasePointer: Pointer;
 end;

 TRIFFState = (rsFailed, rsOpened);

 TRIFF = class
 private
  FInternal: TRIFFInternal;
  FRIFFState: TRIFFState;
  FRIFFError: Longword;
  FRIFFType: String;
 public
  constructor Create(const FilePath: String); reintroduce;
  destructor Destroy; override;
  function GetChunk(const ChunkName: String; var ChunkSize: Longword): Pointer;
  property RIFFState: TRIFFState read FRIFFState;
  property RIFFError: Longword   read FRIFFError;
  property RIFFType : String     read FRIFFType;
 end;

implementation

{ Vérification du fichier RIFF : il doit faire au moins 8 octets, et doit commencer par "RIFF" en ascii }
function CheckRIFF(const P: Pointer; const Size: Longword; var Error: Longword): Boolean;
begin
 try
  Error := RIFF_UNKNOWN_ERROR;
  Result := False;

  { Vérification taille }
  if Size < 8 then
   begin
    Error := RIFF_INVALID_FORMAT;
    Exit;
   end;

  { Vérification RIFF }
  if PDWORD(P)^ <> $52494646 then
   begin
    Error := RIFF_INVALID_FORMAT;
    Exit;
   end;

  Result := True;
  Error := RIFF_SUCCESS;
 except
  Result := False;
  Error := RIFF_UNKNOWN_ERROR;
 end;
end;

{ Ouvre un fichier RIFF et le mappe en mémoire }
function OpenRIFF(const FilePath: String; var Internal: TRIFFInternal; var Error: Longword): Boolean;
begin
 with Internal do try
  Result := False;
  Error := RIFF_UNKNOWN_ERROR;
  { Tentative d'ouverture du fichier en lecture seule }
  Handle := CreateFile(PChar(FilePath), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL or FILE_FLAG_SEQUENTIAL_SCAN, 0);
  if Handle = INVALID_HANDLE_VALUE then
   begin
    Error := RIFF_CANNOT_OPEN;
    Exit;
   end;

  { Récupération de la taille, puis tentative de mappage }
  Size := GetFileSize(Handle, nil);
  Mapped := CreateFileMapping(Handle, nil, PAGE_READONLY, 0, 0, nil);

  if Mapped = 0 then
   begin
    Error := RIFF_CANNOT_MAP;
    Exit;
   end;

  { Lecture du mappage fichier en mémoire }
  BasePointer := MapViewOfFile(Mapped, FILE_MAP_READ, 0, 0, 0);

  if BasePointer = nil then
   begin
    Error := RIFF_CANNOT_VIEW;
    Exit;
   end;

  { On vérifie le fichier RIFF à présent }
  Result := CheckRIFF(BasePointer, Size, Error);
 except
  Result := False;
  Error := RIFF_UNKNOWN_ERROR;
 end;
end;

{ Récupération du type du fichier RIFF, renvoie par exemple "WAVE", dépend du type du fichier }
function GetRIFFType(P: Pointer; var Error: Longword): String;
begin
 try
  Result := '';
  Error := RIFF_UNKNOWN_ERROR;
  { Le type est toujours situé 8 octets après le début du fichier }
  SetLength(Result, 4);
  P := Ptr(Longword(P) + 8);
  CopyMemory(PAnsiChar(Result), P, 4);
  Error := RIFF_SUCCESS;
 except
  Result := '';
  Error := RIFF_UNKNOWN_ERROR;
 end;
end;

{ Fermeture du fichier RIFF }
function CloseRIFF(var Internal: TRIFFInternal; var Error: Longword): Boolean;
begin
 with Internal do try
  Error := RIFF_UNKNOWN_ERROR;
  UnmapViewOfFile(BasePointer);
  CloseHandle(Mapped);
  CloseHandle(Handle);
  Error := RIFF_SUCCESS;
  Result := True;
 except
  Result := False;
  Error := RIFF_UNKNOWN_ERROR;
 end;
end;

{ Récupération de la position d'une section du fichier RIFF }
function GetRIFFChunk(P: Pointer; const Len, Chunk: Longword; var Size: Longword; var Error: Longword): Pointer;
Var
 E: Pointer;
begin
 try
  Size := 0;
  Result := nil;
  Error := RIFF_UNKNOWN_ERROR;
  { On se prépare à parcourir le fichier à la recherche de la balise }
  E := Ptr(Longword(P) + Len - (Len and $3));
  P := Ptr(Longword(P) - 1);

  repeat
   P := Ptr(Longword(P) + 1);
  until (P = E) or (PDWORD(P)^ = Chunk);

  { Si elle n'a pas été trouvée, on l'indique }
  if (P = E) then
   begin
    Error := RIFF_CHUNK_NOTFOUND;
    Exit;
   end;

  { Si elle a été trouvée, on la récupère et on s'en va }
  if (PDWORD(P)^ = Chunk) then
   begin
    P := Ptr(Longword(P) + 4);
    Size := PDWORD(P)^;
    P := Ptr(Longword(P) + 4);
    Result := P;
    Error := RIFF_SUCCESS;
   end;
 except
  Result := nil;
  Error := RIFF_UNKNOWN_ERROR;
 end;
end;

{ Création de l'objet RIFF }
constructor TRIFF.Create(const FilePath: String);
begin
 inherited Create;
 { On essaye de l'ouvrir, puis on récupère son type }
 FRIFFState := TRIFFState(OpenRIFF(FilePath, FInternal, FRIFFError));
 FRIFFType := GetRIFFType(FInternal.BasePointer, FRIFFError);
end;

{ Libération de l'objet RIFF }
destructor TRIFF.Destroy;
begin
 { On le ferme }
 FRIFFState := TRIFFState(CloseRIFF(FInternal, FRIFFError));
 inherited Destroy;
end;

{ Conversion d'un identificateur de section chaîné en double mot }
function GetChunkID(const ChunkName: String): Longword;
begin
 CopyMemory(@Result, PAnsiChar(ChunkName), 4);
end;

{ Récupération de la section ChunkName }
function TRIFF.GetChunk(const ChunkName: String; var ChunkSize: Longword): Pointer;
begin
 Result := GetRIFFChunk(FInternal.BasePointer, FInternal.Size, GetChunkID(ChunkName), ChunkSize, FRIFFError);
end;

end.
