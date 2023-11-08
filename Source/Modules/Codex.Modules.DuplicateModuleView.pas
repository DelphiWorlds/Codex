unit Codex.Modules.DuplicateModuleView;

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
  DW.OTA.Registry,
  Codex.BaseView;

type
  TModuleInfo = record
    ExistingName: string;
    NewName: string;
    SourceID: string;
    TargetID: string;
    WantAddToProject: Boolean;
    procedure Reset;
  end;

  TDuplicateModuleView = class(TForm)
    ContentsPanel: TPanel;
    DetailsPanel: TPanel;
    ExistingNameLabel: TLabel;
    DialogButtonsPanel: TPanel;
    CancelButton: TButton;
    OKButton: TButton;
    ExistingNameEdit: TEdit;
    ModuleIDPanel: TPanel;
    SelectModuleButton: TSpeedButton;
    ModuleIDLabel: TLabel;
    ModuleIDEdit: TEdit;
    ActionList: TActionList;
    ModuleOpenDialog: TFileOpenDialog;
    OKAction: TAction;
    NewNameLabel: TLabel;
    NewNameEdit: TEdit;
    ModuleSaveDialog: TFileSaveDialog;
    AddToProjectCheckBox: TCheckBox;
    procedure OKActionExecute(Sender: TObject);
    procedure OKActionUpdate(Sender: TObject);
    procedure ModuleIDEditChange(Sender: TObject);
    procedure SelectModuleButtonClick(Sender: TObject);
    procedure NewNameEditChange(Sender: TObject);
  private
    FBDSRegistry: TBDSRegistry;
    FModuleInfo: TModuleInfo;
    function GetModuleSuffix: string;
    procedure UpdateExistingName;
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    property ModuleInfo: TModuleInfo read FModuleInfo write FModuleInfo;
  end;

var
  DuplicateModuleView: TDuplicateModuleView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  DW.IOUtils.Helpers, DW.OTA.Helpers,
  Codex.Consts,
  Codex.Modules.Types, Codex.Core;

const
  cRegistryCodexModulesSubKey = cRegistryCodexSubKey + '\Modules';

resourcestring
  sSaveSource = 'Save source';
  sSaveSourceAndResource = 'Save source and %s';

{ TModuleInfo }

procedure TModuleInfo.Reset;
begin
  ExistingName := '';
  NewName := '';
  SourceID := '';
  TargetID := '';
end;

{ TDuplicateModuleView }

constructor TDuplicateModuleView.Create(AOwner: TComponent);
begin
  inherited;
  FBDSRegistry := TBDSRegistry.Current;
end;

procedure TDuplicateModuleView.DoShow;
begin
  inherited;
  AddToProjectCheckBox.Enabled := TOTAHelper.GetActiveProject <> nil;
end;

function TDuplicateModuleView.GetModuleSuffix: string;
begin
  Result := '';
  if not FModuleInfo.SourceID.IsEmpty then
  begin
    if TFile.Exists(FModuleInfo.SourceID + '.fmx') then
      Result := 'fmx'
    else if TFile.Exists(FModuleInfo.SourceID + '.dfm') then
      Result := 'dfm';
  end;
end;

procedure TDuplicateModuleView.ModuleIDEditChange(Sender: TObject);
begin
  UpdateExistingName;
end;

function GetPathWithoutExtension(const AFileName: string): string;
begin
  Result := TPath.Combine(TPath.GetDirectoryName(AFileName), TPath.GetFileNameWithoutExtension(AFileName));
end;

procedure TDuplicateModuleView.UpdateExistingName;
begin
  if TFile.Exists(ModuleIDEdit.Text) then
  begin
    FModuleInfo.SourceID := GetPathWithoutExtension(ModuleIDEdit.Text);
    FModuleInfo.ExistingName := TFormTemplateProcessor.GetExistingName(FModuleInfo.SourceID);
    ExistingNameEdit.Text := FModuleInfo.ExistingName;
    NewNameEdit.Enabled := not string(ExistingNameEdit.Text).IsEmpty;
    if not NewNameEdit.Enabled then
      NewNameEdit.Text := '';
  end
  else
    FModuleInfo.Reset;
end;

procedure TDuplicateModuleView.NewNameEditChange(Sender: TObject);
begin
  UpdateExistingName;
end;

procedure TDuplicateModuleView.OKActionExecute(Sender: TObject);
var
  LSuffix: string;
begin
  LSuffix := GetModuleSuffix;
  ModuleSaveDialog.Title := Babel.Tx(sSaveSource);
  if not LSuffix.IsEmpty then
    ModuleSaveDialog.Title := Format(Babel.Tx(sSaveSourceAndResource),[LSuffix]);
  ModuleSaveDialog.DefaultFolder := FBDSRegistry.ReadSubKeyString(cRegistryCodexModulesSubKey, 'DefaultSaveFolder');
  if ModuleSaveDialog.Execute then
  begin
    FBDSRegistry.WriteSubKeyString(cRegistryCodexModulesSubKey, 'DefaultSaveFolder', TPath.GetDirectoryName(ModuleSaveDialog.FileName));
    FModuleInfo.TargetID := GetPathWithoutExtension(ModuleSaveDialog.FileName);
    FModuleInfo.NewName := NewNameEdit.Text;
    FModuleInfo.WantAddToProject := AddToProjectCheckBox.Checked;
    ModalResult := mrOK
  end;
end;

procedure TDuplicateModuleView.OKActionUpdate(Sender: TObject);
begin
  OKAction.Enabled := TFile.Exists(ModuleIDEdit.Text) and (not NewNameEdit.Enabled or not string(NewNameEdit.Text).Trim.IsEmpty);
end;

procedure TDuplicateModuleView.SelectModuleButtonClick(Sender: TObject);
begin
  ModuleOpenDialog.DefaultFolder := FBDSRegistry.ReadSubKeyString(cRegistryCodexModulesSubKey, 'DefaultOpenFolder');
  if ModuleOpenDialog.Execute then
  begin
    FBDSRegistry.WriteSubKeyString(cRegistryCodexModulesSubKey, 'DefaultOpenFolder', TPath.GetDirectoryName(ModuleOpenDialog.FileName));
    ModuleIDEdit.Text := ModuleOpenDialog.FileName;
    UpdateExistingName;
    if NewNameEdit.Enabled then
      NewNameEdit.SetFocus;
  end;
end;

end.
