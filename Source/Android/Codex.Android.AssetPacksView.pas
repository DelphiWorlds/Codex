unit Codex.Android.AssetPacksView;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Actions, Vcl.ActnList, Vcl.Buttons, Vcl.ComCtrls,
  Codex.BaseView,
  Codex.Android.BuildAssetPacksProcess, Codex.Android.GenerateAppProcess,
  Codex.SDKRegistry, Codex.Android.AssetPackTypes;

type
  TAssetPacksView = class(TForm)
    ActionList: TActionList;
    CommandButtonsPanel: TPanel;
    AddPackAction: TAction;
    DeletePackAction: TAction;
    EditPackAction: TAction;
    PackFolderOpenDialog: TFileOpenDialog;
    CloseButton: TButton;
    AssetPackPathPanel: TPanel;
    SelectAssetPacksPathButton: TSpeedButton;
    AssetPackPathLabel: TLabel;
    AssetPacksPathEdit: TEdit;
    AssetPacksListPanel: TPanel;
    AssetPacksLabel: TLabel;
    PackButtonsPanel: TPanel;
    DeletePackButton: TButton;
    AddPackButton: TButton;
    AssetPacksListView: TListView;
    EditPackButton: TButton;
    BuildAllButton: TButton;
    BuildAllAction: TAction;
    InstallAction: TAction;
    InstallButton: TButton;
    procedure CloseButtonClick(Sender: TObject);
    procedure SelectAssetPacksPathButtonClick(Sender: TObject);
    procedure BuildAllActionExecute(Sender: TObject);
    procedure BuildAllActionUpdate(Sender: TObject);
    procedure InstallActionExecute(Sender: TObject);
    procedure InstallActionUpdate(Sender: TObject);
    procedure AddPackActionUpdate(Sender: TObject);
    procedure AddPackActionExecute(Sender: TObject);
    procedure DeletePackActionExecute(Sender: TObject);
    procedure DeletePackActionUpdate(Sender: TObject);
    procedure EditPackActionUpdate(Sender: TObject);
    procedure EditPackActionExecute(Sender: TObject);
  private
    FAppProcess: TGenerateAppProcess;
    FAssetPack: TAssetPack;
    FBuildPacksProcess: TBuildAssetPacksProcess;
    FDeployedPath: string;
    FIsValidBuild: Boolean;
    FProjectName: string;
    FSDKRegistry: TSDKRegistry;
    procedure BuildPacksProcessResultsHandler(Sender: TObject; const AAssetPackResults: TAssetPackResults);
    procedure BundleProcessResultHandler(Sender: TObject; const AStage: TGenerateAppStage; const AExitCode: Cardinal);
    procedure CheckHasAssetPacks;
    procedure CreateAssetPack(const AFolder: string);
    procedure EditPackItem(const AItem: TListItem);
    function GetAvailableFolders(const AFolder: string = ''): TArray<string>;
    function PackExists(const AFolder: string): Boolean;
    procedure ProcessOutputHandler(Sender: TObject; const AOutput: string);
    procedure PromptAddAssetPack;
    function ScanAssetPack(const APath: string): Boolean;
    procedure SelectAssetPacksPath(const APath: string; const ASuppressWarning: Boolean = False);
    procedure ShowWarning(const AMessage: string);
    procedure UpdateAssetPack(const AItem: TListItem);
    procedure UpdateListViewItem(const AItem: TListItem);
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  AssetPacksView: TAssetPacksView;

implementation

{$R *.dfm}

uses
  DW.OSLog,
  System.IOUtils,
  ToolsAPI, CommonOptionStrs, DCCStrs,
  DW.OTA.Helpers,
  DW.OS.Win, DW.IOUtils.Helpers, DW.Types.Helpers, DW.Vcl.DialogService,
  Codex.Android.KeyStoreInfoView, Codex.Android.AssetPackDetailsView,
  Codex.Consts, Codex.Config, Codex.Core, Codex.ProgressView, Codex.Consts.Text;

{ TAssetPacksView }

