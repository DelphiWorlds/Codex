unit Codex.SDKRegistry;

{*******************************************************}
{                                                       }
{                      Codex                            }
{                                                       }
{         Add-in for Delphi from Delphi Worlds          }
{                                                       }
{  Copyright 2020-2023 Dave Nottage under MIT license   }
{  which is located in the root folder of this library  }
{                                                       }
{*******************************************************}

interface

uses
  {$IF Defined(EXPERT)}
  PlatformAPI,
  {$ENDIF}
  System.Classes, System.Win.Registry;

type
  TSDKRegistry = class(TObject)
  private
    class var FCurrent: TSDKRegistry;
    class destructor DestroyClass;
    class function GetCurrent: TSDKRegistry; static;
  private
    FRegistry: TRegistry;
    FItems: TStrings;
    FRootKey: string;
    function FindNextFrameworkIndex(const AMask: string; const AKeys: TStrings): Integer;
    function FindNextKeyIndex(const AKeys: TStrings; const AKey: string): Integer;
    function GetCount: Integer;
    function GetAndroidDefaultValue(const AName: string): string;
    function GetItem(const AIndex: Integer): string;
    {$IF Defined(EXPERT)}
    function GetProjectAndroidSDK(out ASDK: IOTAPlatformSDKAndroid): Boolean;
    {$ENDIF}
    procedure ReadKeys;
    function ReadString(const APath: string; const AName: string): string;
  public
    class property Current: TSDKRegistry read GetCurrent;
  public
    constructor Create;
    destructor Destroy; override;
    function AddFramework(const AIndex: Integer; const AName: string; const AAllFiles: Boolean): Boolean;
    function CanCreateJar: Boolean;
    function CanCreateRJar: Boolean;
    function GetADBPath: string;
    function GetAAPTPath: string;
    function GetBuildToolsPath: string;
    function GetJDKPath: string;
    function GetSDKAPILevelPath: string;
    property Items[const AIndex: Integer]: string read GetItem;
    property Count: Integer read GetCount;
  end;

implementation

uses
  System.SysUtils,System.IOUtils,
  Winapi.Windows,
  {$IF Defined(EXPERT)}
  ToolsAPI, DW.OTA.Helpers,
  {$ENDIF}
  DW.OS.Win,
  Codex.Consts;

const
  cRegistryRootKey = '\SOFTWARE\Embarcadero\BDS\%s\PlatformSDKs\';
  cRegistryValueKeySDKDisplayName = 'SDKDisplayName';
  cRegistryValueKeyIncludeSubDir = 'IncludeSubDir';
  cRegistryValueKeyMask = 'Mask';
  cRegistryValueKeyPath = 'Path';
  cRegistryValueKeyType = 'Type';
  cRegistryValueTypeFramework = 2;

  cRegistryValueIncludeSubDirValues: array[Boolean] of string = ('0', '1');
  cRegistryValuePathFrameworks = '$(SDKROOT)/System/Library/Frameworks';

{ TSDKRegistry }

constructor TSDKRegistry.Create;
var
  LAccess: Cardinal;
begin
  inherited;
  FItems := TStringList.Create;
  LAccess := KEY_READ or KEY_WRITE;
  if TOSVersion.Architecture = TOSVersion.TArchitecture.arIntelX86 then
    LAccess := LAccess or KEY_WOW64_32KEY
  else
    LAccess := LAccess or KEY_WOW64_64KEY;
  FRegistry := TRegistry.Create(LAccess);
  FRegistry.RootKey := HKEY_CURRENT_USER;
  FRootKey := Format(cRegistryRootKey, [TPlatformOS.GetEnvironmentVariable(cEnvVarProductVersion)]);
end;

destructor TSDKRegistry.Destroy;
begin
  FItems.Free;
  FRegistry.Free;
  inherited;
end;

class destructor TSDKRegistry.DestroyClass;
begin
  FCurrent.Free;
end;

class function TSDKRegistry.GetCurrent: TSDKRegistry;
begin
  if FCurrent = nil then
    FCurrent := TSDKRegistry.Create;
  Result := FCurrent;
