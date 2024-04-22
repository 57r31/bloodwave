unit Unit1;

interface

type DWORD = LongWord;
          BOOL = LongBool;

  LongRec = packed record
    case Integer of
      0: (Lo, Hi: Word);
      1: (Words: array [0..1] of Word);
      2: (Bytes: array [0..3] of Byte);
  end;



const
  faReadOnly  = $00000001;
  faHidden    = $00000002;
  faSysFile   = $00000004;
  faVolumeID  = $00000008;
  faDirectory = $00000010;
  faArchive   = $00000020;
  faAnyFile   = $0000003F;

  INVALID_HANDLE_VALUE = DWORD(-1);

    SND_FILENAME        = $00020000;  { name is file name }

type

    TFileTime = record
    dwLowDateTime: DWORD;
    dwHighDateTime: DWORD;
    end;

    TWin32FindData = record
    dwFileAttributes: DWORD;
    ftCreationTime: TFileTime;
    ftLastAccessTime: TFileTime;
    ftLastWriteTime: TFileTime;
    nFileSizeHigh: DWORD;
    nFileSizeLow: DWORD;
    dwReserved0: DWORD;
    dwReserved1: DWORD;
    cFileName: array[0..260 - 1] of AnsiChar;
    cAlternateFileName: array[0..13] of AnsiChar;
  end;

    TSearchRec = record
     Time: Integer;
     Size: Integer;
     Attr: Integer;
     Name: string;
     ExcludeAttr: Integer;
     FindHandle: THandle;
     FindData: TWin32FindData;
 end;

  function FindFirst(const Path: string; Attr: Integer;
  var  F: TSearchRec): Integer;

  function FindFirstFile(lpFileName: PChar; var lpFindFileData: TWIN32FindData): THandle;
                stdcall; external 'kernel32.dll' name 'FindFirstFileA';
  function FindNextFile(hFindFile: THandle; var lpFindFileData: TWIN32FindData): BOOL;
                stdcall; external 'kernel32.dll' name 'FindNextFileA';
  function FileTimeToLocalFileTime(const lpFileTime: TFileTime; var lpLocalFileTime: TFileTime): BOOL;
                stdcall; external 'kernel32.dll' name 'FileTimeToLocalFileTime';
  function FileTimeToDosDateTime(const lpFileTime: TFileTime; var lpFatDate, lpFatTime: Word): BOOL;
                stdcall; external 'kernel32.dll' name 'FileTimeToDosDateTime';
  procedure Findlose(var F: TSearchRec);
  function FindClose(hFindFile: THandle): BOOL;
                stdcall; external 'kernel32.dll' name 'FindClose';
  function FindNext(var F: TSearchRec): Integer;
  function PlaySound(pszSound: PChar; hmod: HMODULE; fdwSound: DWORD): BOOL;
                stdcall; external 'winmm.dll' name 'PlaySoundA';


implementation


procedure Findlose(var F: TSearchRec);
begin
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    FindClose(F.FindHandle);
    F.FindHandle := INVALID_HANDLE_VALUE;
  end;
end;


function FindMatchingFile(var F: TSearchRec): Integer;
var
  LocalFileTime: TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not FindNextFile(FindHandle, FindData) then
      begin
        Result := GetLastError;
        Exit;
      end;
    FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi,
      LongRec(Time).Lo);
    Size := FindData.nFileSizeLow;
    Attr := FindData.dwFileAttributes;
    Name := FindData.cFileName;
  end;
  Result := 0;
end;

function FindFirst(const Path: string; Attr: Integer;
  var  F: TSearchRec): Integer;
const
  faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := FindFirstFile(PChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := FindMatchingFile(F);
    if Result <> 0 then Findlose(F);
  end else
    Result := GetLastError;
end;

function FindNext(var F: TSearchRec): Integer;
begin
  if FindNextFile(F.FindHandle, F.FindData) then
    Result := FindMatchingFile(F) else
    Result := GetLastError;
end;


end.
