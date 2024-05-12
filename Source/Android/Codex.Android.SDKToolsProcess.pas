unit Codex.Android.SDKToolsProcess;

{*******************************************************}
{                                                       }
{                      Codex                            }
{                                                       }
{         Add-in for Delphi from Delphi Worlds          }
{                                                       }
{  Copyright 2020-2024 Dave Nottage under MIT license   }
{  which is located in the root folder of this library  }
{                                                       }
{*******************************************************}

interface

{$SCOPEDENUMS ON}

uses
  System.Classes,
  DW.RunProcess.Win;

type
  TSDKToolsStep = (None, Fetch, Install);
  TSDKOutputSection = (None, InstalledPackages, AvailablePackages, AvailableUpdates);

  TSDKPackageKind = (Unsupported, APILevel, Emulator, SystemImage);

  TSDKPackageItem = record
    Kind: TSDKPackageKind;
    Description: string;
    IsInstalled: Boolean;
    Package: string;
    Version: string;
  end;

  TSDKPackageItems = TArray<TSDKPackageItem>;

  TInstallProgressEvent = procedure(Sender: TObject; const Percent: Integer) of object;

  TSDKToolsProcess = class(TRunProcess)
  private
    FSDKFolder: string;
    FSDKOutputSection: TSDKOutputSection;
    FSDKToolsStep: TSDKToolsStep;
    FPackages: TSDKPackageItems;
    FOnInstallProgress: TInstallProgressEvent;
    FOnStepComplete: TNotifyEvent;
    procedure DoInstallProgress(const APercent: Integer);
    procedure DoStepComplete;
    procedure ParseSDKOutput(const AOutput: string);
    procedure ParseSDKPartialOutput(const AOutput: string);
    procedure ParsePackage(const AOutput: string; const AIsInstalled: Boolean);
  protected
    procedure DoOutput(const AOutput: string); override;
    procedure DoPartialOutput(const AOutput: string); override;
    procedure DoTerminated(const AExitCode: Cardinal); override;
  public
    procedure FetchPackages;
    procedure InstallAPILevels(const AAPILevels: TArray<string>);
    property Packages: TSDKPackageItems read FPackages;
    property SDKToolsStep: TSDKToolsStep read FSDKToolsStep;
    property SDKFolder: string read FSDKFolder write FSDKFolder;
    property OnInstallProgress: TInstallProgressEvent read FOnInstallProgress write FOnInstallProgress;
    property OnStepComplete: TNotifyEvent read FOnStepComplete write FOnStepComplete;
  end;

implementation

uses
  System.SysUtils, System.IOUtils,
  DW.OSLog;

const
  cSDKManagerCommand = 'cmd.exe /C %s\%s\bin\sdkmanager'; // <----- DO NOT USE QUOTES
  cSDKManagerSDKRootParam = ' --sdk_root="%s"';
  cSDKManagerParamsList = ' --list' + cSDKManagerSDKRootParam;
  cSDKPackageEmulator = 'emulator';
  cSDKPackagePlatforms = 'platforms';
  cSDKPackageSystemImages = 'system-images';
  cSDKOutputAvailablePackages = 'Available Packages:';
  cSDKOutputAvailableUpdates = 'Available Updates:';
  cSDKOutputInstalledPackages = 'Installed Packages:';
  cSDKInstallPlatformParam = '"' + cSDKPackagePlatforms + ';%s"';
  cSDKAcceptPromptPrefix = 'Accept? (';
  cSDKCmdLineToolsFolder = 'cmdline-tools';

type
  TSDKPackageItemsHelper = record helper for TSDKPackageItems
    procedure Add(const AItem: TSDKPackageItem);
    function IndexOf(const AItem: TSDKPackageItem): Integer;
  end;

{ TSDKPackageItemsHelper }

procedure TSDKPackageItemsHelper.Add(const AItem: TSDKPackageItem);
begin
  if IndexOf(AItem) = -1 then
    Self := Self + [AItem];
end;

function TSDKPackageItemsHelper.IndexOf(const AItem: TSDKPackageItem): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(Self) do
  begin
    if Self[I].Package.Equals(AItem.Package) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ TSDKToolsProcess }

procedure TSDKToolsProcess.DoInstallProgress(const APercent: Integer);
begin
  if Assigned(FOnInstallProgress) then
    FOnInstallProgress(Self, APercent);
end;

procedure TSDKToolsProcess.DoOutput(const AOutput: string);
var
  LOutput: string;
begin
  LOutput := AOutput.Trim;
  case FSDKToolsStep of
    TSDKToolsStep.Fetch:
      ParseSDKOutput(LOutput);
  end;
  // TOSLog.d(AOutput);
end;

procedure TSDKToolsProcess.DoPartialOutput(const AOutput: string);
begin
  case FSDKToolsStep of
    TSDKToolsStep.Install:
      ParseSDKPartialOutput(AOutput);
  end;
end;

