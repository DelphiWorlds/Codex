unit Codex.Wizard;

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
  System.TypInfo, System.IOUtils, System.SysUtils, System.Classes,
  ToolsAPI,
  Vcl.Forms, Vcl.Menus, Vcl.ActnList,
  DW.OSLog,
  DW.OTA.Wizard, DW.OTA.IDENotifierOTAWizard, DW.OTA.Notifiers, DW.OTA.Helpers, DW.Menus.Helpers, DW.OTA.WPPlugin, DW.OTA.Types, DW.OTA.Consts,
  Codex.Config.PreVersion2,
  Codex.AboutView, Codex.OptionsView, Codex.ProgressView, Codex.OutputView, Codex.Types,
  Codex.Config, Codex.ErrorInsight, Codex.Consts, Codex.Options, Codex.ResourcesModule, Codex.ModuleNotifier,
  Codex.Interfaces, Codex.Core, Codex.OTA.Helpers;

type
  TCodexWizard = class(TIDENotifierOTAWizard, IConfigOptionsHost, ICodexProvider, IModuleListener)
  private
    FCodexMenuItem: TMenuItem;
    FModuleNotifier: TCodexModuleNotifier;
    FOptionsView: TOptionsView;
    FThemeNotifier: ITOTALNotifier;
    FStructureViewNotifier: ITOTALNotifier;
    // Menu item handlers
    procedure AboutMenuItemHandler(Sender: TObject);
    procedure OptionsMenuItemHandler(Sender: TObject);
    // Wizard methods
    procedure AddCodexMenuItem;
    procedure AddCodexMenuSubItems;
    procedure CheckProject(const AFileName: string; const AWasOpened: Boolean);
    procedure ShowProjectManager;
  protected
    class function GetWizardName: string; override;
  protected
    procedure ChangedTheme;
    procedure IDENotifierFileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string); override;
  public
    // IOTAWizard
    function GetIDString: string; override;
    function GetName: string; override;
    // TOTAWizard
    function GetWizardDescription: string; override;
    procedure IDEStarted; override;
    procedure WizardsCreated; override;
    { IConfigOptionsHost }
    procedure ShowOptions(const ASectionID: string);
    { ICodexProvider }
    function GetEditorActionList: TActionList;
    procedure NotifyContextMenu(const AMenuItem: TMenuItem);
    { IModuleListener }
    procedure ProjectSaved(const AFileName: string);
    procedure SourceSaved(const AFileName: string);
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

resourcestring
  sAbout = 'About';
  sCodexMenuItemCaption = 'Codex';
  sOptions = 'Options';

type
  TCodexThemingServicesNotifier = class(TThemingServicesNotifier)
  private
    FWizard: TCodexWizard;
  public
    constructor Create(const AWizard: TCodexWizard);
    procedure ChangedTheme; override;
  end;

{ TCodexThemingServicesNotifier }

constructor TCodexThemingServicesNotifier.Create(const AWizard: TCodexWizard);
begin
  inherited Create;
  FWizard := AWizard;
end;

procedure TCodexThemingServicesNotifier.ChangedTheme;
begin
  FWizard.ChangedTheme;
end;

{ TCodexWizard }

constructor TCodexWizard.Create;
begin
  inherited;
  CodexProvider := Self;
  FThemeNotifier := TCodexThemingServicesNotifier.Create(Self);
  FModuleNotifier := TCodexModuleNotifier.Create;
  ModuleNotifier.AddListener(Self);
  TConfigOptionsHelper.RegisterHost(Self);
  TCodexResourcesModule.Create(Application);
  ProgressView := TProgressView.Create(Application);
  (BorlandIDEServices as INTAServices).NewToolbar(cCodexToolbarName, cCodexToolbarCaption);
  AddCodexMenuItem;
end;

destructor TCodexWizard.Destroy;
begin
  TWPPluginRegistry.RemovePlugins;
  FStructureViewNotifier.RemoveNotifier;
  FThemeNotifier.RemoveNotifier;
  FModuleNotifier.Free;
  inherited;
end;

function TCodexWizard.GetEditorActionList: TActionList;
begin
  Result := CodexResources.GetActionList('EditorActionList');
end;

function TCodexWizard.GetIDString: string;
begin
  Result := 'com.delphiworlds.codex';
end;

function TCodexWizard.GetName: string;
begin
  Result := GetWizardName;
end;

function TCodexWizard.GetWizardDescription: string;
begin
  Result := 'Codex is a free tool that adds various features to the IDE'#13#10 +
    '(c) 2023 Dave Nottage of Delphi Worlds'#13#10'http://www.delphiworlds.com';
end;

class function TCodexWizard.GetWizardName: string;
begin
  Result := 'Codex';
end;

procedure TCodexWizard.WizardsCreated;
begin
  FCodexMenuItem.Sort;
  AddCodexMenuSubItems;
  CodexResources.AddToolbarActions;
end;

procedure TCodexWizard.AddCodexMenuItem;
var
  LToolsMenuItem: TMenuItem;
