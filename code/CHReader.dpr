
program
  CHReader;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

uses
  Forms,
  Startup in 'Startup.pas' {frmStartup},
  WebServer in 'WebServer.pas',
  Compiler in 'Compiler.pas',
  Shared in 'Shared.pas';

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

{$R *.RES}

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

begin
  Application.Initialize;
  Application.Title := 'CHReader';
  Application.CreateForm(TfrmStartup, frmStartup);
  Application.Run;
end.
