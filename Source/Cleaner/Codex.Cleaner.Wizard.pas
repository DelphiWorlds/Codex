unit Codex.Cleaner.Wizard;

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

implementation

uses
  System.UITypes, System.Classes, System.IOUtils, System.Types,
  Vcl.Menus, Vcl.ActnList, Vcl.Forms,
  DW.OTA.Wizard, DW.OTA.Helpers, DW.Classes.Helpers, DW.IOUtils.Helpers, DW.Menus.Helpers, DW.Types.Helpers,
  Codex.ProgressView,
  Codex.Consts, Codex.Cleaner.CleanView, Codex.Core, Codex.Consts.Text;

const
  cCleanerMenuItemName = 'CodexCleanerMenuItem';

type
  TCleanerWizard = class(TWizard)
  private
    FCleanExtensions: TArray<string>;
    FCleanFolders: TArray<string>;
    FCleanPath: string;
    FIncludeSubfolders: Boolean;
    procedure AddMenuItem;
    procedure Clean;
    procedure CleanerActionHandler(Sender: TObject);
    procedure DeleteFile(const AFileName: string);
    procedure DoProgress(const APercent: Integer; const AMessage: string = '');
  public
    constructor Create; override;
  end;

{ TCleanerWizard }

constructor TCleanerWizard.Create;
begin
  inherited;
  AddMenuItem;
end;

procedure TCleanerWizard.AddMenuItem;
var
  LCodexMenuItem, LMenuItem: TMenuItem;
begin
  if TOTAHelper.FindToolsSubMenu(cCodexMenuItemName, LCodexMenuItem) then
  begin
    LMenuItem := TMenuItem.CreateWithAction(LCodexMenuItem, Babel.Tx(sCleanerCaption), CleanerActionHandler);
    LCodexMenuItem.Insert(LCodexMenuItem.Count, LMenuItem);
  end;
end;

procedure TCleanerWizard.Clean;
const
  cSearchOptions: array[Boolean] of TSearchOption = (TSearchOption.soTopDirectoryOnly, TSearchOption.soAllDirectories);
var
  LItems, LPatterns: TArray<string>;
  I: Integer;
begin
  if FCleanFolders.Count > 0 then
  begin
    DoProgress(0, Babel.Tx(sScanningFolders));
    LItems := TDirectoryHelper.GetDirectories(FCleanPath, FCleanFolders, TSearchOption.soAllDirectories);
    for I := 0 to LItems.Count - 1 do
    begin
      TDirectoryHelper.Delete(LItems[I]);
      DoProgress(Round(100 * (I / (LItems.Count - 1))), LItems[I]);
    end;
  end;
  if FCleanExtensions.Count > 0 then
  begin
    SetLength(LPatterns, Length(FCleanExtensions));
    for I := 0 to Length(FCleanExtensions) - 1 do
      LPatterns[I] := '*.' + FCleanExtensions[I];
    DoProgress(0, Babel.Tx(sScanningFiles));
    LItems := TDirectoryHelper.GetFiles(FCleanPath, LPatterns, cSearchOptions[FIncludeSubfolders]);
    for I := 0 to LItems.Count - 1 do
    begin
      DeleteFile(LItems[I]);
      DoProgress(Round(100 * (I / (LItems.Count - 1))), LItems[I]);
    end;
  end;
  DoProgress(-1);
end;

procedure TCleanerWizard.DeleteFile(const AFileName: string);
begin
  try
    TFile.Delete(AFileName);
  except
    // Just ignore
  end
end;

procedure TCleanerWizard.DoProgress(const APercent: Integer; const AMessage: string = '');
begin
  TDo.SyncMain(
    procedure
    begin
      ProgressView.ShowProgress(Babel.Tx(sCleaning), AMessage, APercent);
    end
  );
end;

procedure TCleanerWizard.CleanerActionHandler(Sender: TObject);
var
  LForm: TCleanView;
begin
  LForm := TCleanView.Create(nil);
  try
    if LForm.ShowModal = mrOK then
    begin
      FCleanPath := LForm.CleanPathEdit.Text;
      FIncludeSubfolders := LForm.CleanPathIncludeSubdirsCheckBox.Checked;
      FCleanExtensions := LForm.CleanExtensions;
      FCleanFolders := LForm.CleanFolders;
      TDo.RunQueue(Clean);
    end;
  finally
    LForm.Free;
  end;
end;

initialization
  TOTAWizard.RegisterWizard(TCleanerWizard);

end.
