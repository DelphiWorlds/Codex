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
  System.SysUtils, System.Classes, System.IOUtils, System.Types, System.DateUtils,
  ToolsAPI, PlatformAPI, CommonOptionStrs,
  DW.OSLog,
  DW.Classes.Helpers, DW.Types.Helpers,
  DW.OTA.Wizard, DW.OTA.Helpers, DW.OTA.Consts, DW.OTA.Notifiers, DW.OTA.Registry,
  Mosco.API, Mosco.RESTClient,
  Codex.Config, Codex.Types, Codex.Core, Codex.Interfaces, Codex.Options,
  Codex.Mosco.AddSDKFrameworkView, Codex.ProgressView,
  Codex.Mosco.ProjectManagerMenu, Codex.Mosco.Helpers, Codex.Mosco.Consts;

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
    FIsDeviceLocked: Boolean;
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
    procedure CheckProfile(const ABundleId: string; const ABuildType: Integer);
    // procedure CheckProvisioning;
    procedure Diagnostic(const AMsg: string);
    procedure DoAddSDKFramework(ASDKs: TArray<string>);
    procedure DoShowDeployedApp(const AProfile, AFileName: string);
    procedure DumpIdentities;
    procedure FetchCerts;
    // procedure FetchProfiles;
    function FindIdentity(const ABundleId: string; const ABuildType: Integer; out AIdentity: TIdentity): Boolean;
    procedure GetFrameworks(const ASDK: string);
    procedure GetLinkedFrameworks(const APaths: TStrings; var AFrameworks: TArray<string>);
    procedure GetModuleMapFrameworks(const AFileName: string; var AFrameworks: TArray<string>);
    procedure GetSDKs;
  protected
    procedure ConfigChanged; override;
    function DebuggerBeforeProgramLaunch(const Project: IOTAProject): Boolean; override;
    procedure IDEStarted; override;
    procedure PeriodicTimer; override;
    procedure ProjectChanged; override;
  public
    { IMoscoProvider }
    procedure AddSDKFramework;
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

resourcestring
  sAddSDKFrameworksTitle = 'Add SDK Frameworks';
  sCannotObtainPlatformSDK = 'Unable to obtain platform SDK for %s';
  sCertExpiresOn = '%s certificate expires/expired on: %s';
  sNoFrameworksAdded = 'No frameworks added. Either they already exist, or errors occurred';
  sNoMacDeveloperCert = 'You do not appear to have a macOS developer certificate';
  sNoMacInstallerCert = 'You do not appear to have a macOS installer certificate';
  sNoProvisioningProfile = 'There does not appear to be a matching provisioning profile for this project';
  sUpdatedProjectInstallerCert = 'Updated project macOS installer certificate';
  sUpdatedProjectDeveloperCert = 'Updated project macOS developer certificate';

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
  TOTAHelper.RegisterThemeForms([TAddSDKFrameworkView]);
  FClient := TMoscoRESTClient.Create;
  FProjectManagerMenuNotifier := TMoscoProjectManagerMenuNotifier.Create;
  ConfigChanged;
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
    TOTAHelper.AddTitleMessage(AMsg, 'Mosco');
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

procedure TMoscoWizard.IDEStarted;
begin
  inherited;
  FStartTime := Now;
  TDo.Run(FetchCerts);
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

procedure TMoscoWizard.CheckProfile(const ABundleId: string; const ABuildType: Integer);
var
  LProfile: TProfile;
begin
  if FClient.GetProfile(ABundleId, ABuildType, LProfile) and not LProfile.Exists then
  begin
    TDo.SyncMain(
      procedure
      begin
        TOTAHelper.AddTitleMessage(Babel.Tx(sNoProvisioningProfile), 'Mosco');
      end
    );
  end;
end;

function TMoscoWizard.FindIdentity(const ABundleId: string; const ABuildType: Integer; out AIdentity: TIdentity): Boolean;
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

procedure TMoscoWizard.ProjectChanged;
var
  LProperties: TProjectProperties;
  LBuildTypeNumber: Integer;
  LProject: IOTAProject;
  LConfigs: IOTAProjectOptionsConfigurations;
  LBaseConfig: IOTABuildConfiguration;
  LIdentity: TIdentity;
