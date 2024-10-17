unit Codex.Mosco.Wizard;

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

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Types, System.DateUtils, System.Zip, System.StrUtils,
  ToolsAPI, PlatformAPI, CommonOptionStrs,
  DW.OSLog,
  // DW.Classes.Helpers,
  DW.Types.Helpers, DW.Base64.Helpers,
  DW.OTA.Wizard, DW.OTA.Helpers, DW.OTA.Consts, DW.OTA.Notifiers, DW.OTA.Registry, DW.OTA.Types, DW.OSDevice, DW.Vcl.DialogService,
  Mosco.API, Mosco.RESTClient,
  Codex.Config, Codex.Types, Codex.Core, Codex.Interfaces, Codex.Options, Codex.OTA.Helpers,
  Codex.Mosco.AddSDKFrameworkView, Codex.ProgressView,
  Codex.Mosco.ProjectManagerMenu, Codex.Mosco.Helpers, Codex.Mosco.Consts, Codex.Consts.Text, Codex.Consts;

type
  TFrameworkMode = (All, Linked);
  TProfilesProcess = (CheckProvisioning, SignLibraries);

  TMoscoWizard = class(TWizard, IMoscoProvider)
  private
    FAddSDKFrameworkView: TAddSDKFrameworkView;
    FCertCheckTime: TDateTime;
    FClient: TMoscoRESTClient;
    FFrameworkMode: TFrameworkMode;
    FIdentities: TIdentities;
    FIsCheckCertsPending: Boolean;
    FIsDeviceLocked: Boolean;
    FNeedsCheckProjectCerts: Boolean;
    // FProfilesProcess: TProfilesProcess;
    FProjectManagerMenuNotifier: ITOTALNotifier;
    FStartTime: TDateTime;
    procedure AddSDKFrameworkViewAddFrameworksHandler(Sender: TObject);
    procedure AddSDKFrameworkViewSDKSelectedHandler(Sender: TObject);
    procedure AddFrameworksToView(const AFrameworks: TArray<string>);
    // procedure AddLinkedFramework;
    function CanLaunch(const AProject: IOTAProject; const ADeviceID: string): Boolean;
    procedure CheckCerts;
    procedure CheckMoscoHost;
    procedure CheckProfile(const ABundleID: string; const ABuildTypeNumber: Integer);
    procedure CheckProjectCerts;
    // procedure CheckProvisioning;
    procedure Diagnostic(const AMsg: string);
    procedure DoAddSDKFramework(ASDKs: TArray<string>);
    procedure DoDeployIOSApp(const ATargetInfo: TTargetInfo);
    procedure DoDeployIOSAppResponse(const AResponse: IMoscoResponse);
    procedure DoGetAppExtensionFiles(const AFileNames: TArray<string>);
    procedure DoShowDeployedApp(const AProfile, AFileName: string);
    procedure DumpIdentities;
    procedure FetchCerts;
    // procedure FetchProfiles;
    // function FindIdentities(const ABundleId: string; const ABuildType: Integer; out AIdentities: TIdentities): Boolean;
    function FindIdentity(const ABuildType: Integer; out AIdentity: TIdentity): Boolean;
    procedure GetFrameworks(const ASDK: string);
    procedure GetLinkedFrameworks(const APaths: TStrings; var AFrameworks: TArray<string>);
    procedure GetModuleMapFrameworks(const AFileName: string; var AFrameworks: TArray<string>);
    procedure GetSDKs;
    procedure NotifyNoProfile;
    function SetConfigs(const AConfigs: IOTAProjectOptionsConfigurations; const APlatforms: TProjectPlatforms; const AKey, AValue: string): Boolean;
  protected
    procedure ConfigChanged; override;
    function DebuggerBeforeProgramLaunch(const Project: IOTAProject): Boolean; override;
    procedure IDEStarted; override;
    procedure PeriodicTimer; override;
    procedure ProjectChanged; override;
  public
    { IMoscoProvider }
    procedure AddSDKFramework;
    procedure DeployIOSApp;
    procedure GetAppExtensionFiles(const AFileNames: TArray<string>);
    function GetAppExtensionNames: TArray<string>;
    procedure ProfileChanged;
    procedure ShowDeployedApp;
    procedure ShowOptions;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

  TOTARemoteProfilePathArrayHelper = record helper for TOTARemoteProfilePathArray
  public
    function Add(const APath, AMask: string): Integer;
    function Count: Integer;
    function IndexOf(const APath, AMask: string): Integer;
  end;