begin
  if TOTAHelper.FindToolsMenu(LToolsMenuItem) then
  begin
    FCodexMenuItem := TMenuItem.Create(nil);
    FCodexMenuItem.Name := cCodexMenuItemName;
    FCodexMenuItem.Caption := sCodexMenuItemCaption;
    LToolsMenuItem.Insert(0, FCodexMenuItem);
  end;
end;

procedure TCodexWizard.AddCodexMenuSubItems;
var
  LMenuItem: TMenuItem;
begin
  TMenuItem.CreateSeparator(FCodexMenuItem);
  LMenuItem := TMenuItem.CreateWithAction(FCodexMenuItem, Babel.Tx(sOptions), OptionsMenuItemHandler);
  FCodexMenuItem.Insert(FCodexMenuItem.Count, LMenuItem);
  LMenuItem := TMenuItem.CreateWithAction(FCodexMenuItem, Babel.Tx(sAbout), AboutMenuItemHandler);
  FCodexMenuItem.Insert(FCodexMenuItem.Count, LMenuItem);
end;

procedure TCodexWizard.ChangedTheme;
var
  I: Integer;
  LView: ICodexView;
begin
  for I := 0 to Screen.FormCount - 1 do
  begin
    if Supports(Screen.Forms[I], ICodexView, LView) then
      TOTAHelper.ApplyTheme(Screen.Forms[I]);
  end;
end;

procedure TCodexWizard.CheckProject(const AFileName: string; const AWasOpened: Boolean);
var
  LExt: string;
begin
  LExt := TPath.GetExtension(AFilename).ToLower;
  if LExt.EndsWith('dproj') or LExt.EndsWith('groupproj') then
  begin
    if AWasOpened and Config.IDE.ShowProjectManagerOnProjectOpen then
      ShowProjectManager;
    Config.IDE.ProjectLastOpenedFileName := AFileName;
    Config.Save;
  end;
end;

procedure TCodexWizard.ProjectSaved(const AFileName: string);
begin
  TOSLog.d('TCodexWizard.ProjectSaved: %s', [AFileName]);
  CheckProject(AFileName, False);
end;

procedure TCodexWizard.ShowProjectManager;
var
  LViewPrjMgr: TComponent;
begin
  if TOTAHelper.FindComponentGlobal(cComponentViewProjectManagerCommand, LViewPrjMgr) and (LViewPrjMgr is TBasicAction) then
    TBasicAction(LViewPrjMgr).Execute;
end;

procedure TCodexWizard.SourceSaved(const AFileName: string);
begin
  //
end;

procedure TCodexWizard.IDENotifierFileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
begin
  inherited;
  if Config.Diagnostics.LogFileOps then
    TOSLog.d('%s: %s', [GetEnumName(TypeInfo(TOTAFileNotification), Ord(ANotifyCode)), AFileName]);
  case ANotifyCode of
    TOTAFileNotification.ofnFileOpened:
    begin
      FModuleNotifier.FileOpened(AFileName);
      if TFile.Exists(AFileName) then
        CheckProject(AFileName, True);
    end;
    TOTAFileNotification.ofnFileClosing:
      FModuleNotifier.FileClosing(AFileName);
    TOTAFileNotification.ofnActiveProjectChanged, TOTAFileNotification.ofnEndProjectGroupClose:
    begin
      if TCodexOTAHelper.CheckProjectChanged then
        ProjectChanged;
    end;
  end;
end;

procedure TCodexWizard.IDEStarted;
begin
  inherited;
  TWPPluginRegistry.CreatePlugins;
  FStructureViewNotifier := TCodexStructureViewNotifier.Create;
  if Config.IDE.LoadProjectLastOpened and TFile.Exists(Config.IDE.ProjectLastOpenedFileName) then
    TOTAHelper.OpenFile(Config.IDE.ProjectLastOpenedFileName);
  ConfigChanged;
end;

procedure TCodexWizard.NotifyContextMenu(const AMenuItem: TMenuItem);
begin
  HookedEditorMenuPopup(AMenuItem);
end;

procedure TCodexWizard.AboutMenuItemHandler(Sender: TObject);
var
  LAbout: TForm;
begin
  LAbout := TAboutView.Create(nil);
  try
    LAbout.ShowModal;
  finally
    LAbout.Free;
  end;
end;

procedure TCodexWizard.OptionsMenuItemHandler(Sender: TObject);
begin
  ShowOptions('');
end;

procedure TCodexWizard.ShowOptions(const ASectionID: string);
begin
  if FOptionsView = nil then
    FOptionsView := TOptionsView.Create(Application);
  if FOptionsView.ShowOptions(ASectionID) then
  begin
    Config.Save;
    ConfigChanged;
  end;
end;

function Initialize(const Services: IBorlandIDEServices; RegisterProc: TWizardRegisterProc;
  var TerminateProc: TWizardTerminateProc): Boolean; stdcall;
begin
  Result := TOTAWizard.InitializeWizard(Services, RegisterProc, TerminateProc, TCodexWizard);
end;

exports
  Initialize name WizardEntryPoint;

initialization
  TCodexConfigPreVersion2.Migrate;
  Config.Load;
  TOSLog.Tag := TCodexWizard.GetWizardName;
  TCodexWizard.RegisterSplash;

end.