begin
  LProperties := ActiveProjectProperties;
  LBuildTypeNumber := TProjectProperties.GetBuildTypeNumber(LProperties.BuildType);
  // For App Store
  if LBuildTypeNumber = 0 then
  begin
    LProject := TOTAHelper.GetActiveProject;
    if LProject <> nil then
    begin
      LConfigs := TOTAHelper.GetProjectOptionsConfigurations(LProject);
      if LConfigs <> nil then
        LBaseConfig := LConfigs.BaseConfiguration;
      if (TOTAHelper.GetProjectCurrentPlatform(LProject) in cAppleProjectPlatforms) and Config.Mosco.CanSend and Config.Mosco.CheckValidProfile then
        TDo.Run(procedure begin CheckProfile(LProperties.BundleIdentifier, LBuildTypeNumber) end);
      // Fill out cert info, if missing
      if LProperties.Platform.StartsWith('macOS') then
      begin
        if Config.Mosco.ErrorsDiagnostic then
          DumpIdentities;
        if FindIdentity(LProperties.BundleIdentifier, 0, LIdentity) then
        begin
          if Config.Mosco.AutoFillMacCerts and (LBaseConfig <> nil) and LBaseConfig.Value[sPF_SandBox].IsEmpty then
          begin
            LBaseConfig.Value[sPF_SandBox] := LIdentity.Description;
            TOTAHelper.AddTitleMessage(Babel.Tx(sUpdatedProjectInstallerCert), 'Mosco');
            TOTAHelper.MarkCurrentModuleModified;
          end;
        end
        else
          TOTAHelper.AddTitleMessage(Babel.Tx(sNoMacInstallerCert), 'Mosco');
        if FindIdentity(LProperties.BundleIdentifier, 2, LIdentity) then
        begin
          if Config.Mosco.AutoFillMacCerts and (LBaseConfig <> nil) and LBaseConfig.Value[sPF_DevSandBox].IsEmpty then
          begin
            LBaseConfig.Value[sPF_DevSandBox] := LIdentity.Description;
            TOTAHelper.AddTitleMessage(Babel.Tx(sUpdatedProjectDeveloperCert), 'Mosco');
            TOTAHelper.MarkCurrentModuleModified;
          end;
        end
        else
          TOTAHelper.AddTitleMessage(Babel.Tx(sNoMacDeveloperCert), 'Mosco');
      end;
    end;
  end;
end;

procedure TMoscoWizard.DoShowDeployedApp(const AProfile, AFileName: string);
var
  LTargetInfo: TTargetInfo;
begin
  LTargetInfo.Profile := AProfile;
  LTargetInfo.FileName := AFileName;
  TDo.Run(procedure begin FClient.ShowApp(LTargetInfo) end);
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
  GetSDKs;
end;

//procedure TMoscoWizard.AddLinkedFramework;
//begin
//  FFrameworkMode := TFrameworkMode.Linked;
//  GetSDKs;
//end;

procedure TMoscoWizard.GetSDKs;
var
  LSDKs: TArray<string>;
begin
  TDo.Run(
    procedure
    begin
      FClient.GetSDKs(LSDKs);
      TDo.SyncMain(procedure begin DoAddSDKFramework(LSDKs) end);
    end
  );
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
  TDo.Run(procedure begin GetFrameworks(LSDK) end);
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
  TDo.SyncMain(procedure begin AddFrameworksToView(LValues); end);
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
    Diagnostic('Available identities:');
  for LIdentity in FIdentities do
    Diagnostic(LIdentity.Description);
end;

procedure TMoscoWizard.FetchCerts;
begin
  if FClient.CanSend and FClient.GetIdentities(FIdentities) then
    TDo.SyncMain(procedure begin CheckCerts; end);
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
    if Trunc(LIdentity.Expiry) < IncDay(Trunc(Now), -Config.Mosco.CertExpiryWarnDays)  then
      LWarnIdentities := LWarnIdentities + [LIdentity];
  end;
  for LIdentity in LWarnIdentities do
  begin
    LExpiry := FormatDateTime('mmm dd, yyyy',  LIdentity.Expiry);
    TOTAHelper.AddTitleMessage(Format(Babel.Tx(sCertExpiresOn), [LIdentity.Description, LExpiry]), 'Mosco');
  end;
end;

initialization
  TOTAWizard.RegisterWizard(TMoscoWizard);

end.