{ TOTARemoteProfilePathArrayHelper }

function TOTARemoteProfilePathArrayHelper.Add(const APath, AMask: string): Integer;
begin
  Result := -1;
  if IndexOf(APath, AMask) = -1 then
  begin
    SetLength(Self, Count + 1);
    Result := Count - 1;
    Self[Result].Path := APath;
    Self[Result].MaskOrFramework := AMask;
    Self[Result].IncludeSubDir := False;
    Self[Result].DestinationDir := '';
    Self[Result].PathType := TOTARemotePathType.orptFramework;
  end;
end;

function TOTARemoteProfilePathArrayHelper.Count: Integer;
begin
  Result := Length(Self);
end;

function TOTARemoteProfilePathArrayHelper.IndexOf(const APath, AMask: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if Self[I].MaskOrFramework.Equals(AMask) and Self[I].Path.Equals(APath) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ TMoscoWizard }

constructor TMoscoWizard.Create;
begin
  inherited;
  MoscoProvider := Self;
  FClient := TMoscoRESTClient.Create;
  FProjectManagerMenuNotifier := TMoscoProjectManagerMenuNotifier.Create;
  ConfigChanged;
  FIsCheckCertsPending := True;
  TThread.CreateAnonymousThread(FetchCerts).Start;
end;

destructor TMoscoWizard.Destroy;
begin
  FClient.Free;
  FProjectManagerMenuNotifier.RemoveNotifier;
  FAddSDKFrameworkView.Free;
  inherited;
end;

procedure TMoscoWizard.Diagnostic(const AMsg: string);
begin
  if Config.Mosco.ErrorsDiagnostic then
    TCodexOTAHelper.AddMessage(AMsg, TTextColor.Warning, 'Mosco');
end;

function TMoscoWizard.CanLaunch(const AProject: IOTAProject; const ADeviceID: string): Boolean;
var
  LDone: Boolean;
begin
  Result := True;
  if TOTAHelper.IsIOSPlatform(AProject.CurrentPlatform) then
  begin
    LDone := False;
    // The following code may be introduced in a later version
{
    repeat
      LDone := False;
      Diagnostic('TMoscoWizard.CanLaunch CheckDeviceLocked');
      FDeviceCheck := Now;
      FClient.CheckDeviceLocked(LParts[1]);
      while (FDeviceCheck > 1) and (SecondsBetween(Now, FDeviceCheck) < 5) do
        Application.ProcessMessages;
      if FIsDeviceLocked then
        LDone := MessageDlg('Please unlock mobile device and click OK, or click Cancel to abort', TMsgDlgType.mtConfirmation, mbOKCancel, 0) = mrCancel;
    until not FIsDeviceLocked or LDone or (FClient.ClientState = TClientState.ConnectError);
}
    Result := not LDone;
  end;
  FIsDeviceLocked := False;
end;

function TMoscoWizard.DebuggerBeforeProgramLaunch(const Project: IOTAProject): Boolean;
var
  LDevice: string;
  LParts: TArray<string>;
  LCanLaunch: Boolean;
  LTargetInfo: TTargetInfo;
begin
  LDevice := TOTAHelper.GetProjectCurrentMobileDeviceName(Project);
  if not LDevice.IsEmpty then
    // Do not localize
    Diagnostic(Format('Current mobile device: %s', [LDevice]))
  else
    Diagnostic('Project device info is empty');
  while LDevice.StartsWith('_') do
    LDevice := LDevice.Substring(1);
  LParts := LDevice.Split(['_']);
  LCanLaunch := True;
  if Length(LParts) > 1 then
  begin
    LTargetInfo.DeviceID := LParts[1];
    LCanLaunch := CanLaunch(Project, LTargetInfo.DeviceID);
  end;
  Result := Config.Mosco.DisableLockCheck or LCanLaunch;
  if Result and not LTargetInfo.DeviceID.IsEmpty then
  begin
    LTargetInfo.Profile := TOTAHelper.GetProjectCurrentConnectionProfile(Project);
    LTargetInfo.FileName := TPath.ChangeExtension(TOTAHelper.GetProjectDeployedFileName(Project), '.app');
    FClient.NotifyLaunch(LTargetInfo);
  end;
end;

procedure TMoscoWizard.GetAppExtensionFiles(const AFileNames: TArray<string>);
begin
  TThread.CreateAnonymousThread(procedure begin DoGetAppExtensionFiles(AFileNames) end).Start;
