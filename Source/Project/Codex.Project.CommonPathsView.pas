unit Codex.Project.CommonPathsView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, System.Actions, Vcl.ActnList,
  DW.OTA.Types, DW.OTA.ProjConfigComboBox,
  Codex.BaseView;

type
  TCommonPathsView = class(TForm)
    CommandButtonsPanel: TPanel;
    CopyButton: TButton;
    CloseButton: TButton;
    ActionList: TActionList;
    ProjectOpenDialog: TFileOpenDialog;
    RecentProjectsPanel: TPanel;
    ProjectsLabel: TLabel;
    FileButtonsPanel: TPanel;
    RemoveFileButton: TButton;
    AddFileButton: TButton;
    ProjectsListBox: TListBox;
    AddProjectAction: TAction;
    RemoveProjectAction: TAction;
    ProjectPathsPanel: TPanel;
    ProjectPathsLabel: TLabel;
    MessageLabel: TLabel;
    MessageTimer: TTimer;
    ConfigPanel: TPanel;
    CopyAction: TAction;
    ProjectPathsListBox: TListBox;
    procedure CopyActionExecute(Sender: TObject);
    procedure AddProjectActionExecute(Sender: TObject);
    procedure RemoveProjectActionExecute(Sender: TObject);
    procedure RemoveProjectActionUpdate(Sender: TObject);
    procedure ProjectsListBoxClick(Sender: TObject);
    procedure MessageTimerTimer(Sender: TObject);
    procedure CopyActionUpdate(Sender: TObject);
  private
    ProjectConfigComboBox: TProjConfigComboBox;
    procedure ProjectConfigComboBoxChangeHandler(Sender: TObject);
    procedure SetMessage(const AMessage: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  CommonPathsView: TCommonPathsView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  Vcl.Clipbrd,
  DW.OTA.Consts,
  Codex.Config, Codex.Core, Codex.Consts.Text;

resourcestring
  sProjectHasBeenMoved = 'Project has been moved or deleted';

{ TCommonPathsView }

constructor TCommonPathsView.Create(AOwner: TComponent);
begin
  inherited;
  ProjectConfigComboBox := TProjConfigComboBox.Create(Self);
  ProjectConfigComboBox.OnChange := ProjectConfigComboBoxChangeHandler;
  ProjectConfigComboBox.AlignWithMargins := True;
  ProjectConfigComboBox.Align := TAlign.alClient;
  ProjectConfigComboBox.Parent := ConfigPanel;
  MessageLabel.Visible := False;
  ProjectsListBox.Items.AddStrings(Config.CommonPathsProjects);
  ProjectsListBoxClick(ProjectsListBox);
end;

destructor TCommonPathsView.Destroy;
begin
  //
  inherited;
end;

procedure TCommonPathsView.MessageTimerTimer(Sender: TObject);
begin
  MessageLabel.Visible := False;
  MessageTimer.Enabled := False;
end;

procedure TCommonPathsView.ProjectConfigComboBoxChangeHandler(Sender: TObject);
begin
  ProjectPathsListBox.Clear;
  ProjectPathsListBox.Items.AddStrings(ProjectConfigComboBox.GetSelectedSearchPaths);
end;

procedure TCommonPathsView.ProjectsListBoxClick(Sender: TObject);
var
  LFileName: string;
begin
  if ProjectsListBox.ItemIndex > -1 then
  begin
    LFileName := ProjectsListBox.Items[ProjectsListBox.ItemIndex];
    if not ProjectConfigComboBox.FileName.Equals(LFileName) then
    begin
      ProjectPathsListBox.Items.Clear;
      ProjectConfigComboBox.Clear;
      if TFile.Exists(LFileName) then
        ProjectConfigComboBox.FileName := LFileName
      else
        SetMessage(Babel.Tx(sProjectHasBeenMoved));
      if ProjectConfigComboBox.Enabled then
        ProjectConfigComboBoxChangeHandler(ProjectConfigComboBox);
    end;
  end
  else
  begin
    ProjectConfigComboBox.Clear;
    ProjectPathsListBox.Items.Clear;
  end;
end;

procedure TCommonPathsView.RemoveProjectActionExecute(Sender: TObject);
var
  I: Integer;
begin
  I := 0;
  repeat
    if ProjectsListBox.Selected[I] then
    begin
      Config.RemoveCommonPathsProject(I);
      ProjectsListBox.Items.Delete(I);
    end
    else
      Inc(I);
  until I = ProjectsListBox.Items.Count;
  ProjectsListBoxClick(ProjectsListBox);
end;

procedure TCommonPathsView.RemoveProjectActionUpdate(Sender: TObject);
begin
  RemoveProjectAction.Enabled := ProjectsListBox.SelCount > 0;
end;

procedure TCommonPathsView.SetMessage(const AMessage: string);
begin
  MessageTimer.Enabled := False;
  MessageLabel.Caption := AMessage;
  MessageLabel.Visible := True;
  MessageTimer.Enabled := True;
end;

procedure TCommonPathsView.AddProjectActionExecute(Sender: TObject);
begin
  if ProjectOpenDialog.Execute then
  begin
    if ProjectsListBox.Items.IndexOf(ProjectOpenDialog.FileName) = -1 then
    begin
      Config.AddCommonPathsProject(ProjectOpenDialog.FileName);
      ProjectsListBox.Items.Insert(0, ProjectOpenDialog.FileName);
    end;
    ProjectsListBox.ItemIndex := ProjectsListBox.Items.IndexOf(ProjectOpenDialog.FileName);
    ProjectsListBoxClick(ProjectsListBox);
  end;
end;

procedure TCommonPathsView.CopyActionExecute(Sender: TObject);
begin
  Clipboard.AsText := string.Join(';', ProjectPathsListBox.Items.ToStringArray);
  SetMessage(Babel.Tx(sCopiedToClipboard));
end;

procedure TCommonPathsView.CopyActionUpdate(Sender: TObject);
begin
  CopyAction.Enabled := ProjectPathsListBox.Items.Count > 0;
end;

end.
