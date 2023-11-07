unit Codex.Android.BuildJarView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Actions, Vcl.ActnList, Vcl.Buttons,
  DW.Types.Helpers,
  DW.Vcl.Splitter.Themed,
  Codex.BaseView,
  Codex.OutputView, Codex.Android.CreateJarProcess, Codex.SDKRegistry;

type
  TBuildJarView = class(TForm)
    DependentJarsPanel: TPanel;
    JarsButtonsPanel: TPanel;
    RemoveJarButton: TButton;
    AddJarButton: TButton;
    JarsListBox: TListBox;
    JavaSourcePanel: TPanel;
    JavaButtonsPanel: TPanel;
    RemoveJavaFileButton: TButton;
    AddJavaFileButton: TButton;
    JavaListBox: TListBox;
    ActionList: TActionList;
    CommandButtonsPanel: TPanel;
    BuildJarButton: TButton;
    OutputPathPanel: TPanel;
    SelectOutputFileButton: TSpeedButton;
    OutputFileEdit: TEdit;
    AddJarAction: TAction;
    RemoveJarAction: TAction;
    AddJavaFileAction: TAction;
    RemoveJavaFileAction: TAction;
    BuildJarAction: TAction;
    JarOpenDialog: TFileOpenDialog;
    JavaOpenDialog: TFileOpenDialog;
    SelectOutputFileAction: TAction;
    JarSaveDialog: TFileSaveDialog;
    LoadJarConfigButton: TButton;
    SaveJarConfigButton: TButton;
    LoadJarConfigAction: TAction;
    SaveJarConfigAction: TAction;
    JarConfigFileOpenDialog: TFileOpenDialog;
    JarConfigFileSaveDialog: TFileSaveDialog;
    AddJavaFolderButton: TButton;
    AddJavaFolderAction: TAction;
    JavaFolderOpenDialog: TFileOpenDialog;
    ToolsOptionsAction: TAction;
    ToolsOptionsButton: TButton;
    DexCheckBox: TCheckBox;
    VersionsPanel: TPanel;
    SourceVersionLabel: TLabel;
    SourceVersionComboBox: TComboBox;
    TargetVersionLabel: TLabel;
    TargetVersionComboBox: TComboBox;
    JarsLabel: TLabel;
    JavaSourceLabel: TLabel;
    VersionsLabel: TLabel;
    OutputFileLabel: TLabel;
    CloseButton: TButton;
    JarsSourceSplitter: TSplitter;
    RetainWorkingFilesCheckBox: TCheckBox;
    NewConfigButton: TButton;
    NewConfigAction: TAction;
    procedure AddJarActionExecute(Sender: TObject);
    procedure AddJavaFileActionExecute(Sender: TObject);
    procedure RemoveJarActionExecute(Sender: TObject);
    procedure RemoveJavaFileActionExecute(Sender: TObject);
    procedure SelectOutputFileActionExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure BuildJarActionExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure LoadJarConfigActionExecute(Sender: TObject);
    procedure SaveJarConfigActionExecute(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure AddJavaFolderActionExecute(Sender: TObject);
    procedure ClearActionExecute(Sender: TObject);
    procedure SourceVersionComboBoxChange(Sender: TObject);
    procedure SourceVersionComboBoxDropDown(Sender: TObject);
    procedure NewConfigActionExecute(Sender: TObject);
    procedure OutputFileEditChange(Sender: TObject);
  private
    FBDSPath: string;
    FConfigFileName: string;
    FCreateJar: TCreateJarProcess;
    FIsModified: Boolean;
    FOutputView: TOutputView;
    FSDKRegistry: TSDKRegistry;
    procedure AddAbsolutePaths(const AFiles, ASource: TStrings);
    procedure AddJarFiles(const AFiles: TStrings);
    procedure AddJavaFiles(const AFiles: TStrings);
    function CanBuild: Boolean;
    function CanModify: Boolean;
    procedure ClearControls;
    function GetConfigPath: string;
    procedure Modified;
    procedure OutputHandler(Sender: TObject; const AOutput: string);
    procedure SaveVersions;
    procedure SetVersions;
    procedure UpdateCaption;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  BuildJarView: TBuildJarView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  DW.OSLog,
  DW.IOUtils.Helpers, DW.OTA.Helpers, DW.Vcl.DialogService, DW.OS.Win, DW.Vcl.ListBoxHelper,
  Neon.Core.Persistence.JSON,
  Codex.Config, Codex.Consts,
  Codex.Android.Types, Codex.Core, Codex.Consts.Text;

{ TBuildJarView }

constructor TBuildJarView.Create(AOwner: TComponent);
begin
  inherited;
  FBDSPath := TPlatformOS.GetEnvironmentVariable(cEnvVarBDS);
  FSDKRegistry := TSDKRegistry.Current;
  FCreateJar := TCreateJarProcess.Create;
  FCreateJar.OnProcessOutput := OutputHandler;
  FOutputView := TOutputView.Create(Self);
  TOTAHelper.ApplyTheme(FOutputView);
  SetVersions;
end;

destructor TBuildJarView.Destroy;
begin
  FCreateJar.Free;
  inherited;
end;

procedure TBuildJarView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (OutputFileEdit.Text <> '') and TDirectory.Exists(TPath.GetDirectoryName(OutputFileEdit.Text)) then
    Config.Android.JarOutputFolder := TPath.GetDirectoryName(OutputFileEdit.Text);
  Config.Save;
end;

function TBuildJarView.GetConfigPath: string;
begin
  Result := TPath.GetDirectoryName(FConfigFileName);
end;

procedure TBuildJarView.LoadJarConfigActionExecute(Sender: TObject);
var
  LConfig: TJarProjectConfig;
begin
  if JarConfigFileOpenDialog.Execute then
  begin
    if LConfig.Load(JarConfigFileOpenDialog.FileName) then
    begin
      FConfigFileName := JarConfigFileOpenDialog.FileName;
      UpdateCaption;
      LConfig.IncludedJars.AssignToStrings(JarsListBox.Items);
      LConfig.JavaFiles.AssignToStrings(JavaListBox.Items);
      OutputFileEdit.Text := LConfig.OutputFile;
      if SourceVersionComboBox.Items.IndexOf(LConfig.SourceVersion) > -1 then
        SourceVersionComboBox.ItemIndex := SourceVersionComboBox.Items.IndexOf(LConfig.SourceVersion);
      if TargetVersionComboBox.Items.IndexOf(LConfig.TargetVersion) > -1 then
        TargetVersionComboBox.ItemIndex := TargetVersionComboBox.Items.IndexOf(LConfig.TargetVersion);
      FIsModified := False;
    end;
    // else display a message
  end;
end;

procedure TBuildJarView.Modified;
begin
  FIsModified := True;
end;

procedure TBuildJarView.NewConfigActionExecute(Sender: TObject);
begin
  if JarConfigFileSaveDialog.Execute then
  begin
    FConfigFileName := JarConfigFileSaveDialog.FileName;
    UpdateCaption;
    ClearControls;
  end;
end;

procedure TBuildJarView.SaveJarConfigActionExecute(Sender: TObject);
var
  LConfig: TJarProjectConfig;
begin
  LConfig.IncludedJars.LoadFromStrings(JarsListBox.Items);
  LConfig.JavaFiles.LoadFromStrings(JavaListBox.Items);
  LConfig.OutputFile := OutputFileEdit.Text;
  LConfig.SourceVersion := SourceVersionComboBox.Text;
  LConfig.TargetVersion := TargetVersionComboBox.Text;
  LConfig.Save(FConfigFileName);
  FIsModified := False;
end;

procedure TBuildJarView.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  AddJarAction.Enabled := CanModify;
  AddJavaFolderAction.Enabled := CanModify;
  AddJavaFileAction.Enabled := CanModify;
  BuildJarAction.Enabled := CanBuild;
  RemoveJarAction.Enabled := JarsListBox.HasSelections;
  RemoveJavaFileAction.Enabled := JavaListBox.HasSelections;
  SaveJarConfigAction.Enabled := FIsModified;
  Handled := True;
end;

function TBuildJarView.CanBuild: Boolean;
var
  LOutputPath: string;
begin
  Result := False;
  LOutputPath := Trim(OutputFileEdit.Text);
  if not LOutputPath.IsEmpty then
  begin
    LOutputPath := TPath.GetDirectoryName(LOutputPath);
    Result := (JavaListBox.Items.Count > 0) and TDirectoryHelper.Exists(TPathHelper.GetAbsolutePath(GetConfigPath, LOutputPath)); // etc
  end;
end;

function TBuildJarView.CanModify: Boolean;
begin
  Result := not FConfigFileName.IsEmpty and TFile.Exists(FConfigFileName);
end;

procedure TBuildJarView.CloseButtonClick(Sender: TObject);
begin
  if FIsModified then
  begin
    case TDialog.YesNoCancel(Babel.Tx(sConfigChanged), TYesNoCancel.Cancel) of
      TYesNoCancel.Yes:
      begin
        SaveJarConfigAction.Execute;
        Close;
      end;
      TYesNoCancel.No:
        Close;
    end;
  end
  else
    Close;
end;

procedure TBuildJarView.AddJarActionExecute(Sender: TObject);
begin
  JarOpenDialog.DefaultFolder := Config.Android.JarFolder;
  if JarOpenDialog.Execute then
  begin
    AddJarFiles(JarOpenDialog.Files);
    Config.Android.JarFolder := JarOpenDialog.DefaultFolder;
    Modified;
  end;
end;

procedure TBuildJarView.AddJarFiles(const AFiles: TStrings);
var
  I: Integer;
begin
  for I := 0 to AFiles.Count - 1 do
  begin
    if JarsListBox.Items.IndexOf(AFiles[I]) = -1 then
    begin
      if AFiles[I].StartsWith(FBDSPath, True) then
        JarsListBox.Items.Add(AFiles[I].Replace(FBDSPath, cBDSMacro, [rfIgnoreCase]))
      else
        JarsListBox.Items.Add(TPathHelper.GetRelativePath(GetConfigPath, AFiles[I]));
    end;
  end;
end;

procedure TBuildJarView.AddJavaFileActionExecute(Sender: TObject);
begin
  JavaOpenDialog.DefaultFolder := Config.Android.JavaFolder;
  if JavaOpenDialog.Execute then
  begin
    AddJavaFiles(JavaOpenDialog.Files);
    Config.Android.JavaFolder := TPath.GetDirectoryName(JavaOpenDialog.FileName);
    Modified;
  end;
end;

procedure TBuildJarView.AddJavaFiles(const AFiles: TStrings);
var
  I: Integer;
begin
  for I := 0 to AFiles.Count - 1 do
  begin
    if JavaListBox.Items.IndexOf(AFiles[I]) = -1 then
      JavaListBox.Items.Add(TPathHelper.GetRelativePath(GetConfigPath, AFiles[I]));
  end;
end;

procedure TBuildJarView.AddJavaFolderActionExecute(Sender: TObject);
var
  I: Integer;
  LIsDuplicateFolder: Boolean;
begin
  if JavaFolderOpenDialog.Execute then
  begin
    LIsDuplicateFolder := False;
    for I := 0 to JavaListBox.Items.Count - 1 do
    begin
      if string(JavaFolderOpenDialog.FileName).StartsWith(TPath.GetDirectoryName(JavaListBox.Items[I])) then
      begin
        LIsDuplicateFolder := True;
        MessageDlg(Format(Babel.Tx(sJavaFolderAlreadyIncluded), [TPath.GetDirectoryName(JavaListBox.Items[I])]), mtWarning, [mbOK], 0);
        Break;
      end;
    end;
    if not LIsDuplicateFolder then
    begin
      JavaListBox.Items.Add(TPath.Combine(TPathHelper.GetRelativePath(GetConfigPath, JavaFolderOpenDialog.FileName), '*.java'));
      Modified;
    end;
  end;
end;

procedure TBuildJarView.RemoveJarActionExecute(Sender: TObject);
begin
  JarsListBox.DeletedSelected;
  Modified;
end;

procedure TBuildJarView.RemoveJavaFileActionExecute(Sender: TObject);
begin
  JavaListBox.DeletedSelected;
  Modified;
end;

procedure TBuildJarView.SelectOutputFileActionExecute(Sender: TObject);
var
  LOutputFileName: string;
begin
  LOutputFileName := string(OutputFileEdit.Text).Trim;
  if not LOutputFileName.IsEmpty then
    LOutputFileName := TPathHelper.GetAbsolutePath(GetConfigPath, LOutputFileName);
  if not LOutputFileName.IsEmpty and TDirectoryHelper.Exists(TPath.GetDirectoryName(LOutputFileName)) then
    JarSaveDialog.DefaultFolder := TPath.GetDirectoryName(LOutputFileName)
  else
    JarSaveDialog.DefaultFolder := Config.Android.JarOutputFolder;
  if JarSaveDialog.Execute then
  begin
    OutputFileEdit.Text := TPathHelper.GetRelativePath(GetConfigPath, JarSaveDialog.FileName);
    Modified;
  end;
end;

procedure TBuildJarView.ClearActionExecute(Sender: TObject);
begin
  if MessageDlg(Babel.Tx(sConfirmClearConfig), mtConfirmation, [mbYes, mbNo], 0) = mrYes then
  begin
    JarsListBox.Clear;
    JavaListBox.Clear;
    OutputFileEdit.Clear;
    SetVersions;
  end;
end;

procedure TBuildJarView.ClearControls;
begin
  JarsListBox.Clear;
  JavaListBox.Clear;
  OutputFileEdit.Clear;
  SetVersions;
end;

procedure TBuildJarView.SetVersions;
var
  LJDKVersion: string;
begin
  LJDKVersion := TPath.GetFileName(ExcludeTrailingPathDelimiter(FSDKRegistry.GetJDKPath));
  if LJDKVersion.StartsWith('jdk', True) then
  begin
    LJDKVersion := LJDKVersion.Substring(3, LJDKVersion.LastIndexOf('.') - 3);
    SourceVersionComboBox.ItemIndex := SourceVersionComboBox.Items.IndexOf(LJDKVersion);
    TargetVersionComboBox.ItemIndex := TargetVersionComboBox.Items.IndexOf(LJDKVersion);
  end;
end;

procedure TBuildJarView.SaveVersions;
begin
  SourceVersionComboBox.Tag := SourceVersionComboBox.ItemIndex;
  TargetVersionComboBox.Tag := TargetVersionComboBox.ItemIndex;
end;

procedure TBuildJarView.SourceVersionComboBoxChange(Sender: TObject);
begin
  if TargetVersionComboBox.ItemIndex < SourceVersionComboBox.ItemIndex then
  begin
    MessageDlg(Babel.Tx(sWarningCannotHaveLowerTarget), mtWarning, [mbOK], 0);
    SourceVersionComboBox.ItemIndex := SourceVersionComboBox.Tag;
    TargetVersionComboBox.ItemIndex := TargetVersionComboBox.Tag;
  end
  else
    SaveVersions;
  Modified;
end;

procedure TBuildJarView.SourceVersionComboBoxDropDown(Sender: TObject);
begin
  SaveVersions;
end;

procedure TBuildJarView.UpdateCaption;
begin
  Caption := sBuildAJarCaption + ' - ' + FConfigFileName;
end;

procedure TBuildJarView.AddAbsolutePaths(const AFiles, ASource: TStrings);
var
  I: Integer;
begin
  AFiles.Clear;
  for I := 0 to ASource.Count - 1 do
  begin
    if ASource[I].StartsWith(cBDSMacro, True) then
      AFiles.Add(ASource[I].Replace(cBDSMacro, FBDSPath, [rfIgnoreCase]))
    else
      AFiles.Add(TPathHelper.GetAbsolutePath(GetConfigPath, ASource[I]));
  end;
end;

procedure TBuildJarView.BuildJarActionExecute(Sender: TObject);
begin
  FOutputView.Memo.Clear;
  FCreateJar.APILevelPath := FSDKRegistry.GetSDKAPILevelPath;
  FCreateJar.JarFilename := TPathHelper.GetAbsolutePath(GetConfigPath, OutputFileEdit.Text);
  FCreateJar.JDKPath := TPath.Combine(FSDKRegistry.GetJDKPath, 'bin');
  FCreateJar.DexPath := FSDKRegistry.GetBuildToolsPath;
  FCreateJar.ShouldRetainWorkingFiles := RetainWorkingFilesCheckBox.Checked;
  FCreateJar.ShouldDex := DexCheckBox.Checked;
  AddAbsolutePaths(FCreateJar.JavaSourceFiles, JavaListBox.Items);
  AddAbsolutePaths(FCreateJar.IncludedJars, JarsListBox.Items);
  FCreateJar.SourceVersion := SourceVersionComboBox.Text;
  FCreateJar.TargetVersion := TargetVersionComboBox.Text;
  FCreateJar.Run;
end;

procedure TBuildJarView.OutputFileEditChange(Sender: TObject);
begin
  Modified;
end;

procedure TBuildJarView.OutputHandler(Sender: TObject; const AOutput: string);
begin
  FOutputView.Show;
  FOutputView.Memo.Lines.Add(AOutput);
end;

end.
