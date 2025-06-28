
unit
  Lzo;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

interface

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function _memcmp(s1, s2: Pointer; numBytes: Cardinal): Integer; cdecl;
procedure _memcpy(s1, s2: Pointer; n: Integer); cdecl;
procedure _memmove(dstP, srcP: Pointer; numBytes: Cardinal); cdecl;
procedure _memset(s: Pointer; c: Byte; n: Integer); cdecl;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

{$LINK 'minilzo.obj'}

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function lzo1x_1_compress(const Source: Pointer; SourceLength: Cardinal; Dest: Pointer; var DestLength: Cardinal; WorkMem: Pointer): Integer; stdcall; external;
function lzo1x_decompress(const Source: Pointer; SourceLength: Cardinal; Dest: Pointer; var DestLength: Cardinal; WorkMem: Pointer (* NOT USED! *)): Integer; stdcall; external;
function lzo1x_decompress_safe(const Source: Pointer; SourceLength: Cardinal; Dest: Pointer; var DestLength: Cardinal; WorkMem: Pointer (* NOT USED! *)): Integer; stdcall; external;
function lzo_adler32(Adler: Cardinal; const Buf: Pointer; Len: Cardinal): Cardinal; stdcall; external;
function lzo_version: Word; stdcall; external;
function lzo_version_string: PChar; stdcall; external;
function lzo_version_date: PChar; stdcall; external;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

implementation

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure _memset(s: Pointer; c: Byte; n: Integer); cdecl;
begin
  FillChar(s^, n, c);
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure _memcpy(s1, s2: Pointer; n: Integer); cdecl;
begin
  Move(s2^, s1^, n);
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

function _memcmp(s1, s2: Pointer; numBytes: Cardinal): Integer; cdecl;
var
  i: Integer;
  p1, p2: ^Byte;
begin
  p1 := s1; p2 := s2;
  for i := 0 to numBytes - 1 do begin
    if (p1^ <> p2^) then begin
      if (p1^ < p2^) then Result := -1 else Result := 1; exit;
    end; Inc(p1); Inc(p2);
  end; Result := 0;
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

procedure _memmove(dstP, srcP: Pointer; numBytes: Cardinal); cdecl;
begin
  Move(srcP^, dstP^, numBytes);
  FreeMem(srcP, numBytes);
end;

// --------------------------------------------------------------------------
//
// --------------------------------------------------------------------------

end.