end;

procedure TMoscoWizard.DoGetAppExtensionFiles(const AFileNames: TArray<string>);
var
  LProject: IOTAProject;
  LFileData, LDeployFolders: TArray<string>;
  LAppExName, LZipFileName, LPlugInsPath, LProjectFileName: string;
  I: Integer;
begin
  try
    if FClient.GetExtensionFiles(AFileNames, LFileData) then
    begin
      LProject := TOTAHelper.GetCurrentSelectedProject;
      if LProject <> nil then
      begin
        LPluginsPath := TPath.Combine(TPath.GetDirectoryName(LProject.FileName), 'PlugIns');
        ForceDirectories(LPlugInsPath);
        for I := 0 to Length(LFileData) - 1 do
        begin
          LAppExName := TPath.ChangeExtension(TPath.GetFileName(AFileNames[I]), '.appex');
          LZipFileName := TPath.Combine(TPath.GetTempPath, TPath.ChangeExtension(LAppExName, '.zip'));
          TOSLog.d('Decoding for: %s', [LAppExName]);
          TBase64Helper.DecodeDecompressToFile(LFileData[I], LZipFileName);
          TOSLog.d('Unzipping to: %s', [TPath.Combine(LPlugInsPath, LAppExName)]);
          TZipFile.ExtractZipFile(LZipFileName, TPath.Combine(LPlugInsPath, LAppExName));
          TFile.Delete(LZipFileName);
        end;
        LDeployFolders := TDirectory.GetDirectories(LPlugInsPath, '*', TSearchOption.soTopDirectoryOnly);
        TThread.Synchronize(nil, procedure begin ProjectToolsProvider.DeployAppExtensions(LDeployFolders) end);
      end
      else
        TCodexOTAHelper.AddMessage('CurrentSelectedProject is NIL!', TTextColor.Error, 'Mosco');
     end
    else
      TOSLog.d('FClient.GetExtensionFiles failed');
  except
    on E: Exception do
      TCodexOTAHelper.AddMessage(Format('%s - %s: %s', ['GetExtensionFiles', E.ClassName, E.Message]), TTextColor.Error, 'Mosco');
  end;
end;

procedure TMoscoWizard.IDEStarted;
begin
  inherited;
  FStartTime := Now;
//  FIsCheckCertsPending := True;
//  TThread.CreateAnonymousThread(FetchCerts).Start;
end;

procedure TMoscoWizard.NotifyNoProfile;
begin
  TCodexOTAHelper.AddMessage(Babel.Tx(sNoProvisioningProfile), TTextColor.Warning, 'Mosco');
end;

procedure TMoscoWizard.PeriodicTimer;
begin
  inherited;
  if Config.Mosco.CanRemind and (FStartTime > 0) and (SecondsBetween(Now, FStartTime) > 5) then
  begin
    FStartTime := 0;
    CheckMoscoHost;
  end;
end;

procedure TMoscoWizard.ShowOptions;
begin
  TConfigOptionsHelper.ShowOptions('Mosco');
end;

procedure TMoscoWizard.CheckProfile(const ABundleID: string; const ABuildTypeNumber: Integer);
var
  LProfile: TProfile;
begin
  TOSLog.d('Check profile for BundleID: %s, BuildTypeNumber: %d', [ABundleID, ABuildTypeNumber]);
  if FClient.GetProfile(ABundleID, ABuildTypeNumber, LProfile) and not LProfile.Exists then
    TThread.Synchronize(nil, NotifyNoProfile);
end;

function TMoscoWizard.FindIdentity(const ABuildType: Integer; out AIdentity: TIdentity): Boolean;
var
  LIdentity: TIdentity;
begin
  Result := False;
  for LIdentity in FIdentities do
  begin
    // Do not localize
    if ((ABuildType = 0) and LIdentity.Description.Contains('Mac Developer Installer')) or
      ((ABuildType = 2) and (LIdentity.Description.StartsWith('Apple Development') or LIdentity.Description.Contains('Mac Developer Application'))) then
    begin
      AIdentity := LIdentity;
      Result := True;
      Break;
    end;
  end;
end;

procedure TMoscoWizard.ProfileChanged;
begin
  ConfigChanged;
end;

function TMoscoWizard.SetConfigs(const AConfigs: IOTAProjectOptionsConfigurations; const APlatforms: TProjectPlatforms; const AKey,
  AValue: string): Boolean;