constructor TAssetPacksView.Create(AOwner: TComponent);
begin
  inherited;
  FSDKRegistry := TSDKRegistry.Current;
  FAssetPack := TAssetPack.Create;
  FBuildPacksProcess := TBuildAssetPacksProcess.Create;
  FBuildPacksProcess.OnOutput := ProcessOutputHandler;
  FBuildPacksProcess.OnResults := BuildPacksProcessResultsHandler;
  FAppProcess := TGenerateAppProcess.Create;
  FAppProcess.OnOutput := ProcessOutputHandler;
  FAppProcess.OnResult := BundleProcessResultHandler;
end;

destructor TAssetPacksView.Destroy;
begin
  FAssetPack.Free;
  FBuildPacksProcess.Free;
  FAppProcess.Free;
  inherited;
end;

procedure TAssetPacksView.DoShow;
begin
  inherited;
  CheckHasAssetPacks;
end;

procedure TAssetPacksView.InstallActionExecute(Sender: TObject);
begin
  FAppProcess.Install;
  ProgressView.ShowProgress(Babel.Tx(sInProgress),Babel.Tx(sInstallingBundle));
end;

procedure TAssetPacksView.InstallActionUpdate(Sender: TObject);
begin
  InstallAction.Enabled := BuildAllAction.Enabled and FIsValidBuild; // TODO: Check whether device is selected - use GetProjectCurrentMobileDeviceName
end;

procedure TAssetPacksView.CheckHasAssetPacks;
var
  LPath: string;
begin
  LPath := TOTAHelper.GetActiveProjectPath;
  if TDirectoryHelper.Exists(LPath) then
  begin
    LPath := TPath.Combine(LPath, 'AssetPacks');
    if TDirectoryHelper.Exists(LPath) then
      SelectAssetPacksPath(LPath);
  end
  else
    AssetPacksListView.Items.Clear;
end;

procedure TAssetPacksView.SelectAssetPacksPath(const APath: string; const ASuppressWarning: Boolean = False);
var
  LPath: string;
  LHasIssues: Boolean;
begin
  AssetPacksListView.Items.Clear;
  LHasIssues := False;
  AssetPacksPathEdit.Text := APath;
  for LPath in TDirectory.GetDirectories(AssetPacksPathEdit.Text, '*', TSearchOption.soTopDirectoryOnly) do
  begin
    if not ScanAssetPack(LPath) then
      LHasIssues := True;
  end;
  if not ASuppressWarning then
  begin
    if (AssetPacksListView.Items.Count = 0) and not LHasIssues then
      PromptAddAssetPack
    else if LHasIssues then
      ShowWarning(Babel.Tx(sFolderHasIssues) + CRLF + Babel.Tx(sPleaseCheckMessages));
  end;
end;

procedure TAssetPacksView.SelectAssetPacksPathButtonClick(Sender: TObject);
begin
  if PackFolderOpenDialog.Execute and not SameText(PackFolderOpenDialog.FileName, AssetPacksPathEdit.Text) then
    SelectAssetPacksPath(PackFolderOpenDialog.FileName);
end;

procedure TAssetPacksView.PromptAddAssetPack;
begin
  //
end;

procedure TAssetPacksView.CreateAssetPack(const AFolder: string);
var
  LManifest: TAssetPackManifest;
begin
  ForceDirectories(TPath.Combine(AFolder, 'pack\assets'));
  LManifest := TAssetPackManifest.Create;
  try
    LManifest.Assign(FAssetPack);
    LManifest.SaveToFile(TPath.Combine(AFolder, 'AndroidManifest.xml'));
  finally
    LManifest.Free;
  end;
end;

function TAssetPacksView.ScanAssetPack(const APath: string): Boolean;
var
  LManifestFileName, LSubFolder: string;
  LManifest: TAssetPackManifest;