end;

function TSDKRegistry.FindNextFrameworkIndex(const AMask: string; const AKeys: TStrings): Integer;
var
  LIncludeSubDirIndex, LMaskIndex, LPathIndex, LTypeIndex, I: Integer;
begin
  Result := -1;
  for I := 0 to AKeys.Count - 1 do
  begin
    if AKeys[I].StartsWith(cRegistryValueKeyMask) and FRegistry.ReadString(AKeys[I]).Equals(AMask) then
    begin
      Result := I;
      Break;
    end;
  end;
  if Result = -1 then
  begin
    LIncludeSubDirIndex := FindNextKeyIndex(AKeys, cRegistryValueKeyIncludeSubDir);
    LMaskIndex := FindNextKeyIndex(AKeys, cRegistryValueKeyMask);
    LPathIndex := FindNextKeyIndex(AKeys, cRegistryValueKeyPath);
    LTypeIndex := FindNextKeyIndex(AKeys, cRegistryValueKeyType);
    if (LIncludeSubDirIndex = LMaskIndex) and (LMaskIndex = LPathIndex) and (LPathIndex = LTypeIndex) then
      Result := LIncludeSubDirIndex;
  end
  else
    Result := -1;
end;

function TSDKRegistry.FindNextKeyIndex(const AKeys: TStrings; const AKey: string): Integer;
var
  I, LKeyIndex: Integer;
  LKeyName: string;
begin
  Result := -1;
  for I := 0 to AKeys.Count - 1 do
  begin
    LKeyName := AKeys[I];
    if LKeyName.StartsWith(AKey) and TryStrToInt(LKeyName.Substring(Length(AKey)), LKeyIndex) and (LKeyIndex > Result) then
      Result := LKeyIndex;
  end;
  if Result > -1 then
    Inc(Result);
end;

function TSDKRegistry.AddFramework(const AIndex: Integer; const AName: string; const AAllFiles: Boolean): Boolean;
var
  LKeys: TStrings;
  LIndex: Integer;
begin
  Result := False;
  ReadKeys;
  if (AIndex >= 0) and (AIndex < FItems.Count) then
  begin
    if FRegistry.OpenKey(FRootKey + FItems[AIndex], False) then
    try
      LKeys := TStringList.Create;
      try
        FRegistry.GetValueNames(LKeys);
        LIndex := FindNextFrameworkIndex(AName, LKeys);
        if LIndex > -1 then
        begin
          FRegistry.WriteString(cRegistryValueKeyIncludeSubDir + LIndex.ToString, cRegistryValueIncludeSubDirValues[AAllFiles]);
          FRegistry.WriteString(cRegistryValueKeyMask + LIndex.ToString, AName);
          FRegistry.WriteString(cRegistryValueKeyPath + LIndex.ToString, cRegistryValuePathFrameworks);
          FRegistry.WriteInteger(cRegistryValueKeyType + LIndex.ToString, cRegistryValueTypeFramework);
          Result := True;
        end;
      finally
        LKeys.Free;
      end;
    finally
      FRegistry.CloseKey;
    end;
  end;
end;

function TSDKRegistry.GetItem(const AIndex: Integer): string;
begin
  Result := '';
  if (AIndex >= 0) and (AIndex < FItems.Count) then
  begin
    if FRegistry.OpenKey(FRootKey + FItems[AIndex], False) then
    try
      Result := FRegistry.ReadString(cRegistryValueKeySDKDisplayName);
    finally
      FRegistry.CloseKey;
    end;
  end;
end;

procedure TSDKRegistry.ReadKeys;
var
  I: Integer;
begin
  FItems.Clear;
  if FRegistry.OpenKey(FRootKey, False) then
  try
    FRegistry.GetKeyNames(FItems);
    for I := FItems.Count - 1 downto 0 do
    begin
      if not (FItems[I].StartsWith('iPhone') or FItems[I].StartsWith('MacOSX')) then
        FItems.Delete(I);
    end;
  finally
    FRegistry.CloseKey;
  end;
end;

