unit Codex.Android.GenerateAppProcess;

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
  DW.RunProcess.Win;

type
  TGenerateAppStage = (None, BuildAPK, Package, Compile, Link, BuildBundle, SignBundle, BuildComplete, BuildAPKs,
    InstallAPKs, ExtractAPKs, InstallComplete);

  TGenerateAppOutputEvent = procedure(Sender: TObject; const Output: string) of object;
  TGenerateAppResultEvent = procedure(Sender: TObject; const Stage: TGenerateAppStage; const ExitCode: Cardinal) of object;

  TGenerateAppProcess = class(TObject)
  private
    FADBPath: string;
    FAPILevelPath: string;
    // FAPKFileName: string; // warning
    FAPKsFileName: string;
    FBuildPath: string;
    FBuildToolsPath: string;
    FBundleFileName: string;
    FBundleToolPath: string;
    FDeployedAppPath: string;
    FJarSignerExePath: string;
    FJavaExePath: string;
    FJDKPath: string;
    FKeyStoreAliasPass: string;
    FKeyStoreAlias: string;
    FKeyStoreFileName: string;
    FKeyStorePass: string;
    FProjectName: string;
    FRunProcess: TRunProcess;
    FStage: TGenerateAppStage;
    FOnOutput: TGenerateAppOutputEvent;
    FOnResult: TGenerateAppResultEvent;
    procedure CheckFilePath(const AFileName: string; var ASuccess: Boolean);
    function CheckFilePaths: Boolean;
    function CheckFolder(const AFolder: string): Boolean;
    procedure DoOutput(const AOutput: string);
    procedure DoResult(const AExitCode: Cardinal);
    procedure ExtractAPKs;
    function GetBuildToolPath(const ATool: string): string;
    procedure InstallAPKs;
    procedure NoDeviceConnected;
    procedure RunProcessTerminatedHandler(Sender: TObject; const AExitCode: Cardinal);
    procedure RunProcessOutputHandler(Sender: TObject; const AOutput: string);
    // procedure SetJavaPath(const Value: string);
    procedure SignBundle;
    procedure SetJDKPath(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    function BuildAPK(const AProjectName, ADeployedAppPath: string): Boolean;
    function BuildBundle(const AProjectName, ADeployedAppPath: string; const AAssetPacks: TArray<string>): Boolean;
    function Extract(const ABundleFileName, AExtractPath: string): Boolean;
    procedure Install(const ABundleFileName: string = '');
    function IsKeyStoreValid: Boolean;
    property APILevelPath: string read FAPILevelPath write FAPILevelPath;
    property ADBPath: string read FADBPath write FADBPath;
    property BundleToolPath: string read FBundleToolPath write FBundleToolPath;
    property JDKPath: string read FJDKPath write SetJDKPath;
    property KeyStoreAlias: string read FKeyStoreAlias write FKeyStoreAlias;
    property KeyStoreAliasPass: string read FKeyStoreAliasPass write FKeyStoreAliasPass;
    property KeyStoreFileName: string read FKeyStoreFileName write FKeyStoreFileName;
    property KeyStorePass: string read FKeyStorePass write FKeyStorePass;
    property OnOutput: TGenerateAppOutputEvent read FOnOutput write FOnOutput;
    property OnResult: TGenerateAppResultEvent read FOnResult write FOnResult;
  end;

implementation

uses
  DW.OSLog,
  System.Zip, System.IOUtils, System.SysUtils,
  DW.IOUtils.Helpers, DW.OTA.Helpers,
  Codex.Core, Codex.Consts.Text;

const
  cBuildBundleCommandLine = '"%s" -jar "%s" build-bundle --modules=%s --output "%s"';
  cSignBundleCommandLine = '"%s" -keystore "%s" -storepass %s -keypass %s "%s" %s';
  cBuildAPKsCommandLine = '"%s" -jar "%s" build-apks --bundle="%s" --output="%s" --ks "%s" --key-pass=pass:%s --ks-pass=pass:%s --ks-key-alias=%s --local-testing';
  cExtractAPKsCommandLine = '"%s" -jar "%s" build-apks --bundle="%s" --output="%s" --ks "%s" --key-pass=pass:%s --ks-pass=pass:%s --ks-key-alias=%s --mode=universal';
  cInstallAPKsCommandLine = '"%s" -jar "%s" install-apks --apks="%s" --device-id=%s --adb %s';
  cAAPTPackageCommand = '%s package --auto-add-overlay -f -m -I %s\android.jar -M %s\AndroidManifest.xml -S %s\res -J %s\src';
  cAAPT2CompileCommand = '%s compile --dir %s\res -o %s\compiled_res.flata';
  cAAPT2LinkCommand = '%s link --auto-add-overlay -I %s\android.jar --manifest %s\AndroidManifest.xml -R %s\compiled_res.flata ' +
    '-o %s\linked_res.ap_ --java %s\src';

  cDeployedAppBinFolder = 'bin';
  cDeployedAppBaseFolder = 'base';

  cJavaExeName = 'java.exe';
  cJarSignerExeName = 'jarsigner.exe';

{ TGenerateAppProcess }

constructor TGenerateAppProcess.Create;
begin
  inherited;
  FRunProcess := TRunProcess.Create;
  FRunProcess.OnProcessTerminated := RunProcessTerminatedHandler;
  FRunProcess.OnProcessOutput := RunProcessOutputHandler;
end;

destructor TGenerateAppProcess.Destroy;
begin
  FRunProcess.Free;
  inherited;
end;

procedure TGenerateAppProcess.DoOutput(const AOutput: string);
begin
  if Assigned(FOnOutput) then
    FOnOutput(Self, AOutput);
end;

procedure TGenerateAppProcess.DoResult(const AExitCode: Cardinal);
begin
  if Assigned(FOnResult) then
    FOnResult(Self, FStage, AExitCode);
end;

function TGenerateAppProcess.IsKeyStoreValid: Boolean;
begin
  Result := not FKeyStoreAliasPass.Trim.IsEmpty and not FKeyStoreAlias.Trim.IsEmpty and not FKeyStorePass.Trim.IsEmpty
    and TFile.Exists(FKeyStoreFileName);
end;

procedure TGenerateAppProcess.NoDeviceConnected;
begin
  DoOutput(Babel.Tx(sCannotInstallNoDevice));
  DoResult(666);
end;

function TGenerateAppProcess.CheckFolder(const AFolder: string): Boolean;
begin
  if not TDirectoryHelper.Exists(AFolder) then
  begin
    Result := False;
    DoOutput(Format(Babel.Tx(sFileNoExist), [AFolder]));
  end
  else
    Result := True;
end;

procedure TGenerateAppProcess.CheckFilePath(const AFileName: string; var ASuccess: Boolean);
begin
  if not TFile.Exists(AFileName) then
  begin
    ASuccess := False;
    DoOutput(Format(Babel.Tx(sFileNoExist), [AFileName]));
  end;
end;

function TGenerateAppProcess.CheckFilePaths: Boolean;
begin
  Result := True;
  FJarSignerExePath := TPath.Combine(FJDKPath, cJarSignerExeName);
  FJavaExePath := TPath.Combine(FJDKPath, cJavaExeName);
  CheckFilePath(FJarSignerExePath, Result);
  CheckFilePath(FJavaExePath, Result);
  CheckFilePath(FBundleToolPath, Result);
  CheckFilePath(FADBPath, Result);
end;

function TGenerateAppProcess.GetBuildToolPath(const ATool: string): string;
begin
  Result := TPath.Combine(FBuildToolsPath, ATool);
end;

function TGenerateAppProcess.BuildAPK(const AProjectName, ADeployedAppPath: string): Boolean;
begin
  Result := False;
  FStage := TGenerateAppStage.None;
  if CheckFilePaths and CheckFolder(ADeployedAppPath) then
  begin
    FBuildPath := TPath.Combine(ADeployedAppPath, 'build');
    ForceDirectories(FBuildPath);
    FStage := TGenerateAppStage.Package;
    FRunProcess.CommandLine := Format(cAAPTPackageCommand, [GetBuildToolPath('aapt.exe'), FAPILevelPath, FBundleToolPath,
      TPath.Combine(ADeployedAppPath, 'res'), FBuildPath]);
    TOSLog.d('Build APK (Package): ' + FRunProcess.CommandLine);
    FRunProcess.Run;
    Result := True;
  end;
end;

function TGenerateAppProcess.BuildBundle(const AProjectName, ADeployedAppPath: string; const AAssetPacks: TArray<string>): Boolean;
var
  LModuleFileNames: TArray<string>;
  LBaseZipFileName, LModules, LBaseFolder: string;
  I: Integer;
begin
  Result := False;
  FStage := TGenerateAppStage.None;
  if CheckFilePaths and CheckFolder(ADeployedAppPath) then
  begin
    FDeployedAppPath := ADeployedAppPath;
    FProjectName := AProjectName;
    LBaseZipFileName := TPath.Combine(ADeployedAppPath, 'BaseModule.zip');
    LBaseFolder := TPath.Combine(ADeployedAppPath, cDeployedAppBaseFolder);
    if TDirectory.Exists(LBaseFolder) then
      TZipFile.ZipDirectoryContents(LBaseZipFileName, LBaseFolder);
    if TFile.Exists(LBaseZipFileName) then
    begin
      LModuleFileNames := AAssetPacks + [LBaseZipFileName];
      for I := 0 to Length(LModuleFileNames) - 1 do
        LModuleFileNames[I] := LModuleFileNames[I].QuotedString('"');
      LModules := string.Join(',', LModuleFileNames);
      FBundleFileName := TPath.Combine(TPath.Combine(FDeployedAppPath, cDeployedAppBinFolder), FProjectName + '.aab');
      if TFile.Exists(FBundleFileName) then
        TFile.Delete(FBundleFileName);
      FStage := TGenerateAppStage.BuildBundle;
      FRunProcess.CommandLine := Format(cBuildBundleCommandLine, [FJavaExePath, FBundleToolPath, LModules, FBundleFileName]);
      TOSLog.d('Build Bundle: ' + FRunProcess.CommandLine);
      FRunProcess.Run;
      Result := True;
    end
    else
      TOTAHelper.AddTitleMessage(Babel.Tx(sCheckConfigAndDeployed), 'Codex');
  end;
end;

function TGenerateAppProcess.Extract(const ABundleFileName, AExtractPath: string): Boolean;
begin
  Result := False;
  FStage := TGenerateAppStage.None;
  if CheckFilePaths then
  begin
    Result := True;
    CheckFilePath(ABundleFileName, Result);
    if Result then
    begin
      FBundleFileName := ABundleFileName;
      FAPKsFileName := TPath.Combine(AExtractPath, TPath.ChangeExtension(TPath.GetFileName(FBundleFileName), '.apks'));
      if TFile.Exists(FAPKsFileName) then
        TFile.Delete(FAPKsFileName);
      // TOSLog.d('Extract from %s to %s', [FBundleFileName, FAPKsFileName]);
      ExtractAPKs;
    end;
  end;
end;

procedure TGenerateAppProcess.RunProcessOutputHandler(Sender: TObject; const AOutput: string);
begin
  // Do not output signing stage - it has a warning that might be off-putting to users
  if FStage <> TGenerateAppStage.SignBundle then
    DoOutput(AOutput);
end;

procedure TGenerateAppProcess.RunProcessTerminatedHandler(Sender: TObject; const AExitCode: Cardinal);
begin
  case FStage of
    TGenerateAppStage.BuildBundle:
    begin
      if AExitCode = 0 then
        SignBundle
      else
        DoResult(AExitCode);
    end;
    TGenerateAppStage.SignBundle:
    begin
      if AExitCode = 0 then
        FStage := TGenerateAppStage.BuildComplete;
      DoResult(AExitCode);
    end;
    TGenerateAppStage.BuildAPKs:
    begin
      if AExitCode = 0 then
        InstallAPKs
      else
        DoResult(AExitCode);
    end;
    TGenerateAppStage.InstallAPKs:
    begin
      if AExitCode = 0 then
        FStage := TGenerateAppStage.InstallComplete;
      DoResult(AExitCode);
    end;
    TGenerateAppStage.ExtractAPKs:
    begin
      if AExitCode = 0 then
        FStage := TGenerateAppStage.InstallComplete;
      DoResult(AExitCode);
    end;
  end;
end;

//procedure TGenerateAppProcess.SetJavaPath(const Value: string);
//begin
//  FJavaExePath := '';
//  FJarSignerExePath := '';
//  FJDKPath := Value;
//end;

procedure TGenerateAppProcess.SetJDKPath(const Value: string);
begin
  FJDKPath := Value;
  FJavaExePath := TPath.Combine(FJDKPath, 'java.exe');
end;

procedure TGenerateAppProcess.SignBundle;
begin
  FStage := TGenerateAppStage.SignBundle;
  FRunProcess.CommandLine :=
    Format(cSignBundleCommandLine, [FJarSignerExePath, FKeyStoreFileName, FKeyStoreAliasPass, FKeyStorePass, FBundleFileName, FKeyStoreAlias]);
  TOSLog.d('Sign Bundle: ' + FRunProcess.CommandLine);
  FRunProcess.Run;
end;

procedure TGenerateAppProcess.Install(const ABundleFileName: string = '');
begin
  if not ABundleFileName.IsEmpty then
    FBundleFileName := ABundleFileName;
  FStage := TGenerateAppStage.BuildAPKs;
  FAPKsFileName := TPath.ChangeExtension(FBundleFileName, '.apks');
  if TFile.Exists(FAPKsFileName) then
    TFile.Delete(FAPKsFileName);
  FRunProcess.CommandLine := Format(cBuildAPKsCommandLine, [FJavaExePath, FBundleToolPath, FBundleFileName, FAPKsFileName, FKeyStoreFileName,
    FKeyStoreAliasPass, FKeyStorePass, FKeyStoreAlias]);
  TOSLog.d('Build APKs: ' + FRunProcess.CommandLine);
  FRunProcess.Run;
end;

procedure TGenerateAppProcess.ExtractAPKs;
begin
  FStage := TGenerateAppStage.ExtractAPKs;
  FRunProcess.CommandLine := Format(cExtractAPKsCommandLine, [FJavaExePath, FBundleToolPath, FBundleFileName, FAPKsFileName, FKeyStoreFileName,
    FKeyStoreAliasPass, FKeyStorePass, FKeyStoreAlias]);
  TOSLog.d('Extract APKs: ' + FRunProcess.CommandLine);
  FRunProcess.Run;
end;

procedure TGenerateAppProcess.InstallAPKs;
var
  LSerial: string;
begin
  LSerial := TOTAHelper.GetProjectCurrentMobileDeviceName(TOTAHelper.GetActiveProject);
  if not LSerial.IsEmpty then
  begin
    FStage := TGenerateAppStage.InstallAPKs;
    FRunProcess.CommandLine := Format(cInstallAPKsCommandLine, [FJavaExePath, FBundleToolPath, FAPKsFileName, LSerial, FADBPath]);
    TOSLog.d('Install APKs: ' + FRunProcess.CommandLine);
    FRunProcess.Run;
  end
  else
    NoDeviceConnected;
end;

end.
