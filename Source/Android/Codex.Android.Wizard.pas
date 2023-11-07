unit Codex.Android.Wizard;

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
  System.Win.Registry, System.SysUtils, System.IOUtils,
  Winapi.Windows, Winapi.ShellAPI,
  ToolsAPI, CommonOptionStrs,
  Vcl.Menus, Vcl.Forms, Vcl.ActnList, Vcl.Controls,
  DW.OSLog,
  DW.OTA.Wizard, DW.OTA.Notifiers, DW.OTA.Helpers, DW.OTA.Consts, DW.OS.Win,
  DW.Menus.Helpers, DW.Vcl.DialogService,
  Codex.Consts, Codex.Core, Codex.SDKRegistry, Codex.Consts.Text,
  Codex.Android.ADBConnectView, Codex.Android.AssetPackDetailsView, Codex.Android.AssetPacksView, Codex.Android.BuildJarView,
  Codex.Android.PackageDownloadView, Codex.Android.Java2OPView, Codex.Android.PackagesView,
  Codex.Android.KeyStoreInfoView, Codex.Android.ProjectManagerMenu, Codex.Android.ResourcesModule, Codex.Android.GenerateAppProcess;

type
  TAndroidWizard = class(TWizard)
  private
    FAndroidMenuItem: TMenuItem;
    FAppProcess: TGenerateAppProcess;
    FAssetPacksView: TAssetPacksView;
    FBuildJarView: TBuildJarView;
    FJava2OPView: TJava2OPView;
    FPackageDownloadView: TPackageDownloadView;
    FProjectManagerMenuNotifier: ITOTALNotifier;
    FResources: TAndroidResources;
    FSDKRegistry: TSDKRegistry;
    procedure AddMenuItems;
    procedure ADBConnect;
    procedure ADBConnectActionHandler(Sender: TObject);
    procedure ADBConnectActionExecuteHandler(Sender: TObject);
    procedure BuildAssetPacks;
    procedure BuildAssetPacksActionHandler(Sender: TObject);
    procedure BuildAssetPacksActionUpdateHandler(Sender: TObject);
    procedure BuildJarActionHandler(Sender: TObject);
    procedure ExtractAPKsActionHandler(Sender: TObject);
    procedure Java2OPActionHandler(Sender: TObject);
    procedure LinkActions;
    procedure LogCatActionHandler(Sender: TObject);
    procedure PackageDownloadActionHandler(Sender: TObject);
    procedure PerformBundleAction(const AMode: TKeyStoreFormMode);
    procedure ShowFixSDKMessage;
  protected
    procedure FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string); override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

resourcestring
  sADBConnectCaption = 'ADB Connect';
  sAndroidToolsCaption = 'Android Tools';
  sBuildAssetPacksCaption = 'Build Asset Packs';
  sBuildJarCaption = 'Build Jar';
  sCreateRJarCaption = 'Create R Jar';
  sEnsureSDKCompleteMessage = 'Please ensure an Android SDK is configured correctly';
  sExtractAARFilesCaption = 'Extract AAR File';
  sExtractAPKsCaption = 'Extract APKs From AAB';
  sImportGoogleServicesJsonCaption = 'Import google-services.json';
  sInstallAABCaption = 'Install AAB';
  sJava2OPCaption = 'Java2OP';
  sLogCatCaption = 'Logcat Viewer';
  sMergePackagesCaption = 'Merge Packages';
  sOptionsCaption = 'Options';
  sPackageDownloadCaption = 'Package Download';
  sRebuildAppCaption = 'Rebuild Project';

{ TAndroidWizard }

constructor TAndroidWizard.Create;
begin
  inherited;
  TOTAHelper.RegisterThemeForms([TPackagesView, TBuildJarView, TJava2OPView, TPackageDownloadView, TADBConnectView, TAssetPacksView, TKeyStoreInfoView,
    TAssetPackDetailsView, TPackagesView]);
  FAppProcess := TGenerateAppProcess.Create;
  FSDKRegistry := TSDKRegistry.Current;
  AddMenuItems;
  LinkActions;
  FProjectManagerMenuNotifier := TAndroidProjectManagerMenuNotifier.Create;
end;

