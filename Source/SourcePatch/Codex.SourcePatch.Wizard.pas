unit Codex.SourcePatch.Wizard;

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
  System.SysUtils, System.IOUtils,
  ToolsAPI,
  Vcl.Menus, Vcl.Forms, Vcl.ActnList,
  DW.OTA.Wizard, DW.OTA.Helpers, DW.Menus.Helpers,
  Codex.Config, Codex.Consts, Codex.Core, Codex.ActionList.Helper, Codex.Consts.Text,
  Codex.SourcePatch.FunctionsModule, Codex.SourcePatch.ResourcesModule;

const
  cMenuItemName = 'CodexSourcePatchMenuItem';

type
  TSourcePatchWizard = class(TWizard)
  private
    FFunctionsModule: TSourcePatchFunctionsModule;
    FResourcesModule: TSourcePatchResourcesModule;
    procedure AddMenuItems;
    procedure CopySourceActionHandler(Sender: TObject);
    procedure CopySourceFromEditorHandler(Sender: TObject);
    procedure CopySourceFromEditorUpdateHandler(Sender: TObject);
    procedure CopySourceFromEditorToProjectHandler(Sender: TObject);
    procedure CopySourceFromEditorToProjectUpdateHandler(Sender: TObject);
    procedure CreatePatchActionHandler(Sender: TObject);
    procedure CreatePatchActionUpdateHandler(Sender: TObject);
    procedure CreatePatchFromEditorHandler(Sender: TObject);
    procedure CreatePatchFromEditorUpdateHandler(Sender: TObject);
    procedure PatchSourceFromEditorHandler(Sender: TObject);
    procedure PatchSourceFromEditorUpdateHandler(Sender: TObject);
    procedure PatchSourceActionHandler(Sender: TObject);
    procedure PatchSourceActionUpdateHandler(Sender: TObject);
    // procedure PatchSourceToProjectActionHandler(Sender: TObject);
    // procedure PatchSourceToProjectActionUpdateHandler(Sender: TObject);
  private
    procedure LinkActions;
  protected
    // Delphi 11.x support
    function HookedEditorMenuPopup(const AMenuItem: TMenuItem): Boolean; override;
    procedure IDEStarted; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

{ TSourcePatchWizard }

constructor TSourcePatchWizard.Create;
begin
  inherited;
  FFunctionsModule := TSourcePatchFunctionsModule.Create(Application);
  FResourcesModule := TSourcePatchResourcesModule.Create(Application);
  LinkActions;
  AddMenuItems;
end;

destructor TSourcePatchWizard.Destroy;
begin
  //
  inherited;
end;

procedure TSourcePatchWizard.IDEStarted;
begin
  inherited;
end;

procedure TSourcePatchWizard.LinkActions;
begin
  FResourcesModule.LinkAction('CopySourceFromEditorAction', CopySourceFromEditorHandler, CopySourceFromEditorUpdateHandler);
  FResourcesModule.LinkAction('CopySourceFromEditorToProjectAction', CopySourceFromEditorToProjectHandler, CopySourceFromEditorToProjectUpdateHandler);
  FResourcesModule.LinkAction('CreatePatchFromEditorAction', CreatePatchFromEditorHandler, CreatePatchFromEditorUpdateHandler);
  FResourcesModule.LinkAction('PatchSourceFromEditorAction', PatchSourceFromEditorHandler, PatchSourceFromEditorUpdateHandler);
  CodexProvider.GetEditorActionList.AssignActions(FResourcesModule.ActionList);
end;

procedure TSourcePatchWizard.CopySourceActionHandler(Sender: TObject);
begin
  FFunctionsModule.CopySourceFiles;
end;

procedure TSourcePatchWizard.CopySourceFromEditorHandler(Sender: TObject);
begin
  FFunctionsModule.CopySourceEditorFile(TOTAHelper.GetActiveSourceEditorFileName);
end;

procedure TSourcePatchWizard.CopySourceFromEditorToProjectHandler(Sender: TObject);
begin
  FFunctionsModule.CopySourceEditorFileToProject;
end;

procedure TSourcePatchWizard.CopySourceFromEditorToProjectUpdateHandler(Sender: TObject);
begin
  TAction(Sender).Enabled := FFunctionsModule.IsSourceFile(TOTAHelper.GetActiveSourceEditorFileName) and (TOTAHelper.GetActiveProject <> nil);
end;

procedure TSourcePatchWizard.CopySourceFromEditorUpdateHandler(Sender: TObject);
begin
  TAction(Sender).Enabled := FFunctionsModule.IsSourceFile(TOTAHelper.GetActiveSourceEditorFileName);
end;

procedure TSourcePatchWizard.CreatePatchActionHandler(Sender: TObject);
begin
  FFunctionsModule.DiffFile;
end;

procedure TSourcePatchWizard.CreatePatchActionUpdateHandler(Sender: TObject);
begin
  TAction(Sender).Enabled := TFile.Exists(FFunctionsModule.GetGitEXE);
