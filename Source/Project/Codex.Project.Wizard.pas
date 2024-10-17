unit Codex.Project.Wizard;

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
  System.SysUtils, System.Classes, System.IOUtils, System.StrUtils,
  Winapi.Windows, Winapi.Messages, ToolsAPI, DCCStrs, DeploymentAPI, PlatformAPI,
  Vcl.Menus, Vcl.Controls, Vcl.Forms, Vcl.StdCtrls, Vcl.ActnList, DW.OSLog,
  DW.OTA.Wizard, DW.OTA.Helpers, DW.Types.Helpers, DW.Menus.Helpers, DW.OTA.Consts,
  DW.IOUtils.Helpers, DW.Classes.Helpers, DW.OTA.Notifiers,
  Codex.Consts, Codex.Consts.Text, Codex.Config, Codex.Interfaces, Codex.Core, Codex.OTA.Helpers,
  Codex.Project.EffectivePathsView, Codex.Project.ProjectPathsView, Codex.Project.CommonPathsView, Codex.Project.AddFoldersView,
  Codex.Project.ProjectToolsView, Codex.Project.DeployFolderView, Codex.Project.DeployExtensionsView,
  Codex.ProgressView, Codex.Project.ResourcesModule,
  Codex.Project.ProjectManagerMenu;

type
  TProjectWizard = class(TWizard, IProjectToolsProvider)
  private
    FEffectivePaths: TStrings;
    FMenuItem: TMenuItem;
    FProjectManagerMenuNotifier: ITOTALNotifier;
    FResources: TProjectResourcesModule;
    procedure AddMenuItems;
    procedure CommonPathsMenuItemHandler(Sender: TObject);
    function DoTotalClean(const AProjectName: string; const APaths: TArray<string>): Boolean;
    procedure DoTotalCleanComplete(const AProjectName: string; const ASuccess: Boolean);
    function DoTotalCleanFile(const AProjectName, AFileName: string): Boolean;
    procedure FindUnitActionExecuteHandler(Sender: TObject);
    procedure ShowEffectivePathsActionHandler(Sender: TObject);
    procedure ShowEffectivePathsForm(const AFind: Boolean);
    procedure ShowToolsActionHandler(Sender: TObject);
    procedure SyncMessage(const AMsg: string);
    procedure UpdateProjectActionHandler(Sender: TObject);
  protected
    procedure FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string); override;
  public
    { IProjectToolsProvider }
    procedure AddFolders;
    procedure BuildProject;
    function CanDeployProject: Boolean;
    procedure CleanProject;
    procedure CompileProject;
    procedure DeployAppExtensions(const AFolders: TArray<string>);
    procedure DeployProject;
    procedure DeployProjectFolder;
    function HasActiveProject: Boolean;
    procedure InsertProjectPaths;
    procedure ShowDeployAppExtensions;
    procedure ShowProjectDeployment;
    procedure ShowProjectOptions;
    procedure TotalCleanProject;
    procedure ViewProjectSource;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

const
  cProjectKnownExtensions: array[0..5] of string = ('.dpr', '.dproj', '.xml', '.fmx', '.pas', '.dfm');

{ TProjectWizard }

constructor TProjectWizard.Create;
begin
  inherited;
  ProjectToolsProvider := Self;
  FResources := TProjectResourcesModule.Create(Application);
  FResources.LinkAction('CommonPathsAction', CommonPathsMenuItemHandler);
  FResources.AddToolbarActions;
  TProjectToolsView.CreateView;
  FEffectivePaths := TStringList.Create;
  FProjectManagerMenuNotifier := TProjectProjectManagerMenuNotifier.Create;
  AddMenuItems;
end;

destructor TProjectWizard.Destroy;
begin
  FProjectManagerMenuNotifier.RemoveNotifier;
  TProjectToolsView.RemoveView;
  FMenuItem.Free;
  FEffectivePaths.Free;
  inherited;
end;

procedure TProjectWizard.AddMenuItems;
var
  LCodexMenuItem, LMenuItem: TMenuItem;