destructor TAndroidWizard.Destroy;
begin
  FProjectManagerMenuNotifier.RemoveNotifier;
  inherited;
end;

procedure TAndroidWizard.AddMenuItems;
var
  LCodexMenuItem, LMenuItem: TMenuItem;
begin
  if TOTAHelper.FindToolsSubMenu(cCodexMenuItemName, LCodexMenuItem) then
  begin
    FAndroidMenuItem := TMenuItem.Create(LCodexMenuItem);
    FAndroidMenuItem.Caption := Babel.Tx(sAndroidToolsCaption);
    LCodexMenuItem.Insert(LCodexMenuItem.Count, FAndroidMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FAndroidMenuItem, Babel.Tx(sADBConnectCaption), ADBConnectActionHandler);
    FAndroidMenuItem.Insert(FAndroidMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FAndroidMenuItem, Babel.Tx(sBuildAssetPacksCaption), BuildAssetPacksActionHandler);
    LMenuItem.Action.OnUpdate := BuildAssetPacksActionUpdateHandler;
    FAndroidMenuItem.Insert(FAndroidMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FAndroidMenuItem, Babel.Tx(sBuildJarCaption), BuildJarActionHandler);
    FAndroidMenuItem.Insert(FAndroidMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FAndroidMenuItem, Babel.Tx(sExtractAPKsCaption), ExtractAPKsActionHandler);
    FAndroidMenuItem.Insert(FAndroidMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FAndroidMenuItem, Babel.Tx(sJava2OPCaption), Java2OPActionHandler);
    FAndroidMenuItem.Insert(FAndroidMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FAndroidMenuItem, Babel.Tx(sLogCatCaption), LogCatActionHandler);
    FAndroidMenuItem.Insert(FAndroidMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FAndroidMenuItem, Babel.Tx(sPackageDownloadCaption), PackageDownloadActionHandler);
    FAndroidMenuItem.Insert(FAndroidMenuItem.Count, LMenuItem);
  end;
end;

procedure TAndroidWizard.LinkActions;
begin
  FResources := TAndroidResources.Create(Application);
  FResources.LinkAction('ADBConnectAction', ADBConnectActionExecuteHandler);
  FResources.AddToolbarActions;
end;

procedure TAndroidWizard.ShowFixSDKMessage;
begin
  TDialog.Warning(sEnsureSDKCompleteMessage);
end;

procedure TAndroidWizard.ADBConnect;
var
  LForm: TADBConnectView;
begin
  if not FSDKRegistry.GetADBPath.IsEmpty then
  begin
    LForm := TADBConnectView.Create(nil);
    try
      LForm.ShowModal;
    finally
      LForm.Free;
    end;
  end
  else
    ShowFixSDKMessage;
end;

procedure TAndroidWizard.ADBConnectActionExecuteHandler(Sender: TObject);
begin
  ADBConnect;
end;

procedure TAndroidWizard.ADBConnectActionHandler(Sender: TObject);
begin
  ADBConnect;
end;

procedure TAndroidWizard.BuildAssetPacks;
begin
  if TOTAHelper.GetProjectCurrentPlatform(TOTAHelper.GetActiveProject) in cAndroidProjectPlatforms then
  begin
    if FAssetPacksView = nil then
      FAssetPacksView := TAssetPacksView.Create(Application);
    FAssetPacksView.Show;
  end
  else
    TDialog.Warning(Babel.Tx(sSelectAndroidForAssetPacks));
end;

procedure TAndroidWizard.BuildAssetPacksActionHandler(Sender: TObject);
begin
  BuildAssetPacks;
end;

procedure TAndroidWizard.BuildAssetPacksActionUpdateHandler(Sender: TObject);
begin
  TAction(Sender).Enabled := TOTAHelper.GetActiveProject <> nil;
end;

procedure TAndroidWizard.BuildJarActionHandler(Sender: TObject);
begin
  if FSDKRegistry.CanCreateJar then
  begin
    if FBuildJarView = nil then
      FBuildJarView := TBuildJarView.Create(Application);
    FBuildJarView.Show;
  end
  else
    ShowFixSDKMessage;
end;

