
unit
  Startup;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

interface

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

uses
  Windows, Messages, SysUtils, Winsock, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls, ShellAPI, Shared, WebServer, Compiler;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

type
  TfrmStartup = class(TForm)

    edBrowseArchive: TEdit;
    edCompileDestination: TEdit;
    edCompileFolder: TEdit;
    imgBrowse: TImage;
    imgCompile: TImage;
    imgStatus: TImage;
    lbBrowse: TLabel;
    lbBrowseArchive: TLabel;
    lbBrowseInfo: TLabel;
    lbCompile: TLabel;
    lbCompileDestination: TLabel;
    lbCompileFolder: TLabel;
    lbCompileInfo: TLabel;
    lbGenericInfo: TLabel;
    lbStatus: TLabel;
    shpBrowse: TShape;
    shpCompile: TShape;
    tmrClock: TTimer;

    procedure FormCreate(Sender: TObject);
    procedure lbCompileClick(Sender: TObject);
    procedure lbBrowseClick(Sender: TObject);
    procedure tmrClockTimer(Sender: TObject);

  private

    procedure DisableInterface;

  end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

var
  frmStartup: TfrmStartup;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

implementation

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

{$R *.DFM}

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TfrmStartup.DisableInterface;
begin
  lbBrowse.Enabled := False;
  lbCompile.Enabled := False;
  edCompileFolder.Enabled := False;
  edCompileDestination.Enabled := False;
  edBrowseArchive.Enabled := False;
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TfrmStartup.lbCompileClick(Sender: TObject);
var
  Id: Cardinal;
begin
  DisableInterface;
  CompilerFolder := edCompileFolder.Text;
  CompilerDestination := edCompileDestination.Text;
  CreateThread(nil, 0, @Compile, nil, 0, Id);
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TfrmStartup.lbBrowseClick(Sender: TObject);
var
  Id: Cardinal;
begin
  DisableInterface;
  WebServerArchiveName := edBrowseArchive.Text;
  CreateThread(nil, 0, @HttpServer, Pointer(8971), 0, Id);
  ShellExecute(Handle, 'open', 'http://localhost:8971/index.html', nil, nil, SW_NORMAL);
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TfrmStartup.tmrClockTimer(Sender: TObject);
begin
  tmrClock.Enabled := False;

  if WebServerRunning then begin
    lbStatus.Caption := 'Web server activated.';
  end else if CompilerRunning then begin
    if CompilerDone then lbStatus.Caption := 'Compilation completed.' else lbStatus.Caption := 'Compiling ' + CompilerProcessing + '...';
  end else begin
    lbStatus.Caption := 'Standby.';
  end;

  tmrClock.Enabled := True;
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure TfrmStartup.FormCreate(Sender: TObject);
var
  i: Integer;
begin
  if (ParamCount > 0) then begin
    for i := 1 to ParamCount do begin

      if (ParamStr(i) = '--compile') then begin Self.lbCompileClick(nil); end;
      if (ParamStr(i) = '--compile-source') and ((i + 1) <= ParamCount) then edCompileFolder.Text := ParamStr(i + 1);
      if (ParamStr(i) = '--compile-archive') and ((i + 1) <= ParamCount) then edCompileDestination.Text := ParamStr(i + 1);

      if (ParamStr(i) = '--browse') then begin Self.WindowState := wsMinimized; Self.lbBrowseClick(nil); end;
      if (ParamStr(i) = '--browse-archive') and ((i + 1) <= ParamCount) then edBrowseArchive.Text := ParamStr(i + 1);

    end;
  end;
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

end.
