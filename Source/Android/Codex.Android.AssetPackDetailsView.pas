unit Codex.Android.AssetPackDetailsView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, System.Actions, Vcl.ActnList,
  Codex.BaseView, Codex.Android.AssetPackTypes;

type
  TAssetPackDetailsView = class(TForm)
    AssetPackDetailsPanel: TPanel;
    PackFolderLabel: TLabel;
    AssetPackTypeLabel: TLabel;
    PackKindComboBox: TComboBox;
    PackNameLabel: TLabel;
    PackNameEdit: TEdit;
    CommandButtonsPanel: TPanel;
    CancelButton: TButton;
    OKButton: TButton;
    PackPackageNameLabel: TLabel;
    PackageEdit: TEdit;
    FolderComboBox: TComboBox;
    ActionList: TActionList;
    OKAction: TAction;
    procedure OKActionExecute(Sender: TObject);
    procedure OKActionUpdate(Sender: TObject);
  public
    function EditPack(const AAssetPack: TAssetPack): Boolean;
    procedure UpdatePack(const AAssetPack: TAssetPack);
  end;

var
  AssetPackDetailsView: TAssetPackDetailsView;

implementation

{$R *.dfm}

{ TAssetPackDetailsView }

function TAssetPackDetailsView.EditPack(const AAssetPack: TAssetPack): Boolean;
begin
  PackageEdit.Text := AAssetPack.Package;
  PackNameEdit.Text := AAssetPack.PackName;
  PackKindComboBox.ItemIndex := Ord(AAssetPack.PackKind) - 1;
  FolderComboBox.Text := AAssetPack.Folder;
  Result := ShowModal = mrOK;
end;

procedure TAssetPackDetailsView.UpdatePack(const AAssetPack: TAssetPack);
begin
  AAssetPack.Package := PackageEdit.Text;
  AAssetPack.PackName := PackNameEdit.Text;
  AAssetPack.PackKind := TAssetPackKind(PackKindComboBox.ItemIndex + 1);
  AAssetPack.Folder := FolderComboBox.Text;
end;

procedure TAssetPackDetailsView.OKActionExecute(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TAssetPackDetailsView.OKActionUpdate(Sender: TObject);
begin
  OKAction.Enabled := not string(PackageEdit.Text).Trim.IsEmpty and not string(PackNameEdit.Text).Trim.IsEmpty and
    not string(PackKindComboBox.Text).Trim.IsEmpty and (PackKindComboBox.ItemIndex > -1);
end;

end.

