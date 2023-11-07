unit Codex.Android.PackagesView;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Actions, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ActnList,
  Codex.OutputView, Codex.Android.BuildRJarProcess, Codex.SDKRegistry, Codex.BaseView;

type
  TPackagesView = class(TForm)
    ActionList: TActionList;
    AddPackageAction: TAction;
    RemovePackageAction: TAction;
    ExtractButtonsPanel: TPanel;
    BuildButton: TButton;
    BuildAction: TAction;
    CloseButton: TButton;
    RJarPathOpenDialog: TFileOpenDialog;
    PackagesPanel: TPanel;
    RJarPanel: TPanel;
    SelectRJarPathButton: TSpeedButton;
    RJarFileNameLabel: TLabel;
    RJarPathEdit: TEdit;
    SelectFolderOpenDialog: TFileOpenDialog;
    PackageFolderLabel: TLabel;
    PackagesListBox: TListBox;
    PackagesButtonsPanel: TPanel;
    RemovePackageButton: TButton;
    AddPackageButton: TButton;
    ProjectFolderPanel: TPanel;
    SelectProjectFolderButton: TSpeedButton;
    ProjectFolderLabel: TLabel;
    ProjectFolderEdit: TEdit;
    RetainWorkingFilesCheckBox: TCheckBox;
    procedure AddPackageActionExecute(Sender: TObject);
    procedure BuildActionExecute(Sender: TObject);
    procedure RemovePackageActionExecute(Sender: TObject);
    procedure BuildActionUpdate(Sender: TObject);
    procedure RemovePackageActionUpdate(Sender: TObject);
    procedure RetainWorkingFilesCheckBoxClick(Sender: TObject);
  private
    FBuildR: TBuildRJarProcess;
    FOutputView: TOutputView;
    FSDKRegistry: TSDKRegistry;
    procedure BuildRJarCompleteHandler(Sender: TObject; const ASuccess: Boolean);
    procedure BuildRJarOutputHandler(Sender: TObject; const AOutput: string);
    procedure DoOutput(const AOutput: string);
    procedure UpdateProjectPaths;
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  PackagesView: TPackagesView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  ToolsAPI, CommonOptionStrs, DW.OTA.Helpers, Codex.OTA.Helpers, DW.OTA.Consts,
  Vcl.FileCtrl,
  DW.IOUtils.Helpers, DW.RunProcess.Win, DW.Vcl.DialogService,
  Codex.Config, Codex.Core, Codex.Consts.Text;

resourcestring
  sAddedJarToProject = 'Added %s to project';
  sAddedResourcesToDeployment = 'Added resources to deployment';
  sPackageFolderAlreadyAdded = 'Package folder has already been added';
  sSelectAndroidPackageFolder = 'Select Android Package Folder';

function ControlsHeight(const AControls: array of TControl): Integer;
var
  LControl: TControl;
begin
  Result := 0;
  for LControl in AControls do
    Result := Result + LControl.Height + LControl.Margins.Top + LControl.Margins.Bottom;
end;

{ TPackagesView }

constructor TPackagesView.Create(AOwner: TComponent);
begin
  inherited;
  FSDKRegistry := TSDKRegistry.Current;
  FBuildR := TBuildRJarProcess.Create;
  FBuildR.OnProcessOutput := BuildRJarOutputHandler;
  FBuildR.OnComplete := BuildRJarCompleteHandler;
  FOutputView := TOutputView.Create(Self);
  ProjectFolderPanel.Visible := False;
end;

destructor TPackagesView.Destroy;
begin
  FBuildR.Free;
  inherited;
end;