var
  LConfig, LPlatformConfig: IOTABuildConfiguration;
  I: Integer;
  LPlatform: TProjectPlatform;
begin
  Result := False;
  for I := 0 to AConfigs.ConfigurationCount - 1 do
  begin
    LConfig := AConfigs.Configurations[I];
    if LConfig.Name.Equals('Base') then
    begin
      for LPlatform := Low(TProjectPlatform) to High(TProjectPlatform) do
      begin
        if (LPlatform in APlatforms) and MatchText(cProjectPlatforms[LPlatform], LConfig.Platforms) then
        begin
          LPlatformConfig := LConfig.PlatformConfiguration[cProjectPlatforms[LPlatform]];
          if (LPlatformConfig <> nil) and LPlatformConfig.Value[AKey].IsEmpty then
          begin
            LPlatformConfig.Value[AKey] := AValue;
            Result := True;
          end;
        end;
      end;
    end;
  end;
end;

procedure TMoscoWizard.ProjectChanged;
var
  LBundleID: string;
begin
  if (TOTAHelper.GetProjectCurrentPlatform(TOTAHelper.GetActiveProject) in cAppleProjectPlatforms) and Config.Mosco.CanSend and Config.Mosco.CheckValidProfile then
  begin
    LBundleID := TCodexOTAHelper.GetActiveConfigVerInfoValue(TOTAHelper.GetActiveProject, 'CFBundleIdentifier');
    TThread.CreateAnonymousThread(procedure begin CheckProfile(LBundleID, ActiveProjectProperties.BuildTypeNumber) end).Start;
  end;
  if (FStartTime > 0) and not FIsCheckCertsPending then
    CheckProjectCerts
  else
    FNeedsCheckProjectCerts := True;
end;

procedure TMoscoWizard.CheckProjectCerts;
type
  TCertKind = (DevDebug, DevSandbox, Sandbox);
  TCertKinds = set of TCertKind;
var
  LConfigs: IOTAProjectOptionsConfigurations;
  LCertKindsUpdated: TCertKinds;
  LIdentity: TIdentity;
begin
  TOSLog.d('TMoscoWizard.CheckProjectCerts');
  FNeedsCheckProjectCerts := False;
  LConfigs := TOTAHelper.GetProjectOptionsConfigurations(TOTAHelper.GetActiveProject);
  if (LConfigs <> nil) and (ActiveProjectProperties.ProjectPlatform in cMacOSProjectPlatforms) and Config.Mosco.AutoFillMacCerts then
  begin
    // if Config.Mosco.ErrorsDiagnostic then
    //   DumpIdentities;
    LCertKindsUpdated := [];
    // It might find more than one - should allow a choice
    if FindIdentity(0, LIdentity) then
    begin
      if SetConfigs(LConfigs, cMacOSProjectPlatforms, sPF_SandBox, LIdentity.Description) then
        Include(LCertKindsUpdated, TCertKind.Sandbox);
    end
    else
      TCodexOTAHelper.AddMessage(Babel.Tx(sNoMacInstallerCert), TTextColor.Warning, 'Mosco');
    if FindIdentity(2, LIdentity) then
    begin
      if SetConfigs(LConfigs, cMacOSProjectPlatforms, sPF_DevSandBox, LIdentity.Description) then
        Include(LCertKindsUpdated, TCertKind.DevSandbox);
      if SetConfigs(LConfigs, cMacOSProjectPlatforms, sPF_MacDevelopmentCert, LIdentity.Description) then
        Include(LCertKindsUpdated, TCertKind.DevDebug);
    end
    else
      TCodexOTAHelper.AddMessage(Babel.Tx(sNoMacDeveloperCert), TTextColor.Warning, 'Mosco');
    if LCertKindsUpdated <> [] then
    begin
      if TCertKind.Sandbox in LCertKindsUpdated then
        TCodexOTAHelper.AddMessage(Babel.Tx(sUpdatedProjectInstallerCert), TTextColor.Warning, 'Mosco');
      if (TCertKind.DevSandbox in LCertKindsUpdated) or (TCertKind.DevDebug in LCertKindsUpdated) then
        TCodexOTAHelper.AddMessage(Babel.Tx(sUpdatedProjectDeveloperCert), TTextColor.Warning, 'Mosco');
      TOTAHelper.GetActiveProject.MarkModified;
      if Config.Mosco.ErrorsDiagnostic then
        Diagnostic('Certs changed: Marked project as modified');
    end;
  end;