begin
  Result := True;
  LManifestFileName := TPath.Combine(APath, cManifestFileName);
  if TFile.Exists(LManifestFileName) then
  begin
    LManifest := TAssetPackManifest.Create;
    try
      if not LManifest.LoadFromFile(LManifestFileName) then
      begin
        TOTAHelper.AddTitleMessage(Format(Babel.Tx(sInvalidAssetPackManifest), [LManifestFileName]), 'Codex');
        Result := False;
      end
      else
        FAssetPack.Assign(LManifest);
    finally
      LManifest.Free;
    end;
  end;
  // else prompt user, or do that at the end?
  LSubFolder := TPath.Combine(APath, 'pack/assets');
  // Iterate assets to find the count?
  if TDirectory.IsEmpty(LSubFolder) then
    TOTAHelper.AddTitleMessage(Format(Babel.Tx(sFolderNoExistOrEmpty), [LSubFolder]), 'Codex');
  if Result then
  begin
    FAssetPack.Folder := TPath.GetFileName(APath);
    UpdateListViewItem(AssetPacksListView.Items.Add);
  end;
end;

procedure TAssetPacksView.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

function TAssetPacksView.PackExists(const AFolder: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to AssetPacksListView.Items.Count - 1 do
  begin
    if SameText(AssetPacksListView.Items[I].SubItems[1], AFolder) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TAssetPacksView.GetAvailableFolders(const AFolder: string = ''): TArray<string>;
var
  I: Integer;
begin
  Result := TDirectory.GetDirectories(AssetPacksPathEdit.Text, '*', TSearchOption.soTopDirectoryOnly);
  for I := Length(Result) - 1 downto 0 do
  begin
    Result[I] := TPath.GetFileName(Result[I]);
    if PackExists(Result[I]) and not SameText(Result[I], AFolder) then
      Delete(Result, I, 1);
  end;
end;

procedure TAssetPacksView.UpdateAssetPack(const AItem: TListItem);
var
  LVerInfo: TArray<string>;
  LConfig: IOTABuildConfiguration;
begin
  FAssetPack.Reset;
  if AItem <> nil then
  begin
    FAssetPack.Package := AItem.Caption;
    FAssetPack.PackName := AItem.SubItems[0];
    FAssetPack.Folder := AItem.SubItems[1];
    FAssetPack.PackKind := TAssetPackKind(Integer(AItem.Data));
  end
  else
  begin
    LConfig := TOTAHelper.GetProjectActiveBuildConfiguration(TOTAHelper.GetActiveProject);
    if LConfig <> nil then
    begin
      LVerInfo := LConfig.GetValue('VerInfo_Keys').Split([';']);
      FAssetPack.Package := StringReplace(LVerInfo.Values['Package'], '$(MSBuildProjectName)', LConfig.Value[sSanitizedProjectName], []);
    end;
  end;
end;

procedure TAssetPacksView.UpdateListViewItem(const AItem: TListItem);
begin
  AItem.Caption := FAssetPack.Package;
  AItem.SubItems.Clear;
  AItem.SubItems.Add(FAssetPack.PackName);
  AItem.SubItems.Add(FAssetPack.Folder);
  AItem.SubItems.Add(cAssetPackKindDisplayValues[FAssetPack.PackKind]);
  AItem.Data := Pointer(Ord(FAssetPack.PackKind));
end;

procedure TAssetPacksView.EditPackItem(const AItem: TListItem);
var
  LDetails: TAssetPackDetailsView;
  LFolders: TArray<string>;
  LFolder, LExistingFolder: string;
begin
  UpdateAssetPack(AItem);
  LFolders := GetAvailableFolders(FAssetPack.Folder);
  LDetails := TAssetPackDetailsView.Create(nil);
  try
    LDetails.FolderComboBox.Items.AddStrings(LFolders);
    if LDetails.EditPack(FAssetPack) then
    begin
      LExistingFolder := '';
      if not FAssetPack.Folder.IsEmpty then
        LExistingFolder := TPath.Combine(AssetPacksPathEdit.Text, FAssetPack.Folder);
      LDetails.UpdatePack(FAssetPack);
      LFolder := TPath.Combine(AssetPacksPathEdit.Text, FAssetPack.Folder);
      if not TDirectoryHelper.Exists(LFolder) then
      begin
        if TDirectoryHelper.Exists(LExistingFolder) then
        begin
          if TDialog.Confirm(Format(Babel.Tx(sRenameAssetPackFolder), [FAssetPack.Folder]), False) then
            TDirectory.Move(LExistingFolder, LFolder);
        end
        else if TDialog.Confirm(Babel.Tx(sFolderNoExistCreateAssetPack), False) then
          CreateAssetPack(LFolder);
      end;
      if TDirectory.Exists(LFolder) then
      begin
        if AItem = nil then
          UpdateListViewItem(AssetPacksListView.Items.Add)
        else
          UpdateListViewItem(AItem);
      end;
    end;
  finally
    LDetails.Free;
  end;
end;

procedure TAssetPacksView.AddPackActionExecute(Sender: TObject);
begin
  EditPackItem(nil);
end;

procedure TAssetPacksView.AddPackActionUpdate(Sender: TObject);
begin
  AddPackAction.Enabled := TDirectoryHelper.Exists(AssetPacksPathEdit.Text);
end;

procedure TAssetPacksView.DeletePackActionExecute(Sender: TObject);
var
  LMessage: string;
begin
  UpdateAssetPack(AssetPacksListView.Selected);
  LMessage := Format(Babel.Tx(sConfirmDeleteAssetPack), [FAssetPack.PackName, FAssetPack.Folder]);
  if TDialog.Confirm(LMessage, True) then
  begin
    TDirectoryHelper.Delete(TPath.Combine(AssetPacksPathEdit.Text, FAssetPack.Folder));
    AssetPacksListView.Selected.Delete;
  end;
end;

procedure TAssetPacksView.DeletePackActionUpdate(Sender: TObject);
begin
  DeletePackAction.Enabled := AssetPacksListView.Selected <> nil;
end;

procedure TAssetPacksView.EditPackActionExecute(Sender: TObject);
begin
  EditPackItem(AssetPacksListView.Selected);
end;

procedure TAssetPacksView.EditPackActionUpdate(Sender: TObject);
begin
  EditPackAction.Enabled := AssetPacksListView.Selected <> nil;
end;

procedure TAssetPacksView.BuildAllActionExecute(Sender: TObject);
var
  LConfig: IOTABuildConfiguration;
  LAABFileName: string;
  LKeyStoreInfo: TKeyStoreInfoView;
  LContinue: Boolean;
  LKeyStoreItem: TKeyStoreItem;
begin
  LConfig := TOTAHelper.GetProjectActiveBuildConfiguration(TOTAHelper.GetActiveProject);
  if LConfig <> nil then
  begin
    FAppProcess.KeyStoreFileName := LConfig.Value[sPF_KeyStore];
    FAppProcess.KeyStoreAlias := LConfig.Value[sPF_AliasKey];
    LKeyStoreInfo := TKeyStoreInfoView.Create(nil);
    try
      LKeyStoreItem := Config.Android.GetKeyStoreItem(FAppProcess.KeyStoreFileName, FAppProcess.KeyStoreAlias);
      LKeyStoreInfo.KeystoreFileNameEdit.Text := FAppProcess.KeyStoreFileName;
      LKeyStoreInfo.KeystoreAliasEdit.Text := FAppProcess.KeyStoreAlias;
      LKeyStoreInfo.KeystoreAliasPassEdit.Text := LKeyStoreItem.KeyAliasPass;
      LKeyStoreInfo.KeystorePassEdit.Text := LKeyStoreItem.KeyStorePass;
      LKeyStoreInfo.FormMode := TKeyStoreFormMode.KeyStore;
      LContinue := LKeyStoreInfo.ShowModal = mrOK;
      if LContinue then
      begin
        FAppProcess.KeyStoreFileName := LKeyStoreInfo.KeyStoreFileNameEdit.Text;
        FAppProcess.KeyStoreAlias := LKeyStoreInfo.KeyStoreAliasEdit.Text;
        FAppProcess.KeyStorePass := LKeyStoreInfo.KeyStorePassEdit.Text;
        FAppProcess.KeyStoreAliasPass := LKeyStoreInfo.KeyStoreAliasPassEdit.Text;
        Config.Android.SetKeyStoreItem(FAppProcess.KeyStoreFileName, FAppProcess.KeyStorePass, FAppProcess.KeyStoreAlias,
          FAppProcess.KeyStoreAliasPass);
      end;
    finally
      LKeyStoreInfo.Free;
    end;
    if LContinue and FAppProcess.IsKeyStoreValid then
    begin
      FProjectName := LConfig.Value[sSanitizedProjectName];
      FDeployedPath := ExpandPath(TOTAHelper.GetActiveProjectPath,  TOTAHelper.ExpandConfiguration(LConfig.GetValue(sExeOutput), LConfig));
      FDeployedPath := TPath.Combine(FDeployedPath, FProjectName);
      LAABFileName := TPath.Combine(FDeployedPath, 'bin\' + FProjectName + '.aab');
      if TFile.Exists(LAABFileName) then
      begin
        FAppProcess.JDKPath := TPath.Combine(FSDKRegistry.GetJDKPath, 'bin');
        FAppProcess.BundleToolPath := TPath.Combine(TPlatformOS.GetEnvironmentVariable('BDSBIN'), cBundleToolPath);
        FBuildPacksProcess.AAPT2ExePath := TPath.Combine(TPlatformOS.GetEnvironmentVariable('BDSBIN'), cAAPT2Path);
        FBuildPacksProcess.APILevelPath := FSDKRegistry.GetSDKAPILevelPath;
        if FBuildPacksProcess.Build(AssetPacksPathEdit.Text) then
        begin
          FIsValidBuild := False;
          ProgressView.ShowProgress(Babel.Tx(sInProgress), Babel.Tx(sBuildingAssetPacks));
        end
        else
          ShowWarning(Babel.Tx(sUnableToBuildAssetPacks) + CRLF + Babel.Tx(sPleaseCheckMessages));
      end
      else
        ShowWarning(Babel.Tx(sCheckConfigAndDeployed));
    end
    else if LContinue then
      ShowWarning(Babel.Tx(sKeystoreInfoMissing));
  end
  else
    ShowWarning(Babel.Tx(sCheckConfig));
end;

procedure TAssetPacksView.ShowWarning(const AMessage: string);
begin
  ProgressView.Dismiss;
  TDialog.Warning(AMessage);
end;

procedure TAssetPacksView.BuildAllActionUpdate(Sender: TObject);
begin
  BuildAllAction.Enabled := TDirectoryHelper.Exists(AssetPacksPathEdit.Text) and (AssetPacksListView.Items.Count > 0);
end;

procedure TAssetPacksView.BuildPacksProcessResultsHandler(Sender: TObject; const AAssetPackResults: TAssetPackResults);
var
  LResult: TAssetPackResult;
  LAssetPacks: TArray<string>;
begin
  LAssetPacks := [];
  for LResult in AAssetPackResults do
  begin
    if LResult.IsSuccess then
      LAssetPacks := LAssetPacks + [LResult.AssetPackFileName];
  end;
  // TODO: Might want to have the option of stopping if any asset packs fail?
  if Length(LAssetPacks) > 0 then
  begin
    FAppProcess.ADBPath := FSDKRegistry.GetADBPath;
    if FAppProcess.BuildBundle(FProjectName, FDeployedPath, LAssetPacks) then
      ProgressView.ShowProgress(Babel.Tx(sInProgress), Babel.Tx(sBuildingBundle))
    else
      ShowWarning(Babel.Tx(sUnableToBuildBundle) + CRLF + Babel.Tx(sPleaseCheckMessages));
  end
  else
    ShowWarning(Babel.Tx(sUnableToCompilePacks) + CRLF + Babel.Tx(sPleaseCheckMessages));
end;

procedure TAssetPacksView.BundleProcessResultHandler(Sender: TObject; const AStage: TGenerateAppStage; const AExitCode: Cardinal);
begin
  if AStage = TGenerateAppStage.BuildComplete then
  begin
    FIsValidBuild := True;
    ProgressView.ShowStatic(Babel.Tx(sComplete), Babel.Tx(sSuccessfullyRebuiltBundle));
  end
  else if AStage = TGenerateAppStage.InstallComplete then
    ProgressView.ShowStatic(Babel.Tx(sComplete), Babel.Tx(sSuccessfullyInstalledBundle))
  else
    ShowWarning(Babel.Tx(sProcessFailed) + CRLF + Babel.Tx(sPleaseCheckMessages));
end;

procedure TAssetPacksView.ProcessOutputHandler(Sender: TObject; const AOutput: string);
begin
  TOTAHelper.AddTitleMessage(AOutput, 'Codex');
end;

end.
