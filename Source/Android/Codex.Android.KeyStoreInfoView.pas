unit Codex.Android.KeyStoreInfoView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, System.Actions, Vcl.ActnList,
  Codex.BaseView;

type
  TKeyStoreFormMode = (KeyStore, ExtractAPKs, InstallBundle);

  TKeyStoreInfoView = class(TForm)
    KeystoreFilePanel: TPanel;
    SelectKeystoreFileButton: TSpeedButton;
    KeystoreFileLabel: TLabel;
    KeystoreFileNameEdit: TEdit;
    KeystoreAliasPanel: TPanel;
    KeystoreAliasLabel: TLabel;
    KeyStoreAliasEdit: TEdit;
    KeystorePassPanel: TPanel;
    KeystorePassLabel: TLabel;
    KeyStorePassEdit: TEdit;
    KeystoreAliasPassPanel: TPanel;
    KeystoreAliasPassLabel: TLabel;
    KeyStoreAliasPassEdit: TEdit;
    CommandButtonsPanel: TPanel;
    CancelButton: TButton;
    OKButton: TButton;
    ActionList: TActionList;
    OKAction: TAction;
    AABPanel: TPanel;
    SelectAABFileButton: TSpeedButton;
    AABLabel: TLabel;
    AABFileNameEdit: TEdit;
    AABFileOpenDialog: TFileOpenDialog;
    KeyStoreFileOpenDialog: TFileOpenDialog;
    SelectAABFileAction: TAction;
    SelectKeyStoreFileAction: TAction;
    procedure OKActionUpdate(Sender: TObject);
    procedure OKActionExecute(Sender: TObject);
    procedure SelectAABFileActionExecute(Sender: TObject);
    procedure SelectKeyStoreFileActionExecute(Sender: TObject);
  private
    FFormMode: TKeyStoreFormMode;
    function GetClientHeight(const Value: TKeyStoreFormMode): Integer;
    procedure SetFormMode(const Value: TKeyStoreFormMode);
  protected
    procedure DoShow; override;
  public
    property FormMode: TKeyStoreFormMode read FFormMode write SetFormMode;
  end;

var
  KeyStoreInfoView: TKeyStoreInfoView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  DW.OTA.Helpers,
  Codex.Config, Codex.Core, Codex.Consts.Text;

type
  TControlHelper = class helper for TControl
    function AbsoluteHeight: Integer;
  end;

{ TControlHelper }

function TControlHelper.AbsoluteHeight: Integer;
begin
  Result := Height;
  if AlignWithMargins and (Align <> TAlign.alNone) then
   Result := Result + Margins.Top + Margins.Bottom;
end;

{ TKeyStoreInfoView }

procedure TKeyStoreInfoView.DoShow;
var
  LProjectBuildBinPath: string;
  LKeyStoreItem: TKeyStoreItem;
begin
  inherited;
  LProjectBuildBinPath := TPath.Combine(TOTAHelper.GetActiveProjectBuildPath, 'bin');
  if not LProjectBuildBinPath.IsEmpty then
    Config.Android.DefaultAABFileName := TPath.Combine(LProjectBuildBinPath, TOTAHelper.GetActiveProjectSanitizedProjectName) + '.aab';
  if not Config.Android.DefaultAABFileName.IsEmpty and TFile.Exists(Config.Android.DefaultAABFileName) then
    AABFileNameEdit.Text := Config.Android.DefaultAABFileName;
  if string(KeystoreFileNameEdit.Text).IsEmpty and Config.Android.FindKeyStoreItemDefault(LKeyStoreItem) then
  begin
    KeystoreFileNameEdit.Text := LKeyStoreItem.KeyStoreFileName;
    KeystorePassEdit.Text := LKeyStoreItem.KeyStorePass;
    KeystoreAliasEdit.Text := LKeyStoreItem.KeyAlias;
    KeystoreAliasPassEdit.Text := LKeyStoreItem.KeyAliasPass;
  end;
end;

function TKeyStoreInfoView.GetClientHeight(const Value: TKeyStoreFormMode): Integer;
begin
  Result := CustomTitleBarHeight + KeystoreFilePanel.AbsoluteHeight + KeystorePassPanel.AbsoluteHeight + KeystoreAliasPanel.AbsoluteHeight
    + KeystoreAliasPassPanel.AbsoluteHeight + CommandButtonsPanel.AbsoluteHeight;
  if Value <> TKeyStoreFormMode.KeyStore then
    Inc(Result, AABPanel.AbsoluteHeight);
end;

procedure TKeyStoreInfoView.OKActionExecute(Sender: TObject);
begin
  Config.Android.SetKeyStoreItem(KeystoreFileNameEdit.Text, KeystorePassEdit.Text, KeystoreAliasEdit.Text, KeystoreAliasPassEdit.Text, True);
  Config.Android.DefaultAABFileName := AABFileNameEdit.Text;
  Config.Save;
  ModalResult := mrOK;
end;

procedure TKeyStoreInfoView.OKActionUpdate(Sender: TObject);
begin
  OKAction.Enabled := TFile.Exists(KeystoreFileNameEdit.Text) and not string(KeystorePassEdit.Text).Trim.IsEmpty and
    not string(KeystoreAliasPassEdit.Text).Trim.IsEmpty and not string(KeystoreAliasEdit.Text).Trim.IsEmpty
    and ((FFormMode = TKeyStoreFormMode.KeyStore) or TFile.Exists(AABFileNameEdit.Text));
end;

procedure TKeyStoreInfoView.SelectAABFileActionExecute(Sender: TObject);
begin
  if AABFileOpenDialog.Execute then
    AABFileNameEdit.Text := AABFileOpenDialog.FileName;
end;

procedure TKeyStoreInfoView.SelectKeyStoreFileActionExecute(Sender: TObject);
begin
  if KeyStoreFileOpenDialog.Execute then
    KeystoreFileNameEdit.Text := KeyStoreFileOpenDialog.FileName;
end;

procedure TKeyStoreInfoView.SetFormMode(const Value: TKeyStoreFormMode);
const
  cFormCaptions: array[TKeyStoreFormMode] of string = (sRebuildBundleWithAssetPacksCaption, sExtractAPKFromAABCaption, sInstallAABCaption);
begin
  FFormMode := Value;
  Caption := Babel.Tx(cFormCaptions[FFormMode]);
  AABPanel.Visible := FFormMode in [TKeyStoreFormMode.ExtractAPKs, TKeyStoreFormMode.InstallBundle];
  ClientHeight := GetClientHeight(FFormMode);
  Constraints.MaxHeight := Height;
  Constraints.MinHeight := Height;
end;

end.
