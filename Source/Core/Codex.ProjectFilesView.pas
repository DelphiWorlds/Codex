unit Codex.ProjectFilesView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList, Vcl.StdCtrls, Vcl.ExtCtrls,
  Codex.BaseView,
  Codex.ProjectFiles;

type
  TProjectFilesView = class(TForm)
    ActionList: TActionList;
    AddFilesAction: TAction;
    RemoveFilesAction: TAction;
    ProjectFilesPanel: TPanel;
    FilesLabel: TLabel;
    FilesButtonsPanel: TPanel;
    RemoveFileButton: TButton;
    AddFileButton: TButton;
    FilesListBox: TListBox;
    FilesOpenDialog: TFileOpenDialog;
    CloseButton: TButton;
    procedure AddFilesActionExecute(Sender: TObject);
    procedure RemoveFilesActionExecute(Sender: TObject);
    procedure RemoveFilesActionUpdate(Sender: TObject);
  private
    FProjectFiles: TProjectFiles;
    FProjectFilesFileName: string;
    FProjectName: string;
    procedure SetProjectFilesFileName(const Value: string);
    procedure SetProjectName(const Value: string);
    procedure UpdateProjectFiles;
  public
    constructor Create(AOwner: TComponent); override;
    property ProjectFilesFileName: string read FProjectFilesFileName write SetProjectFilesFileName;
    property ProjectName: string read FProjectName write SetProjectName;
  end;

var
  ProjectFilesView: TProjectFilesView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  DW.Vcl.ListBoxHelper, DW.OTA.Helpers,
  Codex.Core;

resourcestring
  sProjectFilesForProject = 'Project files for: %s';

{ TProjectFilesView }

constructor TProjectFilesView.Create(AOwner: TComponent);
begin
  inherited;
  TOTAHelper.ApplyTheme(Self);
end;

procedure TProjectFilesView.SetProjectFilesFileName(const Value: string);
var
  LFileName: string;
begin
  if Value <> FProjectFilesFileName then
  begin
    FProjectFilesFileName := Value;
    FProjectFiles := TProjectFiles.Create(FProjectFilesFileName);
    FilesListBox.Items.Clear;
    for LFileName in FProjectFiles.ProjectFileNames do
      FilesListBox.Items.Add(LFileName);
  end;
end;

procedure TProjectFilesView.SetProjectName(const Value: string);
begin
  FProjectName := Value;
  Caption := Format(Babel.Tx(sProjectFilesForProject), [FProjectName]);
end;

procedure TProjectFilesView.UpdateProjectFiles;
begin
  FProjectFiles.ProjectFileNames := FilesListBox.Items.ToStringArray;
  FProjectFiles.Save;
end;

procedure TProjectFilesView.AddFilesActionExecute(Sender: TObject);
var
  I: Integer;
  LIsChanged: Boolean;
begin
  if FilesOpenDialog.Execute then
  begin
    LIsChanged := False;
    for I := 0 to FilesOpenDialog.Files.Count - 1 do
    begin
      if FilesListBox.Items.IndexOf(FilesOpenDialog.Files[I]) = -1 then
      begin
        FilesListBox.Items.Add(FilesOpenDialog.Files[I]);
        LIsChanged := True;
      end;
    end;
    if LIsChanged then
      UpdateProjectFiles;
  end;
end;

procedure TProjectFilesView.RemoveFilesActionExecute(Sender: TObject);
begin
  FilesListBox.DeletedSelected;
  UpdateProjectFiles;
end;

procedure TProjectFilesView.RemoveFilesActionUpdate(Sender: TObject);
begin
  RemoveFilesAction.Enabled := FilesListBox.HasSelections;
end;

end.
