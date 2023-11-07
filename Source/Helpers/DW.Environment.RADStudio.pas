unit DW.Environment.RADStudio;

interface

uses
  System.Classes,
  DW.Environment;

type
  TRSEnvironment = class(TEnvironment)
  private
  protected
    function GetConfigRoot: string; override;
    function GetKey: TEnvironmentKey; override;
    procedure RootKeyNamesLoaded; override;
  public
    procedure CloseKey;
    function GetAndroidSDKPath(const AVersion: string): string;
    function GetAndroidLibPath(const AVersion: string): string;
    function GetBDSCommonDir(const AVersion: string): string; overload;
    function GetBDSEXEPath(const AIndex: Integer): string; overload;
    function GetBDSPath(const AVersion: string): string; overload;
    function GetBDSPath(const AIndex: Integer): string; overload;
    procedure GetBDSValues(const AIndex: Integer; const APath: string; const AValues: TStrings);
    function GetDefaultSDKName(const AVersion, APlatform: string): string;
    function GetDefaultSDKValue(const AVersion, APlatform, AKey: string): string;
    function GetJDKPath(const AVersion: string): string;
    procedure GetSDKNames(const AVersion: string; const ASDKNames: TStrings);
    procedure GetSearchPaths(const AVersion, APlatform: string; const AVars: TStrings);
    procedure GetVariables(const AVersion: string; const AVars: TStrings);
    function GetVersion(const AIndex: Integer): string;
    function GetVersionName(const AIndex: Integer): string; overload;
    function GetVersionName(const AVersion: string): string; overload;
    function GetVersionNumber(const AVersion: string): string;
    function OpenKey(const AIndex: Integer; const APath: string; const ACanCreate: Boolean = False): Boolean;
    property ConfigRoot: string read GetConfigRoot;
  end;

implementation

uses
  System.SysUtils, System.IOUtils;

const
  cKnownVersions: array[0..8] of string = (
     '18.0', '19.0', '20.0', '21.0', '22.0', '23.0', '24.0', '25.0', '26.0'
  );
  cKnownVersionNames: array[0..8] of string = (
    '10.1 Berlin', '10.2 Tokyo', '10.3 Rio', '10.4 Sydney', '11.0 Alexandria',
    '12.0 Athens', '13.0', '14.0', '15.0'
  );
  cKnownVersionNumbers: array[0..8] of string = (
    '10.1', '10.2', '10.3', '10.4', '11.0', '12.0', '13.0', '14.0', '15.0'
  );

{ TRSEnvironment }

function TRSEnvironment.GetConfigRoot: string;
begin
  Result := 'Software\Embarcadero\BDS';
end;

function TRSEnvironment.GetKey: TEnvironmentKey;
begin
  Result := TEnvironmentKey.User;
end;

function TRSEnvironment.GetVersionName(const AIndex: Integer): string;
begin
  Result := '';
  if (AIndex >= 0) and (AIndex < RootKeyNames.Count) then
    Result := GetVersionName(RootKeyNames[AIndex]);
end;

procedure TRSEnvironment.GetVariables(const AVersion: string; const AVars: TStrings);
begin
  GetValues(AVersion + '\Environment Variables', AVars);
  AVars.Values['DEMOSDIR'] := '';
  AVars.Values['IBREDISTDIR'] := '';
  AVars.Values['BDSCOMMONDIR'] := ''; // Special for those have had their BDS install screw up like mine did
  AVars.Values['Path'] := ''; // Ignore overridden path
end;

procedure TRSEnvironment.GetSDKNames(const AVersion: string; const ASDKNames: TStrings);
begin
  GetValues(AVersion + '\PlatformSDKs', ASDKNames);
end;

procedure TRSEnvironment.GetSearchPaths(const AVersion, APlatform: string; const AVars: TStrings);
var
  LPath: string;