end;

procedure TMoscoWizard.DoShowDeployedApp(const AProfile, AFileName: string);
var
  LTargetInfo: TTargetInfo;
begin
  LTargetInfo.Profile := AProfile;
  LTargetInfo.FileName := AFileName;
  TThread.CreateAnonymousThread(procedure begin FClient.ShowApp(LTargetInfo) end).Start;
end;

procedure TMoscoWizard.ShowDeployedApp;
var
  LProject: IOTAProject;
  LProfile, LFileName: string;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if LProject <> nil then
  begin
    LProfile := TOTAHelper.GetProjectCurrentConnectionProfile(LProject);
    LFileName := TOTAHelper.GetProjectDeployedFileName(LProject);
    DoShowDeployedApp(LProfile, LFileName);
  end;
end;

procedure TMoscoWizard.ConfigChanged;
begin
  inherited;
  if Config.Mosco.UseProfile then
    FClient.Host := TBDSRegistry.Current.GetDefaultRemoteProfileHost('OSX64')
  else
    FClient.Host := Config.Mosco.Host;
  FClient.Port := Config.Mosco.Port;
end;

procedure TMoscoWizard.AddSDKFramework;
begin
  FFrameworkMode := TFrameworkMode.All;
  TThread.CreateAnonymousThread(GetSDKs).Start;
end;

//procedure TMoscoWizard.AddLinkedFramework;
//begin
//  FFrameworkMode := TFrameworkMode.Linked;
//  TThread.CreateAnonymousThread(GetSDKs);
//end;

procedure TMoscoWizard.GetSDKs;
var
  LSDKs: TArray<string>;
begin
  try
    FClient.GetSDKs(LSDKs);
  finally
    TThread.Synchronize(nil, procedure begin DoAddSDKFramework(LSDKs) end);
  end
end;

procedure TMoscoWizard.DoAddSDKFramework(ASDKs: TArray<string>);
var
  LSDKs: TStrings;
  LPlatform, LSDK, LCurrentSDK: string;
  LProject: IOTAProject;
  LPlatformSDK: IOTAPlatformSDK;
  I: Integer;
begin
  if Length(ASDKs) > 0 then
  begin
    LPlatform := '';
    LCurrentSDK := '';
    LProject := TOTAHelper.GetCurrentSelectedProject;
    if LProject <> nil then
    begin
      LPlatform := LProject.CurrentPlatform;
      LPlatformSDK := (BorlandIDEServices as IOTAPlatformSDKServices).GetDefaultForPlatform(LPlatform);
      if LPlatformSDK <> nil then
        LCurrentSDK := LPlatformSDK.Name;
    end;
    if (FFrameworkMode = TFrameworkMode.Linked) and not LPlatform.IsEmpty then
    begin
      for I := Length(ASDKs) - 1 downto 0 do
      begin
        LSDK := ASDKs[I];
        if ((LPlatform.StartsWith('iOS', True) and not LSDK.StartsWith('iPhoneOS', True)) or
          ((LPlatform.StartsWith('macOS', True) and not LSDK.StartsWith('macOS', True)))) then
        begin
          Delete(ASDKs, I, 1);
        end;
      end;
    end;
    if FAddSDKFrameworkView = nil then
       FAddSDKFrameworkView := TAddSDKFrameworkView.Create(nil);
    FAddSDKFrameworkView.CurrentSDK := LCurrentSDK;
    LSDKs := TStringList.Create;
    try
      TBDSRegistry.Current.GetPlatformSDKs(LSDKs, True);
      FAddSDKFrameworkView.ImportedSDKs := LSDKs.ToStringArray;
    finally
      LSDKs.Free;
    end;
    FAddSDKFrameworkView.OnSDKSelected := AddSDKFrameworkViewSDKSelectedHandler;
    FAddSDKFrameworkView.OnAddFrameworks := AddSDKFrameworkViewAddFrameworksHandler;
    FAddSDKFrameworkView.AddSDKs(ASDKs);
    FAddSDKFrameworkView.ShowModal;
  end;
end;

procedure TMoscoWizard.AddSDKFrameworkViewSDKSelectedHandler(Sender: TObject);
var
  LSDK: string;
begin
  LSDK := FAddSDKFrameworkView.SelectedSDK;
  TThread.CreateAnonymousThread(procedure begin GetFrameworks(LSDK) end).Start;
