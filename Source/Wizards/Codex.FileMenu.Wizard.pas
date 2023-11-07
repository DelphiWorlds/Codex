unit Codex.FileMenu.Wizard;

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
  System.SysUtils, System.Generics.Collections, System.Generics.Defaults, System.IOUtils, System.StrUtils, System.DateUtils,
  Winapi.ShellAPI, Winapi.Windows,
  ToolsAPI,
  Vcl.Menus, Vcl.ActnList,
  DW.OTA.Helpers, DW.OTA.Wizard, DW.Menus.Helpers, DW.OTA.Notifiers,
  Codex.Config, Codex.Consts, Codex.Types, Codex.Core, Codex.Interfaces, Codex.ProjectFiles, Codex.ProjectFilesView;

type
  TFileMenuWizard = class(TWizard, IModuleListener)
  private
    FIsGroupOpen: Boolean;
    FProjectFiles: TProjectFiles;
    FProjectFilesItem: TMenuItem;
    FReopenFilesItem: TMenuItem;
    procedure AddProjectFilesMenu;
    procedure AddReopenMenu;
    procedure CheckClosedFile(const AFileName: string);
    procedure CheckOpenedFile(const AFileName: string);
    procedure ManageProjectFilesItemHandler(Sender: TObject);
    procedure OpenProjectFileItemHandler(Sender: TObject);
    procedure ReopenFileItemHandler(Sender: TObject);
    procedure UpdateProjectFilesMenu;
    procedure UpdateReopenMenu;
  protected
    procedure FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string); override;
    procedure ProjectChanged; override;
  public
    { IModuleListener }
    procedure ProjectSaved(const AFileName: string);
    procedure SourceSaved(const AFileName: string);
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

resourcestring
  sCodexProjectItemCaption = 'Codex..';
  sCodexReopenFilesItemCaption = 'Reopen File';
  sCodexProjectFilesItemCaption = 'Project Files';

{ TFileMenuWizard }

constructor TFileMenuWizard.Create;
begin
  inherited;
  ModuleNotifier.AddListener(Self);
  TOTAHelper.RegisterThemeForms([TProjectFilesView]);
  AddReopenMenu;
  AddProjectFilesMenu;
end;

destructor TFileMenuWizard.Destroy;
begin
  //
  inherited;
end;

procedure TFileMenuWizard.AddProjectFilesMenu;
var
  LFileItem, LClosedFilesItem: TMenuItem;
begin
  if TOTAHelper.FindTopMenu('FileMenu', LFileItem) and
    (TOTAHelper.FindMenu(LFileItem, 'FileClosedFilesItem', LClosedFilesItem) or TOTAHelper.FindMenu(LFileItem, 'FileOpenRecentItem', LClosedFilesItem)) then
  begin
    FProjectFilesItem := TMenuItem.Create(nil);
    FProjectFilesItem.Name := cCodexProjectFilesItemName;
    FProjectFilesItem.Caption := Babel.Tx(sCodexProjectFilesItemCaption);
    LFileItem.Insert(LClosedFilesItem.MenuIndex, FProjectFilesItem);
  end;
end;

procedure TFileMenuWizard.AddReopenMenu;
var
  LFileItem, LClosedFilesItem: TMenuItem;
begin
  if TOTAHelper.FindTopMenu('FileMenu', LFileItem) and
    (TOTAHelper.FindMenu(LFileItem, 'FileClosedFilesItem', LClosedFilesItem) or TOTAHelper.FindMenu(LFileItem, 'FileOpenRecentItem', LClosedFilesItem)) then
  begin
    FReopenFilesItem := TMenuItem.Create(nil);
    FReopenFilesItem.Name := cCodexReopenFilesItemName;
    FReopenFilesItem.Caption := Babel.Tx(sCodexReopenFilesItemCaption);
    LFileItem.Insert(LClosedFilesItem.MenuIndex, FReopenFilesItem);
    UpdateReopenMenu;
  end;
end;

procedure TFileMenuWizard.FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
begin
  inherited;
  case ANotifyCode of
    TOTAFileNotification.ofnFileOpened:
      CheckOpenedFile(AFileName);
    TOTAFileNotification.ofnFileClosing:
      CheckClosedFile(AFileName);
    TOTAFileNotification.ofnBeginProjectGroupOpen:
      FIsGroupOpen := True;
    TOTAFileNotification.ofnEndProjectGroupOpen:
      FIsGroupOpen := False;
    TOTAFileNotification.ofnActiveProjectChanged, TOTAFileNotification.ofnEndProjectGroupClose:
      UpdateProjectFilesMenu;
  end;
end;

procedure TFileMenuWizard.CheckClosedFile(const AFileName: string);
var
  LFileName: string;
begin
  LFileName := AFileName.ToLower;
  if not (LFileName.EndsWith('.dproj') or LFileName.EndsWith('.groupproj') or LFileName.Equals('default.htm')) then
  begin
    Config.AddOpenedFile(AFileName);
    if not TOTAHelper.IsIDEClosing then
      UpdateReopenMenu;
  end;
end;

procedure TFileMenuWizard.ProjectSaved(const AFileName: string);
begin
  //
end;