procedure TSDKToolsProcess.DoStepComplete;
begin
  if Assigned(FOnStepComplete) then
    FOnStepComplete(Self);
end;

procedure TSDKToolsProcess.DoTerminated(const AExitCode: Cardinal);
begin
  case FSDKToolsStep of
    TSDKToolsStep.Fetch:
      DoStepComplete;
    TSDKToolsStep.Install:
      DoStepComplete;
  end;
end;

procedure TSDKToolsProcess.ParseSDKPartialOutput(const AOutput: string);
var
  LPercent: Integer;
  LParts: TArray<string>;
begin
  if AOutput.Contains(cSDKAcceptPromptPrefix) then
  begin
    TOSLog.d('> Responding to prompt');
    Write('y')
  end
  else if AOutput.StartsWith('[') and AOutput.Contains('] ') then
  begin
    LParts := AOutput.Split([']'], 2);
    if Length(LParts) = 2 then
    begin
      LParts := LParts[1].Trim.Split([' ']); // Space after %
      if (Length(LParts) > 0) and TryStrToInt(LParts[0].Trim(['%']), LPercent) then
        DoInstallProgress(LPercent);
    end;
  end;
end;

procedure TSDKToolsProcess.ParseSDKOutput(const AOutput: string);
begin
  if AOutput.Trim.StartsWith(cSDKOutputInstalledPackages, True) then
    FSDKOutputSection := TSDKOutputSection.InstalledPackages
  else if AOutput.Trim.StartsWith(cSDKOutputAvailablePackages, True) then
    FSDKOutputSection := TSDKOutputSection.AvailablePackages
  else if AOutput.Trim.StartsWith(cSDKOutputAvailableUpdates, True) then
    FSDKOutputSection := TSDKOutputSection.AvailablePackages
  else
  begin
    case FSDKOutputSection of
      TSDKOutputSection.InstalledPackages:
      begin
        if AOutput.IndexOf(';') > 0 then
          ParsePackage(AOutput, True);
      end;
      TSDKOutputSection.AvailablePackages:
      begin
        if AOutput.IndexOf(';') > 0 then
          ParsePackage(AOutput, False);
      end;
    end;
  end;
end;

procedure TSDKToolsProcess.ParsePackage(const AOutput: string; const AIsInstalled: Boolean);
var
  LParts: TArray<string>;
  LValue: Integer;
  LItem: TSDKPackageItem;
begin
  LItem.IsInstalled := AIsInstalled;
  LParts := AOutput.Split(['|']);
  if Length(LParts) > 0 then
  begin
    LItem.Package := LParts[0].Trim;
    if Length(LParts) > 1 then
      LItem.Version := LParts[1].Trim;
    if Length(LParts) > 2 then
      LItem.Description := LParts[2].Trim;
  end;
  LParts := LItem.Package.Split([';']);
  if Length(LParts) > 1 then
  begin
    if LParts[0].Equals(cSDKPackagePlatforms) then
      LItem.Kind := TSDKPackageKind.APILevel
    else if LParts[0].Equals(cSDKPackageSystemImages) then
      LItem.Kind := TSDKPackageKind.SystemImage
    else if LParts[0].Equals(cSDKPackageEmulator) then
      LItem.Kind := TSDKPackageKind.Emulator
    else
      LItem.Kind := TSDKPackageKind.Unsupported;
    if LItem.Kind = TSDKPackageKind.APILevel then
    begin
      LParts := LParts[1].Split(['-'], 2);
      LValue := 0;
      if Length(LParts) = 2 then
        LValue := StrToIntDef(LParts[1], 0);
      if (LValue > 0) and (LValue < 19) then
        LItem.Kind := TSDKPackageKind.Unsupported;
    end;
    if LItem.Kind <> TSDKPackageKind.Unsupported then
      FPackages.Add(LItem);
  end;
end;

procedure TSDKToolsProcess.FetchPackages;
begin
  FSDKToolsStep := TSDKToolsStep.Fetch;
  FSDKOutputSection := TSDKOutputSection.None;
  FPackages := [];
  CommandLine := Format(cSDKManagerCommand + cSDKManagerParamsList, [FSDKFolder, cSDKCmdLineToolsFolder, FSDKFolder]);
  TOSLog.d('Packages command:');
  TOSLog.d(CommandLine);
  Run;
end;

procedure TSDKToolsProcess.InstallAPILevels(const AAPILevels: TArray<string>);
var
  LAPILevel: string;
  LParams: TArray<string>;
begin
  FSDKToolsStep := TSDKToolsStep.Install;
  for LAPILevel in AAPILevels do
    LParams := LParams + [Format(cSDKInstallPlatformParam, [LAPILevel])];
  CommandLine := Format(cSDKManagerCommand + cSDKManagerSDKRootParam, [FSDKFolder, cSDKCmdLineToolsFolder, FSDKFolder])
    + ' ' + string.Join(' ', LParams);
  TOSLog.d('Install command:');
  TOSLog.d(CommandLine);
  Run;
end;

end.
