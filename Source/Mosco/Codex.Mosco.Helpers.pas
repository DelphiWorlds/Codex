unit Codex.Mosco.Helpers;

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
  System.Classes,
  DW.OTA.Registry;

type
  TBDSRegistryHelper = class helper for TBDSRegistry
  private
    function FindNextSDKFrameworkIndex(const AMask: string; const AKeys: TStrings): Integer;
  public
    function AddSDKFramework(const ASDKName, AFrameworkName: string; const AAllFiles: Boolean): Boolean;
    function GetDefaultRemoteProfileHost(const APlatform: string): string;
    function GetDefaultRemoteProfileName(const APlatform: string): string;
    procedure GetPlatformSDKs(const ASDKs: TStrings; const AAppleSDKsOnly: Boolean = False);
    procedure GetRemoteProfileNames(const AProfileNames: TStrings);
    function GetRemoteProfileValue(const AProfileName: string; const AKey: string): string;
    function GetSDKFrameworks(const ASDKName: string): TArray<string>;
    procedure SetDefaultProfile(const APlatform, AProfileName: string);
    procedure SetDefaultSDK(const APlatform, ASDKName: string);
  end;

implementation

uses
  System.SysUtils,
  DW.OTA.Helpers, DW.OTA.Consts,
  Codex.Mosco.Consts;

{ TBDSRegistryHelper }

procedure TBDSRegistryHelper.GetPlatformSDKs(const ASDKs: TStrings; const AAppleSDKsOnly: Boolean = False);
var
  I: Integer;
begin
  ReadKeys(cRegistryPathPlatformSDKs, ASDKs);
  if AAppleSDKsOnly then
  begin
    for I := ASDKs.Count - 1 downto 0 do
    begin
      if not (ASDKs[I].StartsWith('iPhone') or ASDKs[I].StartsWith('MacOS')) then
        ASDKs.Delete(I);
    end;
  end;
end;

function TBDSRegistryHelper.GetSDKFrameworks(const ASDKName: string): TArray<string>;
var
  LValueKeys: TStrings;
  I, LIndex: Integer;
  LKey, LFrameworkName: string;
begin
  if OpenSubKey(cRegistryPathPlatformSDKs + '\' + ASDKName, False) then
  try
    LValueKeys := TStringList.Create;
    try
      GetValueNames(LValueKeys);
      for I := 0 to LValueKeys.Count - 1 do
      begin
        LKey := LValueKeys[I];
        if LKey.StartsWith('Mask') and TryStrToInt(LKey.Substring(4), LIndex) then
        begin
          LFrameworkName := ReadString(LKey);
          LKey := 'Path' + LIndex.ToString;
          if ValueExists(LKey) and ReadString(LKey).EndsWith('/Frameworks') then
            Result := Result + [LFrameworkName];
        end;
      end;
    finally
      LValueKeys.Free;
    end;
  finally
    CloseKey;
  end;
end;

function TBDSRegistryHelper.GetDefaultRemoteProfileHost(const APlatform: string): string;
var
  LProfile: string;
begin
  Result := '';
  LProfile := GetDefaultRemoteProfileName(APlatform);
  if not LProfile.IsEmpty then
    Result := GetRemoteProfileValue(LProfile, 'HostName');
end;

function TBDSRegistryHelper.GetDefaultRemoteProfileName(const APlatform: string): string;
begin
  Result := ReadSubKeyString(cRegistryPathRemoteProfiles, 'Default_' + APlatform);
end;

procedure TBDSRegistryHelper.GetRemoteProfileNames(const AProfileNames: TStrings);
begin
  ReadKeys(cRegistryPathRemoteProfiles, AProfileNames);
end;

function TBDSRegistryHelper.GetRemoteProfileValue(const AProfileName, AKey: string): string;
begin
  Result := ReadSubKeyString(cRegistryPathRemoteProfiles + '\' + AProfileName, AKey);
end;

function TBDSRegistryHelper.FindNextSDKFrameworkIndex(const AMask: string; const AKeys: TStrings): Integer;
var
  LIncludeSubDirIndex, LMaskIndex, LPathIndex, LTypeIndex, I: Integer;
  LExists: Boolean;
begin
  Result := -1;
  LExists := False;
  for I := 0 to AKeys.Count - 1 do
  begin
    if AKeys[I].StartsWith(cRegistryValueKeyMask) and ReadString(AKeys[I]).Equals(AMask) then
    begin
      LExists := True;
      Break;
    end;
  end;
  if not LExists then
  begin
    LIncludeSubDirIndex := FindNextKeyIndex(AKeys, cRegistryValueKeyIncludeSubDir);
    LMaskIndex := FindNextKeyIndex(AKeys, cRegistryValueKeyMask);
    LPathIndex := FindNextKeyIndex(AKeys, cRegistryValueKeyPath);
    LTypeIndex := FindNextKeyIndex(AKeys, cRegistryValueKeyType);
    if (LIncludeSubDirIndex = LMaskIndex) and (LMaskIndex = LPathIndex) and (LPathIndex = LTypeIndex) then
      Result := LIncludeSubDirIndex;
  end;
end;

function TBDSRegistryHelper.AddSDKFramework(const ASDKName, AFrameworkName: string; const AAllFiles: Boolean): Boolean;
var
  LValueKeys: TStrings;
  LIndex: Integer;
begin
  Result := False;
  if OpenSubKey(cRegistryPathPlatformSDKs + '\' + ASDKName, False) then
  try
    LValueKeys := TStringList.Create;
    try
      GetValueNames(LValueKeys);
      LIndex := FindNextSDKFrameworkIndex(AFrameworkName, LValueKeys);
      if LIndex > -1 then
      begin
        WriteString(cRegistryValueKeyIncludeSubDir + LIndex.ToString, cRegistryValueIncludeSubDirValues[AAllFiles]);
        WriteString(cRegistryValueKeyMask + LIndex.ToString, AFrameworkName);
        WriteString(cRegistryValueKeyPath + LIndex.ToString, cRegistryValuePathFrameworks);
        WriteInteger(cRegistryValueKeyType + LIndex.ToString, cRegistryValueTypeFramework);
        Result := True;
      end;
    finally
      LValueKeys.Free;
    end;
  finally
    CloseKey;
  end;
end;

procedure TBDSRegistryHelper.SetDefaultProfile(const APlatform, AProfileName: string);
var
  I: Integer;
begin
  if OpenSubKey(cRegistryPathRemoteProfiles) then
  try
    if TOTAHelper.IsMacOSPlatform(APlatform) then
    begin
      for I := Low(cMacOSPlatformNames) to High(cMacOSPlatformNames) do
        WriteString('Default_' + cMacOSPlatformNames[I], AProfileName);
    end
    else
      WriteString('Default_' + APlatform, AProfileName);
  finally
    CloseKey;
  end;
end;

procedure TBDSRegistryHelper.SetDefaultSDK(const APlatform, ASDKName: string);
begin
  if OpenKey(cRegistryPathPlatformSDKs, False) then
  try
    WriteString('Default_' + APlatform, ASDKName);
  finally
    CloseKey;
  end;
end;

end.