procedure TAndroidWizard.ExtractAPKsActionHandler(Sender: TObject);
begin
  PerformBundleAction(TKeyStoreFormMode.ExtractAPKs);
end;

procedure TAndroidWizard.PerformBundleAction(const AMode: TKeyStoreFormMode);
var
  LKeyStoreInfo: TKeyStoreInfoView;
begin
  FAppProcess.KeyStoreFileName := TOTAHelper.GetEnvironmentOptions.Values[sENV_PF_KeyStore];
  FAppProcess.KeyStoreAlias := TOTAHelper.GetEnvironmentOptions.Values[sENV_PF_AliasKey];
  LKeyStoreInfo := TKeyStoreInfoView.Create(nil);
  try
    LKeyStoreInfo.KeystoreFileNameEdit.Text := FAppProcess.KeyStoreFileName;
    LKeyStoreInfo.KeystoreAliasEdit.Text := FAppProcess.KeyStoreAlias;
    LKeyStoreInfo.FormMode := AMode;
    if (LKeyStoreInfo.ShowModal = mrOK) and ((AMode <> TKeyStoreFormMode.ExtractAPKs) or FResources.APKFolderOpenDialog.Execute) then
    begin
      FAppProcess.ADBPath := FSDKRegistry.GetADBPath;
      FAppProcess.JDKPath := TPath.Combine(FSDKRegistry.GetJDKPath, 'bin');
      FAppProcess.BundleToolPath := TPath.Combine(TPlatformOS.GetEnvironmentVariable('BDSBIN'), cBundleToolPath);
      FAppProcess.KeyStoreFileName := LKeyStoreInfo.KeystoreFileNameEdit.Text;
      FAppProcess.KeyStoreAlias := LKeyStoreInfo.KeystoreAliasEdit.Text;
      FAppProcess.KeyStoreAliasPass := LKeyStoreInfo.KeystoreAliasPassEdit.Text;
      FAppProcess.KeyStorePass := LKeyStoreInfo.KeystorePassEdit.Text;
      case AMode of
        TKeyStoreFormMode.ExtractAPKs:
          FAppProcess.Extract(LKeyStoreInfo.AABFileNameEdit.Text, FResources.APKFolderOpenDialog.FileName);
        TKeyStoreFormMode.InstallBundle:
          FAppProcess.Install(LKeyStoreInfo.AABFileNameEdit.Text);
      end;
    end;
  finally
    LKeyStoreInfo.Free;
  end;
end;

procedure TAndroidWizard.PackageDownloadActionHandler(Sender: TObject);
begin
  if FPackageDownloadView = nil then
    FPackageDownloadView := TPackageDownloadView.Create(Application);
  FPackageDownloadView.Show;
end;

procedure TAndroidWizard.FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
begin
  case ANotifyCode of
    TOTAFileNotification.ofnActiveProjectChanged:
      Modification;
  end;
end;

procedure TAndroidWizard.Java2OPActionHandler(Sender: TObject);
begin
  if FJava2OPView = nil then
    FJava2OPView := TJava2OPView.Create(Application);
  FJava2OPView.Show;
end;

procedure TAndroidWizard.LogCatActionHandler(Sender: TObject);
var
  LRegistry: TRegistry;
  LPath: string;
begin
  LPath := '';
  LRegistry := TRegistry.Create(KEY_READ);
  try
    LRegistry.RootKey := HKEY_LOCAL_MACHINE;
    // Checks whether Device Lens has been installed
    if LRegistry.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{ADA70506-4629-46CB-977E-31B26E44ADDE}_is1', False) then
    try
      LPath := LRegistry.ReadString('InstallLocation');
      if not LPath.IsEmpty then
        LPath := TPath.Combine(LPath, 'DeviceLens.exe');
    finally
      LRegistry.CloseKey;
    end
    else
      TOSLog.d('Reg key not found');
  finally
    LRegistry.Free;
  end;
  // If not installed, or just not found, open the Device Lens repo
  if LPath.IsEmpty then
    LPath := 'https://github.com/DelphiWorlds/DeviceLens';
  ShellExecute(0, 'open', PChar(LPath), nil, nil, SW_SHOWNORMAL);
end;

initialization
  TOTAWizard.RegisterWizard(TAndroidWizard);

end.