function TSDKRegistry.GetCount: Integer;
begin
  ReadKeys;
  Result := FItems.Count;
end;

function TSDKRegistry.ReadString(const APath: string; const AName: string): string;
begin
  Result := '';
  if FRegistry.OpenKey(FRootKey + APath, False) then
  try
    Result := FRegistry.ReadString(AName);
  finally
    FRegistry.CloseKey;
  end;
end;

{$IF Defined(EXPERT)}
function TSDKRegistry.GetProjectAndroidSDK(out ASDK: IOTAPlatformSDKAndroid): Boolean;
var
  LProject: IOTAProject;
  LSDK: IOTAPlatformSDK;
begin
  Result := False;
  LProject := TOTAHelper.GetActiveProject;
  if LProject <> nil then
  begin
    LSDK := (BorlandIDEServices as IOTAPlatformSDKServices).GetDefaultForPlatform(LProject.CurrentPlatform);
    Result := Supports(LSDK, IOTAPlatformSDKAndroid, ASDK);
  end;
end;
{$ENDIF}

function TSDKRegistry.GetAndroidDefaultValue(const AName: string): string;
var
  LDefaultSDK: string;
begin
  LDefaultSDK := ReadString('', 'Default_Android');
  if LDefaultSDK.IsEmpty then
    LDefaultSDK := ReadString('', 'Default_Android64');
  if not LDefaultSDK.IsEmpty then
    Result := ReadString(LDefaultSDK, AName);
end;

function TSDKRegistry.GetBuildToolsPath: string;
begin
  Result := GetAAPTPath;
  if not Result.IsEmpty then
    Result := TPath.GetDirectoryName(Result);
end;

function TSDKRegistry.GetAAPTPath: string;
{$IF Defined(EXPERT)}
var
  LAndroidSDK: IOTAPlatformSDKAndroid;
{$ENDIF}
begin
  Result := '';
  {$IF Defined(EXPERT)}
  if GetProjectAndroidSDK(LAndroidSDK) then
    Result := LAndroidSDK.SDKAaptPath;
  {$ENDIF}
  if Result.IsEmpty then
    Result := GetAndroidDefaultValue('SDKAaptPath');
end;

function TSDKRegistry.GetADBPath: string;
{$IF Defined(EXPERT)}
var
  LAndroidSDK: IOTAPlatformSDKAndroid;
{$ENDIF}
begin
  Result := '';
  {$IF Defined(EXPERT)}
  if GetProjectAndroidSDK(LAndroidSDK) then
    Result := LAndroidSDK.SDKAdbPath;
  {$ENDIF}
  if Result.IsEmpty then
    Result := GetAndroidDefaultValue('SDKAdbPath');
end;

function TSDKRegistry.GetJDKPath: string;
{$IF Defined(EXPERT)}
var
  LAndroidSDK: IOTAPlatformSDKAndroid;
{$ENDIF}
begin
  Result := '';
  {$IF Defined(EXPERT)}
  if GetProjectAndroidSDK(LAndroidSDK) then
    Result := LAndroidSDK.JDKPath;
  {$ENDIF}
  if Result.IsEmpty then
    Result := GetAndroidDefaultValue('JDKPath');
end;

function TSDKRegistry.GetSDKAPILevelPath: string;
{$IF Defined(EXPERT)}
var
  LAndroidSDK: IOTAPlatformSDKAndroid;
{$ENDIF}
begin
  Result := '';
  {$IF Defined(EXPERT)}
  if GetProjectAndroidSDK(LAndroidSDK) then
    Result := LAndroidSDK.SDKApiLevel;
  {$ENDIF}
  if Result.IsEmpty then
    Result := GetAndroidDefaultValue('SDKApiLevelPath');
end;

function TSDKRegistry.CanCreateJar: Boolean;
begin
  Result := not GetSDKAPILevelPath.IsEmpty and not GetJDKPath.IsEmpty;
end;

function TSDKRegistry.CanCreateRJar: Boolean;
begin
  Result := not GetBuildToolsPath.IsEmpty and CanCreateJar;
end;

end.
