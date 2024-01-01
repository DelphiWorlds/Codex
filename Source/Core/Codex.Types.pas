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
    BundleIdentifier: string;
    Config: string;
    DeviceID: string;
    Platform: string;
    Profile: string;
    ProjectFileName: string;
    ProjectPlatform: TProjectPlatform;
    TargetFileName: string;
    procedure Clear;
    function GetBuildKind: TProfileKind;
    function GetCaption: string;
    function GetLongBuildType: string;
    function IsDistributionBuildType: Boolean;
    function Update(const AProperties: TProjectProperties): Boolean;
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
  else if ABuildType.Equals('Development') then
    Result := 2
  else if ABuildType.Equals('DeveloperID') then
    Result := 3
  else
    Result := -1;
end;

procedure TProjectProperties.Clear;
begin
  BuildType := '';
  BundleIdentifier := '';
  Config := '';
  DeviceID := '';
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
    Result := TProfileKind.DeveloperID;
end;

function TProjectProperties.GetCaption: string;
begin
  Result := '';
  if not (Platform.IsEmpty or Config.IsEmpty) then
  begin
    Result := Platform + ' > ' + Config;
    if not BuildType.IsEmpty and not BuildType.Equals(Config) then
      Result := Result + ' > ' + GetLongBuildType;
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
    or not BuildType.Equals(AProperties.BuildType) or not BundleIdentifier.Equals(AProperties.BundleIdentifier) then
  begin
    Self := AProperties;
    Result := True;
  end;
end;

end.
