unit Codex.Cleaner.CleanView;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.CheckLst, System.Actions, Vcl.ActnList,
  DW.Vcl.Splitter.Themed,
  Codex.BaseView;

type
  TCleanView = class(TForm)
    CleanPathPanel: TPanel;
    AppImagesPathPanel: TPanel;
    SelectCleanPathSpeedButton: TSpeedButton;
    CleanPathEdit: TEdit;
    CleanPathIncludeSubdirsCheckBox: TCheckBox;
    FileOpenDialog: TFileOpenDialog;
    FileTypesCheckListBox: TCheckListBox;
    AppImagesButtonsPanel: TPanel;
    ActionList: TActionList;
    CleanAction: TAction;
    CleanButton: TButton;
    CancelButton: TButton;
    PathLabel: TLabel;
    FoldersCheckListBox: TCheckListBox;
    ListBoxesSplitter: TSplitter;
    FoldersPanel: TPanel;
    FileTypesCheckBox: TCheckBox;
    FoldersCheckBox: TCheckBox;
    procedure SelectCleanPathSpeedButtonClick(Sender: TObject);
    procedure CleanActionUpdate(Sender: TObject);
    procedure CleanActionExecute(Sender: TObject);
    procedure FileTypesCheckBoxClick(Sender: TObject);
    procedure FoldersCheckBoxClick(Sender: TObject);
  private
    function GetCleanExtensions: TArray<string>;
    function GetCleanFolders: TArray<string>;
  public
    constructor Create(AOwner: TComponent); override;
    property CleanExtensions: TArray<string> read GetCleanExtensions;
    property CleanFolders: TArray<string> read GetCleanFolders;
  end;

var
  CleanView: TCleanView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  DW.IOUtils.Helpers, DW.OTA.Helpers,
  DW.Vcl.ListBoxHelper,
  Codex.Core;

resourcestring
  sConfirmClean = 'Confirm that you wish to delete files with the selected extensions, and the selected folders';

const
  cCheckedState: array[Boolean] of TCheckBoxState = (TCheckBoxState.cbUnchecked, TCheckBoxState.cbChecked);

{ TfrmClean }

constructor TCleanView.Create(AOwner: TComponent);
begin
  inherited;
  TOTAHelper.ApplyTheme(Self);
end;

procedure TCleanView.FileTypesCheckBoxClick(Sender: TObject);
begin
  FileTypesCheckListBox.CheckAll(cCheckedState[FileTypesCheckBox.Checked]);
end;

procedure TCleanView.FoldersCheckBoxClick(Sender: TObject);
begin
  FoldersCheckListBox.CheckAll(cCheckedState[FoldersCheckBox.Checked]);
end;

procedure TCleanView.CleanActionExecute(Sender: TObject);
begin
  if MessageDlg(Babel.Tx(sConfirmClean), TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], 0) = mrYes then
    ModalResult := mrOk;
end;

procedure TCleanView.CleanActionUpdate(Sender: TObject);
begin
  CleanAction.Enabled := TDirectoryHelper.Exists(CleanPathEdit.Text) and
    ((FileTypesCheckListBox.CheckedCount > 0) or (FoldersCheckListBox.CheckedCount > 0));
end;

function TCleanView.GetCleanExtensions: TArray<string>;
var
  I: Integer;
begin
  for I := 0 to FileTypesCheckListBox.Count - 1 do
  begin
    if FileTypesCheckListBox.Checked[I] then
      Result := Result + [FileTypesCheckListBox.Items[I]];
  end;
end;

function TCleanView.GetCleanFolders: TArray<string>;
var
  I: Integer;
begin
  for I := 0 to FoldersCheckListBox.Count - 1 do
  begin
    if FoldersCheckListBox.Checked[I] then
      Result := Result + [FoldersCheckListBox.Items[I]];
  end;
end;

procedure TCleanView.SelectCleanPathSpeedButtonClick(Sender: TObject);
begin
  if FileOpenDialog.Execute then
    CleanPathEdit.Text := FileOpenDialog.FileName;
end;

end.