procedure TPackagesView.UpdateProjectPaths;
var
  LProjectName, LProjectPath, LProjectOutputPath: string;
  LProject: IOTAProject;
  LConfiguration: IOTABuildConfiguration;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  LConfiguration := TOTAHelper.GetProjectActiveBuildConfiguration(LProject);
  if (LProject <> nil) and (LConfiguration <> nil) then
  begin
    LProjectPath := TOTAHelper.GetProjectPath(LProject);
    LProjectName := LConfiguration.Value[sSanitizedProjectName];
    LProjectOutputPath := TPath.Combine(TOTAHelper.GetProjectOutputDir(LProject), LProjectName);
    FBuildR.IsDebugConfig := SameText(LConfiguration.Name, 'Debug'); // TODO: May not be called "Debug"
  end;
  FBuildR.MergedResPath := TPath.Combine(LProjectPath, 'Resources\Merged\res');
  FBuildR.ProjectName := LProjectName;
  FBuildR.ProjectOutputPath := LProjectOutputPath;
  FBuildR.ProjectPath := LProjectPath;
  FBuildR.RJarPath := TPath.Combine(LProjectPath, 'Lib');
end;

procedure TPackagesView.BuildActionExecute(Sender: TObject);
begin
  FOutputView.Clear;
  UpdateProjectPaths;
  FBuildR.APILevelPath := FSDKRegistry.GetSDKAPILevelPath;
  FBuildR.BuildToolsPath := FSDKRegistry.GetBuildToolsPath;
  FBuildR.JDKPath := TPath.Combine(FSDKRegistry.GetJDKPath, 'bin');
  FBuildR.Packages := PackagesListBox.Items.ToStringArray;
  FBuildR.Build;
end;

procedure TPackagesView.BuildActionUpdate(Sender: TObject);
begin
  BuildAction.Enabled := PackagesListBox.Items.Count > 0;
end;

procedure TPackagesView.BuildRJarCompleteHandler(Sender: TObject; const ASuccess: Boolean);
var
  LDeployConfigs: TDeployConfigs;
  LProject: IOTAProject;
begin
  if ASuccess then
  begin
    LProject := TOTAHelper.GetCurrentSelectedProject;
    if LProject <> nil then
    begin
      LProject.AddFile(FBuildR.RJarFileName, False);
      DoOutput(Format(Babel.Tx(sAddedJarToProject), [FBuildR.RJarFileName]));
    end;
    if TCodexOTAHelper.GetDeployConfigs(['Android', 'Android64'], LDeployConfigs) then
    begin
      if TCodexOTAHelper.DeployFolder(FBuildR.MergedResPath, 'res', LDeployConfigs) then
        DoOutput(Babel.Tx(sAddedResourcesToDeployment));
    end;
  end;
  DoOutput(Format('*** %s ***', [Babel.Tx(sProcessComplete)]));
end;

procedure TPackagesView.BuildRJarOutputHandler(Sender: TObject; const AOutput: string);
begin
  DoOutput(AOutput);
end;

procedure TPackagesView.DoOutput(const AOutput: string);
begin
  FOutputView.Show;
  FOutputView.Memo.Lines.Add(AOutput);
end;

procedure TPackagesView.DoShow;
begin
  inherited;
  RetainWorkingFilesCheckBox.Checked := False;
end;

procedure TPackagesView.RemovePackageActionExecute(Sender: TObject);
begin
  PackagesListBox.Items.Delete(PackagesListBox.ItemIndex);
end;

procedure TPackagesView.RemovePackageActionUpdate(Sender: TObject);
begin
  RemovePackageAction.Enabled := PackagesListBox.ItemIndex > -1;
end;

procedure TPackagesView.RetainWorkingFilesCheckBoxClick(Sender: TObject);
begin
  FBuildR.NeedsWorkingFiles := RetainWorkingFilesCheckBox.Checked;
end;

procedure TPackagesView.AddPackageActionExecute(Sender: TObject);
begin
  SelectFolderOpenDialog.Title := Babel.Tx(sSelectAndroidPackageFolder);
  SelectFolderOpenDialog.DefaultFolder := Config.Android.DefaultAndroidPackageFolder;
  if SelectFolderOpenDialog.Execute then
  begin
    if PackagesListBox.Items.IndexOf(SelectFolderOpenDialog.FileName) = -1 then
    begin
      Config.Android.DefaultAndroidPackageFolder := SelectFolderOpenDialog.FileName;
      Config.Save;
      PackagesListBox.Items.Add(SelectFolderOpenDialog.FileName);
    end
    else
      TDialog.Warning(Babel.Tx(sPackageFolderAlreadyAdded));
  end;
end;

end.

