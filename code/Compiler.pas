
unit
  Compiler;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

interface

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

uses
  Windows, SysUtils, Lzo, Shared;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

var
  CompilerFolder, CompilerDestination: String;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

var
  CompilerDone: Boolean;
  CompilerRunning: Boolean;
  CompilerProcessing: String;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function Compile(Nothing: Integer): Integer; safecall; far;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

implementation

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function IsNotCompressible(FileName: String): Boolean;

var
  Ext: String;

begin
  Ext := LowerCase(ExtractFileExt(FileName));

  Result := (Ext = '.7z'  ) or
            (Ext = '.arj' ) or
            (Ext = '.avi' ) or
            (Ext = '.cab' ) or
            (Ext = '.gz'  ) or
            (Ext = '.gif' ) or
            (Ext = '.jpg' ) or
            (Ext = '.jpeg') or
            (Ext = '.mkv' ) or
            (Ext = '.mp2' ) or
            (Ext = '.mp3' ) or
            (Ext = '.mpg' ) or
            (Ext = '.mpge') or
            (Ext = '.ogg' ) or
            (Ext = '.png' ) or
            (Ext = '.rar' ) or
            (Ext = '.tif' ) or
            (Ext = '.tiff' ) or
            (Ext = '.tgz' ) or
            (Ext = '.wav' ) or
            (Ext = '.wma' ) or
            (Ext = '.wmv' ) or
            (Ext = '.zip' );
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure RecursiveScanArchive(Path: String);

var
  j: Integer; Data: TSearchRec;
  Buffer, LzoMem, WorkMem: PByteArray;
  Source: THandle; SourceSize, BytesRead, BytesWritten, BytesCompressed: Cardinal;

begin

  j := FindFirst(Path + '\*.*', faAnyFile, Data); while (j = 0) do begin

    if ((Data.Attr and faDirectory) = 0) then begin // If it's a file...

      CompilerProcessing := Data.Name;

      if (ListSize < MAX_LIST_SIZE) then begin

      Source := CreateFile(PChar(Path + '\' + Data.Name), GENERIC_READ, FILE_SHARE_READ, nil, OPEN_EXISTING, 0, 0); if (Source <> INVALID_HANDLE_VALUE) then begin

        SourceSize := GetFileSize(Source, nil);

        GetMem(Buffer, SourceSize);

        List[ListSize].Size := SourceSize;
        List[ListSize].Position := ArchiveSize;
        List[ListSize].Name := StringReplace(Copy(Path + '\' + Data.Name, Length(CompilerFolder) + 2, 65536), '\', '/', [rfReplaceAll]);

        ReadFile(Source, Buffer^, SourceSize, BytesRead, nil);

        if not(IsNotCompressible(Data.Name)) then begin

          GetMem(WorkMem, 131072);
          GetMem(LzoMem, SourceSize + 65536);

          lzo1x_1_compress(Buffer, BytesRead, LzoMem, BytesCompressed, WorkMem);

          if (BytesCompressed < BytesRead) then begin // If the compression ratio is good...

            WriteFile(Archive, LzoMem^, BytesCompressed, BytesWritten, nil); Inc(ArchiveSize, BytesWritten);

            List[ListSize].Compressed := BytesCompressed;

          end else begin

            WriteFile(Archive, Buffer^, BytesRead, BytesWritten, nil); Inc(ArchiveSize, BytesWritten);

            List[ListSize].Compressed := 0;

          end;

          FreeMem(LzoMem, SourceSize + 65536);
          FreeMem(WorkMem, 131072);

        end else begin

          WriteFile(Archive, Buffer^, BytesRead, BytesWritten, nil); Inc(ArchiveSize, BytesWritten);

          List[ListSize].Compressed := 0;

        end;

        FreeMem(Buffer, SourceSize);

        CloseHandle(Source);

        Inc(ListSize);

      end;

      end;

    end else if (Data.Name <> '.') and (Data.Name <> '..') then begin

      RecursiveScanArchive(Path + '\' + Data.Name);

    end; j := FindNext(Data);

  end; FindClose(Data);

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function Compile(Nothing: Integer): Integer; safecall; far;

var
  j: Integer;
  NameSize: Word;
  BytesWritten: Cardinal;

begin

  CompilerRunning := True;

  Archive := CreateFile(PChar(CompilerDestination), GENERIC_WRITE, 0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_ARCHIVE, 0); if (Archive <> INVALID_HANDLE_VALUE) then begin

    ArchiveSize := 0; WriteFile(Archive, ArchiveSize, SizeOf(ArchiveSize), BytesWritten, nil); ArchiveSize := SizeOf(ArchiveSize);

    RecursiveScanArchive(CompilerFolder);

    SetFilePointer(Archive, 0, nil, FILE_BEGIN); WriteFile(Archive, ArchiveSize, SizeOf(ArchiveSize), BytesWritten, nil);

    SetFilePointer(Archive, ArchiveSize, nil, FILE_BEGIN);

    for j := 0 to (ListSize - 1) do begin

      WriteFile(Archive, List[j].Size, SizeOf(List[j].Size), BytesWritten, nil);
      WriteFile(Archive, List[j].Compressed, SizeOf(List[j].Compressed), BytesWritten, nil);
      WriteFile(Archive, List[j].Position, SizeOf(List[j].Position), BytesWritten, nil);

      NameSize := Length(List[j].Name);
      WriteFile(Archive, NameSize, SizeOf(NameSize), BytesWritten, nil);
      WriteFile(Archive, List[j].Name[1], NameSize, BytesWritten, nil);

    end;

    CloseHandle(Archive);

  end;

  CompilerDone := True;

  ExitThread(0);

end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

initialization

  CompilerDone := False;
  CompilerRunning := False;
  CompilerProcessing := '';

end.