begin
  AVars.Clear;
  LPath := GetValue('SearchPath', AVersion + '\Library\' + APlatform);
  for LPath in LPath.Split([';']) do
    AVars.Add(LPath);
end;

function TRSEnvironment.GetDefaultSDKName(const AVersion, APlatform: string): string;
begin
  Result := GetValue('Default_' + APlatform, AVersion + '\PlatformSDKs');
end;

function TRSEnvironment.GetDefaultSDKValue(const AVersion, APlatform, AKey: string): string;
var
  LDefaultSDKName: string;
begin
  LDefaultSDKName := GetDefaultSDKName(AVersion, APlatform);
  Result := GetValue(AKey, AVersion + '\PlatformSDKs\' + LDefaultSDKName);
end;

procedure TRSEnvironment.GetBDSValues(const AIndex: Integer; const APath: string; const AValues: TStrings);
begin
  GetValues(GetVersion(AIndex) + '\' + APath, AValues);
end;

function TRSEnvironment.GetVersion(const AIndex: Integer): string;
begin
  Result := '';
  if (AIndex >= 0) and (AIndex < RootKeyNames.Count) then
    Result := RootKeyNames[AIndex];
end;

function TRSEnvironment.GetVersionName(const AVersion: string): string;
var
  I: Integer;
begin
  Result := Format('RAD Studio %s (Unknown Delphi version name)', [AVersion]);
  for I := Low(cKnownVersions) to High(cKnownVersions) do
  begin
    if cKnownVersions[I].Equals(AVersion) then
      Result := cKnownVersionNames[I];
  end;
end;

function TRSEnvironment.GetVersionNumber(const AVersion: string): string;
var
  LUpdate, I: Integer;
  LParts: TArray<string>;
begin
  Result := '';
  for I := Low(cKnownVersions) to High(cKnownVersions) do
  begin
    if cKnownVersions[I].Equals(AVersion) then
      Result := cKnownVersionNumbers[I];
  end;
  LUpdate := 0;
  LParts := GetValue('Main Product Update', AVersion + '\InstalledUpdates').Split([' ']);
  if Length(LParts) > 0 then
    LUpdate := StrToIntDef(LParts[Length(LParts) - 1], 0);
  Result := Result + '.' + LUpdate.ToString;
end;

function TRSEnvironment.OpenKey(const AIndex: Integer; const APath: string; const ACanCreate: Boolean = False): Boolean;
begin
  Result := Registry.OpenKey(GetConfigRoot + '\' + GetVersion(AIndex) + '\' + APath, ACanCreate);
end;

procedure TRSEnvironment.RootKeyNamesLoaded;
var
  I: Integer;
begin
  for I := RootKeyNames.Count - 1 downto 0 do
  begin
    if not TFile.Exists(GetValue('App', RootKeyNames[I])) then
      RootKeyNames.Delete(I);
  end;
end;

procedure TRSEnvironment.CloseKey;
begin
  Registry.CloseKey;
end;

function TRSEnvironment.GetAndroidLibPath(const AVersion: string): string;
begin
  Result := TPath.Combine(GetBDSPath(AVersion), 'lib\android\release');
end;

function TRSEnvironment.GetAndroidSDKPath(const AVersion: string): string;
var
  LDefaultAndroid: string;
begin
  Result := '';
  LDefaultAndroid := GetValue('Default_Android', AVersion + '\PlatformSDKs');
  if not LDefaultAndroid.IsEmpty then
    Result := GetValue('SystemRoot', AVersion + '\PlatformSDKs\' + LDefaultAndroid);
end;

function TRSEnvironment.GetJDKPath(const AVersion: string): string;
var
  LDefaultAndroid: string;
begin
  Result := '';
  LDefaultAndroid := GetValue('Default_Android', AVersion + '\PlatformSDKs');
  if not LDefaultAndroid.IsEmpty then
    Result := GetValue('JDKPath');
end;

function TRSEnvironment.GetBDSPath(const AVersion: string): string;
begin
  Result := GetValue('RootDir', AVersion);
end;

function TRSEnvironment.GetBDSCommonDir(const AVersion: string): string;
begin
  Result := GetValue('BDSCOMMONDIR', AVersion + '\Environment Variables');
end;

function TRSEnvironment.GetBDSEXEPath(const AIndex: Integer): string;
begin
  Result := GetValue('App', GetVersion(AIndex));
end;

function TRSEnvironment.GetBDSPath(const AIndex: Integer): string;
begin
  Result := GetValue('RootDir', GetVersion(AIndex));
end;

end.
