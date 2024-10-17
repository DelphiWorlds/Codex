unit Codex.Types;

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

{$SCOPEDENUMS ON}

uses
  Mosco.API,
  DW.OTA.Types;

type
  TTextColor = (Hint, Warning, Error, Success);

  TProjectProperties = record
  public
    class function GetBuildTypeNumber(const ABuildType: string): Integer; static;
  public
    BuildType: string;
    BuildTypeNumber: Integer;
    Config: string;
    Platform: string;
    Profile: string;
    ProjectFileName: string;
    ProjectOutputFolder: string;
    ProjectPlatform: TProjectPlatform;
    TargetFileName: string;
    procedure Clear;
    function GetBuildKind: TProfileKind;
    function GetCaption: string;
    function GetLongBuildType: string;
    function IsDistributionBuildType: Boolean;
    function Update(const AProperties: TProjectProperties): Boolean;
  end;

  TSourceErrorKind = (Hint, Warning, Error);

  TSourceError = record
    LineNo: Integer;
    ColumnNo: Integer;
    Kind: TSourceErrorKind;
    Message: string;
    constructor Create(const AMessage: string);
    function Equals(const AError: TSourceError): Boolean;
  end;

  TSourceErrors = TArray<TSourceError>;

  TSourceSymbol = record
    Symbol: string;
    LineNo: Integer;
    ColumnNo: Integer;
    Units: TArray<string>;
    UseUnit: Integer;
  end;

  TSourceSymbols = TArray<TSourceSymbol>;

  TUnitSection = (InterfaceSection, ImplementationSection);

  TUseUnit = record
    UnitName: string;
    Section: TUnitSection;
  end;

  TUseUnits = TArray<TUseUnit>;

  TDelphiVersionInfo = record
    Major: Integer;
    Minor: Integer;
    Version: Integer;
    Build: Integer;
    function IsDelphi12Update1(const ANeedExact: Boolean = True): Boolean;
  end;

implementation

uses
  System.SysUtils;

{ TProjectProperties }

class function TProjectProperties.GetBuildTypeNumber(const ABuildType: string): Integer;
begin
  if ABuildType.Equals('AppStore') then
    Result := 0
  else if ABuildType.Equals('Adhoc') then
    Result := 1
  else if ABuildType.Equals('Development') or ABuildType.Equals('Normal') then
    Result := 2
  else if ABuildType.Equals('DeveloperID') then
    Result := 3
  else
    Result := -1;
end;

procedure TProjectProperties.Clear;
begin
  BuildType := '';
  Config := '';
  Platform := '';
  ProjectFileName := '';
  TargetFileName := '';
end;

function TProjectProperties.GetLongBuildType: string;
begin
  if BuildType.Equals('AppStore') then
    Result := 'Application Store'
  else if BuildType.Equals('Adhoc') then
    Result := 'Ad hoc'
  else if BuildType.Equals('DeveloperID') then
    Result := 'Developer ID'
  else
    Result := BuildType;
end;

function TProjectProperties.GetBuildKind: TProfileKind;
begin
  Result := TProfileKind.Development;
  if BuildType.Equals('AppStore') then
    Result := TProfileKind.AppStore
  else if BuildType.Equals('Adhoc') then
    Result := TProfileKind.AdHoc
  else if BuildType.Equals('DeveloperID') then
    Result := TProfileKind.Enterprise;
end;

function TProjectProperties.GetCaption: string;
begin
  Result := '';
  if not (Platform.IsEmpty or Config.IsEmpty) then
  begin
    Result := Platform + ' > ' + Config;
    if not BuildType.IsEmpty and not BuildType.Equals(Config) then
      Result := Result + ' > ' + GetLongBuildType;
    Result := Result + ' - ' + ProjectOutputFolder;
  end;
end;

function TProjectProperties.IsDistributionBuildType: Boolean;
begin
  Result := BuildType.Equals('AppStore') or BuildType.Equals('Adhoc') or BuildType.Equals('DeveloperID');
end;

function TProjectProperties.Update(const AProperties: TProjectProperties): Boolean;
begin
  Result := False;
  if not SameText(ProjectFileName, AProperties.ProjectFileName) or not Platform.Equals(AProperties.Platform) or not Config.Equals(AProperties.Config)
    or not BuildType.Equals(AProperties.BuildType) then // or not BundleIdentifier.Equals(AProperties.BundleIdentifier) then
  begin
    Self := AProperties;
    Result := True;
  end;
end;

{ TSourceError }

constructor TSourceError.Create(const AMessage: string);
var
  LValue, LError: string;
  LColonIndex: Integer;
begin
  LError := AMessage.Substring(AMessage.LastIndexOf('(') + 1);
  // eg
  //  012345678901234567 (18)
  //  at line xx (xx:yy)
  LColonIndex := LError.IndexOf(':');
  LValue := LError.Substring(0, LColonIndex);
  if not integer.TryParse(LValue, LineNo) then
    LineNo := -1;
  LValue := LError.Substring(LColonIndex + 1, Length(LError) - LColonIndex - 2); // skip the last bracket
  if not integer.TryParse(LValue, ColumnNo) then
    ColumnNo := -1;
  case AMessage.Chars[0] of
    'H':
      Kind := TSourceErrorKind.Hint;
    'W':
      Kind := TSourceErrorKind.Warning;
    else
      Kind := TSourceErrorKind.Error;
  end;
  LError := AMessage.Substring(0, AMessage.LastIndexOf(' at line ')); // TODO: Might need to allow for localized text!
  Message := LError.Substring(LError.IndexOf(' ') + 1).Trim;
end;

function TSourceError.Equals(const AError: TSourceError): Boolean;
begin
  Result := (LineNo = AError.LineNo) and (ColumnNo = AError.ColumnNo) and (Kind = AError.Kind) and (Message = AError.Message);
end;

{ TDelphiVersionInfo }

function TDelphiVersionInfo.IsDelphi12Update1(const ANeedExact: Boolean = True): Boolean;
begin
  Result := (Major = 29) and (Minor = 0) and (Version = 51961) and (Build = 7529);
  if not Result and not ANeedExact then
    Result := (Major > 29) or ((Major = 29) and ((Minor > 0) or (Version >= 51961)));
end;

end.
