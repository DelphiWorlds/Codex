unit Codex.Android.Java2OPView;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Actions, Vcl.ActnList, Vcl.Buttons,
  Codex.OutputView, Codex.Android.Java2OPProcess, Codex.BaseView;

type
  TJava2OPView = class(TForm)
    JarsPanel: TPanel;
    JarsButtonsPanel: TPanel;
    RemoveClassButton: TButton;
    AddClassButton: TButton;
    ClassesListBox: TListBox;
    SourceFoldersPanel: TPanel;
    SourceFoldersButtonsPanel: TPanel;
    RemoveSourceFolderButton: TButton;
    AddSourceFolderButton: TButton;
    SourceFoldersListBox: TListBox;
    ActionList: TActionList;
    CommandButtonsPanel: TPanel;
    BuildJarButton: TButton;
    OutputFilePanel: TPanel;
    SelectOutputFileButton: TSpeedButton;
    OutputFileEdit: TEdit;
    AddSourceFolderAction: TAction;
    RemoveSourceFolderAction: TAction;
    AddClassAction: TAction;
    RemoveClassAction: TAction;
    RunAction: TAction;
    JarOpenDialog: TFileOpenDialog;
    SourceFolderOpenDialog: TFileOpenDialog;
    SelectOutputFileAction: TAction;
    OutputFileSaveDialog: TFileSaveDialog;
    ClassEdit: TEdit;
    ClearOutputFileButton: TSpeedButton;
    JarFilesPanel: TPanel;
    JarFilesListBox: TListBox;
    JarFilesButtonsPanel: TPanel;
    RemoveJarFileButton: TButton;
    AddJarFileButton: TButton;
    AddJarAction: TAction;
    RemoveJarAction: TAction;
    PostProcessingCheckBox: TCheckBox;
    ClassPathPanel: TPanel;
    ClassPathButtonsPanel: TPanel;
    RemoveClassPathFolderButton: TButton;
    AddClassPathFolderButton: TButton;
    ClassPathListBox: TListBox;
    AddClassPathFolderAction: TAction;
    RemoveClassPathFolderAction: TAction;
    CloseButton: TButton;
    ClassesLabel: TLabel;
    JarFilesLabel: TLabel;
    SourceFoldersLabel: TLabel;
    ClassPathsLabel: TLabel;
    OutputFileLabel: TLabel;
    procedure AddSourceFolderActionExecute(Sender: TObject);
    procedure AddClassActionExecute(Sender: TObject);
    procedure RemoveSourceFolderActionExecute(Sender: TObject);
    procedure RemoveClassActionExecute(Sender: TObject);
    procedure SelectOutputFileActionExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure RunActionExecute(Sender: TObject);
    procedure ClearOutputFileButtonClick(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure AddJarActionExecute(Sender: TObject);
    procedure RemoveJarActionExecute(Sender: TObject);
    procedure AddClassPathFolderActionExecute(Sender: TObject);
    procedure RemoveClassPathFolderActionExecute(Sender: TObject);
  private
    FJava2OP: TJava2OPProcess;
    FOutputView: TOutputView;
    function CanRun: Boolean;
    function HasItems(const AItems: TListBox): Boolean;
    function HasJars: Boolean;
    function IsClassValid: Boolean;
    function IsOutputFileNameValid: Boolean;
    procedure OutputHandler(Sender: TObject; const AOutput: string);
    procedure UpdateClassPathListBox;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  Java2OPView: TJava2OPView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  DW.IOUtils.Helpers, DW.OTA.Helpers, DW.Vcl.ListBoxHelper,
  Codex.Config;

constructor TJava2OPView.Create(AOwner: TComponent);
begin
  inherited;
  FJava2OP := TJava2OPProcess.Create;
  FJava2OP.OnProcessOutput := OutputHandler;
  FOutputView := TOutputView.Create(Self);
  UpdateClassPathListBox;
end;

destructor TJava2OPView.Destroy;
begin
  FJava2OP.Free;
  inherited;
end;

function TJava2OPView.HasItems(const AItems: TListBox): Boolean;
begin
  Result := AItems.Items.Count > 0;
end;

function TJava2OPView.HasJars: Boolean;
begin
  Result := JarFilesListBox.Items.Count > 0;
end;

function TJava2OPView.IsClassValid: Boolean;
begin
  Result := (Pos(' ', ClassEdit.Text) = 0) and (ClassEdit.Text <> '');
end;

function TJava2OPView.IsOutputFileNameValid: Boolean;
begin
  Result := (OutputFileEdit.Text = '') or TDirectoryHelper.Exists(TPath.GetDirectoryName(OutputFileEdit.Text));
end;

procedure TJava2OPView.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  RunAction.Enabled := CanRun;
  AddClassAction.Enabled := IsClassValid and (ClassesListBox.Items.IndexOf(ClassEdit.Text) = -1);
  RemoveClassAction.Enabled := ClassesListBox.HasSelections;
  RemoveJarAction.Enabled := JarFilesListBox.HasSelections;
  RemoveSourceFolderAction.Enabled := SourceFoldersListBox.HasSelections;
  RemoveClassPathFolderAction.Enabled := ClassPathListBox.HasSelections;
  Handled := True;
end;

function TJava2OPView.CanRun: Boolean;
begin
  Result := (HasJars or HasItems(ClassesListBox)) and IsOutputFileNameValid;
end;

procedure TJava2OPView.ClearOutputFileButtonClick(Sender: TObject);
begin
  OutputFileEdit.Text := '';
end;

procedure TJava2OPView.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TJava2OPView.AddSourceFolderActionExecute(Sender: TObject);
begin
  SourceFolderOpenDialog.DefaultFolder := Config.Android.Java2OP.DefaultSourceFolder;
  if SourceFolderOpenDialog.Execute then
  begin
    Config.Android.Java2OP.DefaultSourceFolder := TPath.GetDirectoryName(SourceFolderOpenDialog.FileName);
    if SourceFoldersListBox.Items.IndexOf(SourceFolderOpenDialog.FileName) = -1 then
      SourceFoldersListBox.Items.Add(SourceFolderOpenDialog.FileName);
  end;
end;

procedure TJava2OPView.AddClassActionExecute(Sender: TObject);
begin
  ClassesListBox.Items.Add(ClassEdit.Text);
end;

procedure TJava2OPView.AddClassPathFolderActionExecute(Sender: TObject);
begin
  SourceFolderOpenDialog.DefaultFolder := Config.Android.Java2OP.DefaultClassPathFolder;
  if SourceFolderOpenDialog.Execute then
  begin
    Config.Android.Java2OP.DefaultClassPathFolder := SourceFolderOpenDialog.FileName;
    if ClassPathListBox.Items.IndexOf(SourceFolderOpenDialog.FileName) = -1 then
      ClassPathListBox.Items.Add(SourceFolderOpenDialog.FileName);
  end;
end;

procedure TJava2OPView.RemoveSourceFolderActionExecute(Sender: TObject);
begin
  SourceFoldersListBox.DeletedSelected;
end;

procedure TJava2OPView.RemoveClassActionExecute(Sender: TObject);
begin
  ClassesListBox.DeletedSelected;
end;

procedure TJava2OPView.RemoveClassPathFolderActionExecute(Sender: TObject);
begin
  ClassPathListBox.DeletedSelected;
end;

procedure TJava2OPView.AddJarActionExecute(Sender: TObject);
var
  I: Integer;
begin
  JarOpenDialog.DefaultFolder := Config.Android.Java2OP.DefaultJarFolder;
  if JarOpenDialog.Execute then
  begin
    Config.Android.Java2OP.DefaultJarFolder := TPath.GetDirectoryName(JarOpenDialog.Files[0]);
    for I := 0 to JarOpenDialog.Files.Count - 1 do
      JarFilesListBox.Items.Add(JarOpenDialog.Files[I]);
  end;
end;

procedure TJava2OPView.RemoveJarActionExecute(Sender: TObject);
begin
  JarFilesListBox.DeletedSelected;
end;

procedure TJava2OPView.SelectOutputFileActionExecute(Sender: TObject);
begin
  if TDirectoryHelper.Exists(TPathHelper.GetDirectoryName(OutputFileEdit.Text)) then
    OutputFileSaveDialog.DefaultFolder := TPathHelper.GetDirectoryName(OutputFileEdit.Text);
//  else
//    OutputFileSaveDialog.DefaultFolder := TAndroidConfig.Current.JarOutputFolder;
  if OutputFileSaveDialog.Execute then
    OutputFileEdit.Text := OutputFileSaveDialog.FileName;
end;

procedure TJava2OPView.UpdateClassPathListBox;
var
  LPaths: TArray<string>;
  LPath: string;
begin
  LPaths := GetEnvironmentVariable('CLASSPATH').Split([';']);
  for LPath in LPaths do
    ClassPathListBox.Items.Add(LPath);
end;

procedure TJava2OPView.RunActionExecute(Sender: TObject);
begin
  FOutputView.Memo.Clear;
  FJava2OP.IncludedClasses.Assign(ClassesListBox.Items);
  FJava2OP.JavaSourceFolders.Assign(SourceFoldersListBox.Items);
  FJava2OP.JarFiles.Assign(JarFilesListBox.Items);
  FJava2OP.NeedsPostProcessing := PostProcessingCheckBox.Checked;
  FJava2OP.OutputFilename := OutputFileEdit.Text;
  FJava2OP.ClassPath.Assign(ClassPathListBox.Items);
  FJava2OP.Run;
end;

procedure TJava2OPView.OutputHandler(Sender: TObject; const AOutput: string);
begin
  FOutputView.Show;
  FOutputView.Memo.Lines.Add(AOutput);
end;

end.