end;

procedure TMoscoWizard.DoDeployIOSApp(const ATargetInfo: TTargetInfo);
var
  LResponse: IMoscoResponse;
begin
  LResponse := FClient.Execute(cAPIXcodeDeployIOS, ATargetInfo.ToJSON);
  TThread.Synchronize(nil, procedure begin DoDeployIOSAppResponse(LResponse); end);
end;

procedure TMoscoWizard.DoDeployIOSAppResponse(const AResponse: IMoscoResponse);
begin
  TCodexOTAHelper.HideWait;
  if AResponse.IsOK then
    TCodexOTAHelper.AddMessage(AResponse.StatusMessage, TTextColor.Success, 'Mosco')
  else
    TCodexOTAHelper.AddMessage(AResponse.StatusMessage, TTextColor.Warning, 'Mosco');
end;

procedure TMoscoWizard.DeployIOSApp;
var
  LProject: IOTAProject;
  LTargetInfo: TTargetInfo;
  LWaitCaption: string;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if LProject <> nil then
  begin
    LTargetInfo.User := TOSDevice.GetUsername;
    LTargetInfo.Profile := TOTAHelper.GetProjectCurrentConnectionProfile(LProject);
    LTargetInfo.FileName := TOTAHelper.GetProjectDeployedFileName(LProject);
    LTargetInfo.BuildKind := TProjectProperties.GetBuildTypeNumber(TOTAHelper.GetProjectCurrentBuildType(LProject));
    LTargetInfo.DeviceID := TOTAHelper.GetProjectCurrentMobileDeviceName(LProject);
    LWaitCaption := sRebuildInstalliOSApp;
    if LTargetInfo.BuildKind in [0, 1] then
      LWaitCaption := sRebuildIPA;
    TCodexOTAHelper.ShowWait(LWaitCaption);
    TThread.CreateAnonymousThread(procedure begin DoDeployIOSApp(LTargetInfo) end).Start;
  end;
end;

function TMoscoWizard.GetAppExtensionNames: TArray<string>;
begin
  FClient.GetExtensionNames(Result);
end;

procedure TMoscoWizard.GetFrameworks(const ASDK: string);
var
  LFrameworks, LValues, LExisting: TArray<string>;
  LFramework: string;
  I: Integer;