begin
  if TOTAHelper.FindToolsSubMenu(cCodexMenuItemName, LCodexMenuItem) then
  begin
    FMenuItem := TMenuItem.Create(LCodexMenuItem);
    FMenuItem.Caption := sProjectToolsCaption;
    LCodexMenuItem.Insert(LCodexMenuItem.Count, FMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FMenuItem, Babel.Tx(sFindUnitCaption), FindUnitActionExecuteHandler);
    LMenuItem.Action.OnUpdate := UpdateProjectActionHandler;
    FMenuItem.Insert(FMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FMenuItem, Babel.Tx(sCommonPathsCaption), CommonPathsMenuItemHandler);
    FMenuItem.Insert(FMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FMenuItem, Babel.Tx(sShowToolsCaption), ShowToolsActionHandler);
    FMenuItem.Insert(FMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(FMenuItem, Babel.Tx(sShowEffectivePathsCaption), ShowEffectivePathsActionHandler);
    LMenuItem.Action.OnUpdate := UpdateProjectActionHandler;
    FMenuItem.Insert(FMenuItem.Count, LMenuItem);
    FMenuItem.Sort;
  end;
end;

function TProjectWizard.HasActiveProject: Boolean;
begin
  Result := TOTAHelper.GetActiveProject <> nil;
end;

function TProjectWizard.CanDeployProject: Boolean;
begin
  Result := HasActiveProject and ActiveProjectProperties.Platform.StartsWith('Android', True) or not ActiveProjectProperties.Profile.IsEmpty;
end;

procedure TProjectWizard.UpdateProjectActionHandler(Sender: TObject);
begin
  TAction(Sender).Enabled := HasActiveProject;
end;

procedure TProjectWizard.FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
begin
  if not TOTAHelper.IsIDEClosing then
    FMenuItem.Enabled := TOTAHelper.GetActiveProject <> nil;
end;

procedure TProjectWizard.FindUnitActionExecuteHandler(Sender: TObject);
begin
  ShowEffectivePathsForm(True);
end;

procedure TProjectWizard.ShowEffectivePathsActionHandler(Sender: TObject);
begin
  ShowEffectivePathsForm(False);
end;

procedure TProjectWizard.ShowEffectivePathsForm(const AFind: Boolean);
var
  LForm: TEffectivePathsView;
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetActiveProject;
  if LProject <> nil then
  begin
    LForm := TEffectivePathsView.Create(nil);
    try
      GetEffectivePaths(LForm.EffectivePathsListBox.Items);
      LForm.FindMode := AFind;
      if not AFind then
      begin
        LForm.Caption := Format(Babel.Tx(sEffectivePathsFormCaption),
          [TPath.GetFileName(LProject.FileName), LProject.CurrentPlatform, LProject.CurrentConfiguration]);
      end;
      LForm.ShowModal;
    finally
      LForm.Free;
    end;
  end;
end;

procedure TProjectWizard.ShowToolsActionHandler(Sender: TObject);
begin
  TProjectToolsView.ShowView;
end;

procedure TProjectWizard.AddFolders;
var
  LForm: TForm;
begin
  LForm := TAddFoldersView.Create(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TProjectWizard.BuildProject;
begin
  TCodexOTAHelper.ExecuteIDEAction('ProjectBuildCommand');
end;

procedure TProjectWizard.CleanProject;
begin
  TCodexOTAHelper.ExecuteIDEAction('ProjectCleanCommand');
end;

procedure TProjectWizard.TotalCleanProject;
var
  LProject: IOTAProject;
  LConfigs: IOTAProjectOptionsConfigurations;
  LConfig, LPlatformConfig: IOTABuildConfiguration;
  LPlatforms: IOTAProjectPlatforms;
  LProjectName, LProjectFileName, LProjectPath, LPath, LPlatform: string;
  LPaths: TArray<string>;
  I: Integer;
  LCleanedPaths, LCleanedApp: Boolean;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if LProject <> nil then
  begin
    Supports(LProject, IOTAProjectPlatforms, LPlatforms);
    LProjectFileName := LProject.ProjectOptions.TargetName;
    LProjectName := TPath.GetFileNameWithoutExtension(LProjectFileName);
    LProjectPath := TOTAHelper.GetProjectPath(LProject);
    LConfigs := TOTAHelper.GetProjectOptionsConfigurations(LProject);
    for I := 0 to LConfigs.ConfigurationCount - 1 do
    begin
      LConfig := LConfigs.Configurations[I];
      if not LConfig.Name.Equals('Base') then
      begin
        for LPlatform in LConfig.Platforms do
        begin
          LPlatformConfig := LConfig.PlatformConfiguration[LPlatform];
          if (LPlatformConfig <> nil) and LPlatforms.Enabled[LPlatform] then
          begin
            LPath := TOTAHelper.ExpandConfiguration(LConfig.GetValue(sDcuOutput), LPlatformConfig);
            LPath := ExpandPath(LProjectPath, TOTAHelper.ExpandVars(LPath));
            if TDirectory.Exists(LPath) then
              LPaths.Add(LPath, False);
          end;
        end;
      end;
    end;
    // TODO: ProgressView.Width := Screen.Width div 3;
    TDo.Run(
      procedure
      begin
        LCleanedApp := not TFile.Exists(LProjectFileName) or DoTotalCleanFile(LProjectName, LProjectFileName);
        LCleanedPaths := DoTotalClean(LProjectName, LPaths);
        DoTotalCleanComplete(LProjectName, LCleanedPaths and LCleanedApp);
      end);
  end;
end;

procedure TProjectWizard.DoTotalCleanComplete(const AProjectName: string; const ASuccess: Boolean);
begin
  // For some bizarre reason, this IDE message needs to be synched separately from dismissing the ProgressView
  if ASuccess then
    SyncMessage(Format(Babel.Tx(sTotalCleanOfProjectCompleted), [AProjectName]));
  TDo.SyncMain(
    procedure
    begin
      if ASuccess then
        ProgressView.Dismiss
      else
        ProgressView.ShowStatic(Format(Babel.Tx(sCleaningProjectTitle), [AProjectName]), Babel.Tx(sCleanCouldNotComplete));
    end);
end;

function TProjectWizard.DoTotalClean(const AProjectName: string; const APaths: TArray<string>): Boolean;
var
  LPath, LFileName: string;
  LPaths, LFiles: TArray<string>;
begin
  Result := True;
  for LPath in APaths do
  begin
    LFiles := TDirectory.GetFiles(LPath, '*.*', TSearchOption.soTopDirectoryOnly);
    for LFileName in LFiles do
    begin
      if not DoTotalCleanFile(AProjectName, LFileName) then
        Result := False;
    end;
    LPaths := TDirectory.GetDirectories(LPath, '*.*', TSearchOption.soTopDirectoryOnly);
    if Length(LPaths) = 0 then
    try
      TDirectory.Delete(LPath);
    except
      TOSLog.d('> Could not delete folder: %s', [LPath]);
    end
    else
      DoTotalClean(AProjectName, LPaths);
  end;
end;

function TProjectWizard.DoTotalCleanFile(const AProjectName, AFileName: string): Boolean;
begin
  TDo.Sync(
    procedure
    begin
      ProgressView.ShowProgress(Format(Babel.Tx(sCleaningProjectTitle), [AProjectName]), Format(Babel.Tx(sCleanDeletingFile), [AFileName]));
    end);
  try
    TFile.Delete(AFileName);
    Result := True;
  except
    Result := False;
  end;
  if not Result then
    SyncMessage(Format(Babel.Tx(sCleanCouldNotDeleteFile), [AFileName]));
end;

procedure TProjectWizard.SyncMessage(const AMsg: string);
begin
  TDo.Sync(
    procedure
    begin
      TOTAHelper.AddTitleMessage(AMsg, 'Codex');
    end);
end;

procedure TProjectWizard.CommonPathsMenuItemHandler(Sender: TObject);
var
  LForm: TForm;
begin
  LForm := TCommonPathsView.Create(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

procedure TProjectWizard.CompileProject;
begin
  TCodexOTAHelper.ExecuteIDEAction('ProjectCompileCommand');
end;

procedure TProjectWizard.DeployAppExtensions(const AFolders: TArray<string>);
var
  LDeployConfigs: TDeployConfigs;
  LDeployConfig: TDeployConfig;
  LFolder: string;
begin
  for LFolder in AFolders do
  begin
    LDeployConfig.PlatformName := cProjectPlatforms[ActiveProjectProperties.ProjectPlatform];
    LDeployConfig.Configs := ['Debug', 'Release'];
    LDeployConfigs := [LDeployConfig];
    TCodexOTAHelper.DeployFolder(LFolder, TPath.Combine('.\PlugIns', TPath.GetFileName(LFolder)), LDeployConfigs);
  end;
  ShowProjectDeployment;
end;

procedure TProjectWizard.ShowDeployAppExtensions;
var
  LView: TForm;
begin
  LView := TDeployExtensionsView.Create(nil);
  try
    LView.ShowModal;
  finally
    LView.Free;
  end;
end;

procedure TProjectWizard.DeployProject;
begin
  TCodexOTAHelper.ExecuteIDEAction('ProjectDeployCommand');
end;

procedure TProjectWizard.InsertProjectPaths;
var
  LForm: TProjectPathsView;
  LConfigs: IOTAProjectOptionsConfigurations;
  LBaseConfig: IOTABuildConfiguration;
  LPaths: TStrings;
begin
  LConfigs := TOTAHelper.GetActiveProjectOptionsConfigurations;
  if LConfigs <> nil then
  begin
    LBaseConfig := LConfigs.BaseConfiguration;
    if LBaseConfig <> nil then
    begin
      LForm := TProjectPathsView.Create(nil);
      try
        LPaths := TStringList.Create;
        try
          LBaseConfig.GetValues(sUnitSearchPath, LPaths);
          LForm.ExistingPaths := LPaths;
          TWizard.GetEffectivePaths(LForm.EffectivePathsListBox.Items, True);
          if LForm.ShowModal = mrOK then
          begin
            LForm.SelectedPaths.AssignToStrings(LPaths, False);
            LBaseConfig.SetValues(sUnitSearchPath, LPaths);
            TOTAHelper.MarkCurrentModuleModified;
          end;
        finally
          LPaths.Free;
        end;
      finally
        LForm.Free;
      end;
    end;
  end;
end;

procedure TProjectWizard.ShowProjectDeployment;
var
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetActiveProject;
  if LProject <> nil then
    (BorlandIDEServices as IOTADeploymentService).DeployManagerProject(LProject);
end;

procedure TProjectWizard.ShowProjectOptions;
begin
  TCodexOTAHelper.ExecuteIDEAction('ProjectOptionsCommand');
end;

procedure TProjectWizard.ViewProjectSource;
begin
  if TOTAHelper.GetActiveProject <> nil then
    TOTAHelper.GetActiveProject.Show;
end;

procedure TProjectWizard.DeployProjectFolder;
var
  LForm: TForm;
begin
  LForm := TDeployFolderView.Create(nil);
  try
    LForm.ShowModal;
  finally
    LForm.Free;
  end;
end;

initialization
  TOTAWizard.RegisterWizard(TProjectWizard);

end.