procedure TFileMenuWizard.CheckOpenedFile(const AFileName: string);
begin
  //
end;

procedure TFileMenuWizard.UpdateProjectFilesMenu;
var
  I: Integer;
  LMenuItem: TMenuItem;
  LProjectFilesFileName, LFileName: string;
begin
  if FProjectFilesItem <> nil then
  begin
    for I := FProjectFilesItem.Count - 1 downto 0 do
    begin
      LMenuItem := FProjectFilesItem[I];
      FProjectFilesItem.Delete(I);
      LMenuItem.Free;
    end;
    FProjectFilesItem.Enabled := TOTAHelper.GetActiveProject <> nil;
    if FProjectFilesItem.Enabled then
    begin
      LMenuItem := TMenuItem.CreateWithAction(FProjectFilesItem, 'Manage..', ManageProjectFilesItemHandler); // TODO: Localize
      FProjectFilesItem.Add(LMenuItem);
      LProjectFilesFileName := TPath.Combine(TOTAHelper.GetActiveProjectPath, 'projectfiles.json');
      if TFile.Exists(LProjectFilesFileName) then
      begin
        FProjectFiles := TProjectFiles.Create(LProjectFilesFileName);
        if Length(FProjectFiles.ProjectFileNames) > 0 then
          TMenuItem.CreateSeparator(FProjectFilesItem);
        for I := 0 to High(FProjectFiles.ProjectFileNames) do
        begin
          LFileName := FProjectFiles.ProjectFileNames[I];
          LMenuItem := TMenuItem.CreateWithAction(FProjectFilesItem, (I + 1).ToString + ' ' + LFileName, OpenProjectFileItemHandler);
          LMenuItem.Action.Tag := I + 1;
          FProjectFilesItem.Add(LMenuItem);
        end;
      end;
      // TAction(LMenuItem.Action).Enabled := TOTAHelper.GetActiveProject <> nil;
    end;
  end;
end;

procedure TFileMenuWizard.ManageProjectFilesItemHandler(Sender: TObject);
var
  LForm: TProjectFilesView;
begin
  LForm := TProjectFilesView.Create(nil);
  try
    LForm.ProjectFilesFileName := TPath.Combine(TOTAHelper.GetActiveProjectPath, 'projectfiles.json');
    LForm.ProjectName := TPath.GetFileName(TOTAHelper.GetActiveProjectFileName);
    LForm.ShowModal;
    UpdateProjectFilesMenu;
  finally
    LForm.Free;
  end;
end;

procedure TFileMenuWizard.UpdateReopenMenu;
var
  I: Integer;
  LMenuItem: TMenuItem;
  LFileName: string;
begin
  if FReopenFilesItem <> nil then
  begin
    for I := FReopenFilesItem.Count - 1 downto 0 do
    begin
      LMenuItem := FReopenFilesItem[I];
      FReopenFilesItem.Delete(I);
      LMenuItem.Free;
    end;
    for I := 0 to Length(Config.OpenedFilesMRU) - 1 do
    begin
      LFileName := Config.OpenedFilesMRU[I];
      LMenuItem := TMenuItem.CreateWithAction(FReopenFilesItem, (I + 1).ToString + ' ' + LFileName, ReopenFileItemHandler);
      FReopenFilesItem.Add(LMenuItem);
    end;
    FReopenFilesItem.Enabled := FReopenFilesItem.Count > 0;
  end;
end;

procedure TFileMenuWizard.ReopenFileItemHandler(Sender: TObject);
var
  LFileName: string;
begin
  LFileName := TAction(Sender).Caption;
  LFileName := LFileName.Substring(Pos(' ', LFileName));
  TOTAHelper.OpenFile(LFileName);
end;

procedure TFileMenuWizard.SourceSaved(const AFileName: string);
begin
  //
end;

procedure TFileMenuWizard.OpenProjectFileItemHandler(Sender: TObject);
var
  LIndex: Integer;
  LFileName, LExt: string;
  LSEI: TShellExecuteInfo;
begin
  LIndex := TAction(Sender).Tag - 1;
  if (LIndex >= 0) and (LIndex < Length(FProjectFiles.ProjectFileNames)) then
  begin
    LFileName := FProjectFiles.ProjectFileNames[LIndex];
    LExt := LFileName.Substring(LFileName.LastIndexOf('.'));
    // If the file does not have an extension known by RAD Studio..
    if IndexText(LExt, cKnownEditorFileExts) = -1 then
    begin
      // This shows the "Select an app to open.." dialog, with the default app at the top, if one exists
      FillChar(LSEI, SizeOf(LSEI), 0);
      LSEI.cbSize := SizeOf(LSEI);
      LSEI.lpFile := PChar(LFileName);
      LSEI.lpVerb := 'openas';
      LSEI.nShow := SW_SHOW;
      LSEI.fMask := SEE_MASK_INVOKEIDLIST;
      ShellExecuteEx(@LSEI);
    end
    else
      TOTAHelper.OpenFile(LFileName);
  end;
end;

procedure TFileMenuWizard.ProjectChanged;
begin
  UpdateProjectFilesMenu;
end;

initialization
  TOTAWizard.RegisterWizard(TFileMenuWizard);

end.