begin
  FClient.GetFrameworks(ASDK, LFrameworks);
  LValues.LoadText(LFrameworks.ToText(#13#10));
  for I := 0 to LValues.Count - 1 do
    LValues[I] := TPath.GetFileNameWithoutExtension(LValues[I]);
  LExisting := TBDSRegistry.Current.GetSDKFrameworks(FAddSDKFrameworkView.MatchingSDK);
  for I := LValues.Count - 1 downto 0 do
  begin
    LFramework := LValues[I];
    if LExisting.IndexOf(LFramework) > -1 then
      LValues.Delete(I);
  end;
  TThread.Synchronize(nil, procedure begin AddFrameworksToView(LValues); end);
end;

procedure TMoscoWizard.AddFrameworksToView(const AFrameworks: TArray<string>);
var
  LPaths: TStrings;
  LValidFrameworks: TArray<string>;
begin
  FAddSDKFrameworkView.AddFrameworks(AFrameworks);
  if FFrameworkMode = TFrameworkMode.Linked then
  begin
    LPaths := TStringList.Create;
    try
      GetLinkedFrameworks(LPaths, LValidFrameworks);
    finally
      LPaths.Free;
    end;
    FAddSDKFrameworkView.ValidateFrameworks(LValidFrameworks);
  end;
end;

procedure TMoscoWizard.AddSDKFrameworkViewAddFrameworksHandler(Sender: TObject);
var
  LView: TAddSDKFrameworkView;
  I: Integer;
  LAdded: Boolean;
  LFrameworkName, LSDKName: string;
  LPlatformSDK: IOTAPlatformSDKOSX;
  LServices: IOTAPlatformSDKServices;
  LPaths: TOTARemoteProfilePathArray;
begin
  LAdded := False;
  LView := TAddSDKFrameworkView(Sender);
  LSDKName := LView.MatchingSDK;
  LServices := BorlandIDEServices as IOTAPlatformSDKServices;
  if Supports(LServices.GetPlatformSDK(LSDKName), IOTAPlatformSDKOSX, LPlatformSDK) then
  begin
    LPaths := LPlatformSDK.Paths;
    for I := 0 to LView.FrameworksListBox.Items.Count - 1 do
    begin
      if LView.FrameworksListBox.Checked[I] then
      begin
        LFrameworkName := LView.FrameworksListBox.Items[I];
        if (LPaths.Add(cRegistryValuePathFrameworks, LFrameworkName) > -1) and
          TBDSRegistry.Current.AddSDKFramework(LSDKName, LFrameworkName, False) then
        begin
          LAdded := True;
        end;
      end;
    end;
    if LAdded then
    begin
      LPlatformSDK.Paths := LPaths;
      LServices.EditPlatformSDK(LSDKName);
      LView.CheckSelectedSDK(True);
    end
    else
      ProgressView.ShowStatic(Babel.Tx(sAddSDKFrameworksTitle), Babel.Tx(sNoFrameworksAdded));
  end
  else
    ProgressView.ShowStatic(Babel.Tx(sAddSDKFrameworksTitle), Format(Babel.Tx(sCannotObtainPlatformSDK), [LSDKName]));
end;

procedure TMoscoWizard.GetLinkedFrameworks(const APaths: TStrings; var AFrameworks: TArray<string>);
var
  I: Integer;
  LFileName: string;
begin
  AFrameworks.Clear;
  TWizard.GetEffectivePaths(APaths);
  for I := 0 to APaths.Count - 1 do
  begin
    if APaths[I].Contains('.framework') then
    begin
      LFileName := TPath.Combine(APaths[I], 'Modules\module.modulemap');
      if TFile.Exists(LFileName) then
        GetModuleMapFrameworks(LFileName, AFrameworks);
    end;
  end;
end;

procedure TMoscoWizard.GetModuleMapFrameworks(const AFileName: string; var AFrameworks: TArray<string>);
var
  I: Integer;
  LParts: TArray<string>;
  LText: TStringDynArray;
  LFramework: string;
begin
  LText.LoadText(TFile.ReadAllText(AFileName));
  for I := 0 to LText.Count - 1 do
  begin
    if LText[I].Trim.StartsWith('link framework') then
      TOSLog.d(LText[I].Trim);
    LParts := LText[I].Trim.Split([' ']);
    if (Length(LParts) >= 3) and LParts[0].ToLower.Equals('link') and LParts[1].ToLower.Equals('framework') then
    begin
      LFramework := AnsiDequotedStr(LParts[2], '"');
      AFrameworks.Add(LFramework, False);
    end;
  end;
end;

procedure TMoscoWizard.CheckMoscoHost;
begin
  // Show dialog that Mosco settings have not been established
end;

//procedure TMoscoWizard.CheckProvisioning;
//begin
//  FProfilesProcess := TProfilesProcess.CheckProvisioning;
//  FetchProfiles;
//end;

procedure TMoscoWizard.DumpIdentities;
var
  LIdentity: TIdentity;
begin
  if Length(FIdentities) > 0 then
    // Do not localize
    Diagnostic('Available identities:')
  else
    Diagnostic('No identities available');
  for LIdentity in FIdentities do
    Diagnostic(LIdentity.Description);
end;

procedure TMoscoWizard.FetchCerts;
begin
  FIdentities := [];
  try
    if FClient.CanSend then
      FClient.GetIdentities(FIdentities);
  finally
    TThread.Synchronize(nil, CheckCerts);
  end;
end;

procedure TMoscoWizard.CheckCerts;
var
  LIdentity: TIdentity;
  LWarnIdentities: TIdentities;
  LExpiry: string;
begin
  FCertCheckTime := Now;
  for LIdentity in FIdentities do
  begin
    if Trunc(LIdentity.Expiry) < IncDay(Trunc(Now), Config.Mosco.CertExpiryWarnDays)  then
      LWarnIdentities := LWarnIdentities + [LIdentity];
  end;
  for LIdentity in LWarnIdentities do
  begin
    LExpiry := FormatDateTime('mmm dd, yyyy',  LIdentity.Expiry);
    TCodexOTAHelper.AddMessage(Format(Babel.Tx(sCertExpiresOn), [LIdentity.Description, LExpiry]), TTextColor.Error, 'Mosco');
  end;
  FIsCheckCertsPending := False;
  if FNeedsCheckProjectCerts then
    CheckProjectCerts;
end;

initialization
  TOTAWizard.RegisterWizard(TMoscoWizard);

end.
