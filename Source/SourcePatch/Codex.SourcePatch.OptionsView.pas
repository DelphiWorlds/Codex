unit Codex.SourcePatch.OptionsView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Codex.Options;

type
  TSourcePatchOptionsView = class(TForm, IConfigOptionsSection)
    RootPanel: TPanel;
    SourceCopyPathPanel: TPanel;
    SelectSourceCopyPathButton: TSpeedButton;
    SourceCopyPathLabel: TLabel;
    SourceCopyPathEdit: TEdit;
    SourceCopyProjectRelativeCheckBox: TCheckBox;
    PatchFilesLocationPanel: TPanel;
    SelectPatchFilesLocationButton: TSpeedButton;
    PatchFilesLocationLabel: TLabel;
    PatchFilesFolderEdit: TEdit;
    SourceCopyAlwaysPromptCheckBox: TCheckBox;
    ShouldOpenSourceFilesCheckBox: TCheckBox;
    SourceCopyFolderOpenDialog: TFileOpenDialog;
    PatchFilesFolderOpenDialog: TFileOpenDialog;
    procedure SourceCopyProjectRelativeCheckBoxClick(Sender: TObject);
    procedure SelectSourceCopyPathButtonClick(Sender: TObject);
    procedure SelectPatchFilesLocationButtonClick(Sender: TObject);
  private
    procedure UpdateControls;
  public
    { IConfigOptionsSection }
    function GetRootControl: TControl;
    function SectionID: string;
    function SectionTitle: string;
    procedure Save;
    procedure ShowSection;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  SourcePatchOptionsView: TSourcePatchOptionsView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  Codex.Config, Codex.Core;

resourcestring
  sSourcePatchTitle = 'Source Patch';
  sSourceCopyRelativeCaption = 'Folder relative to project to copy source to: (blank means same folder as project)';
  sSourceCopyDefaultFolderCaption = 'Default folder to copy source to:';

{ TSourcePatchOptionsView }

constructor TSourcePatchOptionsView.Create(AOwner: TComponent);
begin
  inherited;
  //
end;

function TSourcePatchOptionsView.GetRootControl: TControl;
begin
  Result := RootPanel;
end;

procedure TSourcePatchOptionsView.Save;
begin
  Config.SourcePatch.AlwaysPromptSourceCopyPath := SourceCopyAlwaysPromptCheckBox.Checked;
  Config.SourcePatch.SourceCopyPath := SourceCopyPathEdit.Text;
  Config.SourcePatch.IsSourceCopyProjectRelative := SourceCopyProjectRelativeCheckBox.Checked;
  Config.SourcePatch.PatchFilesPath := PatchFilesFolderEdit.Text;
  Config.SourcePatch.ShouldOpenSourceFiles := ShouldOpenSourceFilesCheckBox.Checked;
end;

function TSourcePatchOptionsView.SectionID: string;
begin
  Result := 'SourcePatch';
end;

procedure TSourcePatchOptionsView.ShowSection;
begin
  SourceCopyAlwaysPromptCheckBox.Checked := Config.SourcePatch.AlwaysPromptSourceCopyPath;
  SourceCopyPathEdit.Text := Config.SourcePatch.SourceCopyPath;
  SourceCopyProjectRelativeCheckBox.Checked := Config.SourcePatch.IsSourceCopyProjectRelative;
  PatchFilesFolderEdit.Text := Config.SourcePatch.PatchFilesPath;
  ShouldOpenSourceFilesCheckBox.Checked := Config.SourcePatch.ShouldOpenSourceFiles;
  UpdateControls;
end;

function TSourcePatchOptionsView.SectionTitle: string;
begin
  Result := Babel.Tx(sSourcePatchTitle);
end;

procedure TSourcePatchOptionsView.SelectPatchFilesLocationButtonClick(Sender: TObject);
begin
  if not string(PatchFilesFolderEdit.Text).Trim.IsEmpty and TDirectory.Exists(PatchFilesFolderEdit.Text) then
    PatchFilesFolderOpenDialog.DefaultFolder := PatchFilesFolderEdit.Text;
  if PatchFilesFolderOpenDialog.Execute then
    PatchFilesFolderEdit.Text := PatchFilesFolderOpenDialog.FileName;
end;

procedure TSourcePatchOptionsView.SelectSourceCopyPathButtonClick(Sender: TObject);
begin
  if not string(SourceCopyPathEdit.Text).Trim.IsEmpty and TDirectory.Exists(SourceCopyPathEdit.Text) then
    SourceCopyFolderOpenDialog.DefaultFolder := SourceCopyPathEdit.Text;
  if SourceCopyFolderOpenDialog.Execute then
    SourceCopyPathEdit.Text := SourceCopyFolderOpenDialog.FileName;
end;

procedure TSourcePatchOptionsView.SourceCopyProjectRelativeCheckBoxClick(Sender: TObject);
begin
  UpdateControls;
  if Visible and SourceCopyProjectRelativeCheckBox.Checked then
    SourceCopyPathEdit.Text := '';
end;

procedure TSourcePatchOptionsView.UpdateControls;
begin
  SelectSourceCopyPathButton.Enabled := not SourceCopyProjectRelativeCheckBox.Checked;
  if SourceCopyProjectRelativeCheckBox.Checked then
    SourceCopyPathLabel.Caption := Babel.Tx(sSourceCopyRelativeCaption)
  else
    SourceCopyPathLabel.Caption := Babel.Tx(sSourceCopyDefaultFolderCaption);
end;

initialization
  TConfigOptionsHelper.RegisterOptions(TSourcePatchOptionsView);

end.
