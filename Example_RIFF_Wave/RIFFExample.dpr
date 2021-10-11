program RIFFExample;

uses
  Forms,
  Main in 'Main.pas' {MainForm},
  Wave in 'Wave.pas';

{$R *.res}
{$R WinThemes.res}

begin
  Application.Initialize;
  Application.Title := 'Lecteur WAVE';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