end;

procedure TSourcePatchWizard.CreatePatchFromEditorHandler(Sender: TObject);
begin
  FFunctionsModule.DiffEditorFile(TOTAHelper.GetActiveSourceEditorFileName);
end;

procedure TSourcePatchWizard.CreatePatchFromEditorUpdateHandler(Sender: TObject);
begin
  TAction(Sender).Enabled := FFunctionsModule.CanCreatePatch(TOTAHelper.GetActiveSourceEditorFileName);
end;

procedure TSourcePatchWizard.PatchSourceActionHandler(Sender: TObject);
begin
  FFunctionsModule.PatchSourceFile;
end;

procedure TSourcePatchWizard.PatchSourceActionUpdateHandler(Sender: TObject);
begin
  TAction(Sender).Enabled := TFile.Exists(FFunctionsModule.GetPatchEXE);
end;

procedure TSourcePatchWizard.PatchSourceFromEditorHandler(Sender: TObject);
begin
  FFunctionsModule.PatchEditorFile(TOTAHelper.GetActiveSourceEditorFileName);
end;

procedure TSourcePatchWizard.PatchSourceFromEditorUpdateHandler(Sender: TObject);
begin
  TAction(Sender).Enabled := FFunctionsModule.CanApplyPatch(TOTAHelper.GetActiveSourceEditorFileName);
end;

{
procedure TSourcePatchWizard.PatchSourceToProjectActionHandler(Sender: TObject);
begin
  FModule.PatchSourceFile(True);
end;

procedure TSourcePatchWizard.PatchSourceToProjectActionUpdateHandler(Sender: TObject);
begin
  TAction(Sender).Enabled := TFile.Exists(FModule.GetPatchEXE) and (TOTAHelper.GetActiveProject <> nil);
end;
}

procedure TSourcePatchWizard.AddMenuItems;
var
  LCodexMenuItem, LPatchMenuItem, LMenuItem: TMenuItem;
begin
  if TOTAHelper.FindToolsSubMenu(cCodexMenuItemName, LCodexMenuItem) then
  begin
    LPatchMenuItem := TMenuItem.Create(LCodexMenuItem);
    LPatchMenuItem.Caption := Babel.Tx(sPatchMenuCaption);
    LCodexMenuItem.Insert(LCodexMenuItem.Count, LPatchMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(LPatchMenuItem, Babel.Tx(sCopySourcesMenuCaption), CopySourceActionHandler);
    LPatchMenuItem.Insert(LPatchMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(LPatchMenuItem, Babel.Tx(sCreatePatchMenuCaption), CreatePatchActionHandler);
    LMenuItem.Action.OnUpdate := CreatePatchActionUpdateHandler;
    LPatchMenuItem.Insert(LPatchMenuItem.Count, LMenuItem);
    LMenuItem := TMenuItem.CreateWithAction(LPatchMenuItem, Babel.Tx(sPatchSourceMenuCaption), PatchSourceActionHandler);
    LMenuItem.Action.OnUpdate := PatchSourceActionUpdateHandler;
    LPatchMenuItem.Insert(LPatchMenuItem.Count, LMenuItem);
  end;
end;

function TSourcePatchWizard.HookedEditorMenuPopup(const AMenuItem: TMenuItem): Boolean;
var
  LMenuItem: TMenuItem;
begin
  TMenuItem.CreateSeparator(AMenuItem);
  LMenuItem := TMenuItem.CreateWithAction(AMenuItem, Babel.Tx(sCopySourceMenuCaption), CopySourceFromEditorHandler);
  LMenuItem.Action.OnUpdate := CopySourceFromEditorUpdateHandler;
  AMenuItem.Insert(AMenuItem.Count, LMenuItem);
  LMenuItem := TMenuItem.CreateWithAction(AMenuItem, Babel.Tx(sCopySourceToProjectMenuCaption), CopySourceFromEditorToProjectHandler);
  LMenuItem.Action.OnUpdate := CopySourceFromEditorToProjectUpdateHandler;
  AMenuItem.Insert(AMenuItem.Count, LMenuItem);
  // Intended for source that was copied from BDS\source, and has been modified, so a patch can be created
  LMenuItem := TMenuItem.CreateWithAction(AMenuItem, Babel.Tx(sCreatePatchMenuCaption), CreatePatchFromEditorHandler);
  LMenuItem.Action.OnUpdate := CreatePatchFromEditorUpdateHandler;
  AMenuItem.Insert(AMenuItem.Count, LMenuItem);
  LMenuItem := TMenuItem.CreateWithAction(AMenuItem, Babel.Tx(sPatchSourceMenuCaption), PatchSourceFromEditorHandler);
  LMenuItem.Action.OnUpdate := PatchSourceFromEditorUpdateHandler;
  AMenuItem.Insert(AMenuItem.Count, LMenuItem);
  Result := True;
end;

initialization
  TOTAWizard.RegisterWizard(TSourcePatchWizard);

end.
