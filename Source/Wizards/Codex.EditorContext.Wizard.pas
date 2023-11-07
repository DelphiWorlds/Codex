unit Codex.EditorContext.Wizard;

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
  System.Classes, System.SysUtils, System.IOUtils,
  ToolsAPI,
  Vcl.Menus, Vcl.ActnPopup, Vcl.ActnList,
  DW.OTA.Wizard, DW.OTA.Helpers, DW.Menus.Helpers,
  Codex.Core;

type
  TEditorContextWizard = class(TWizard)
  private
    procedure CheckEditorActionList;
  protected
    procedure AddToProjectHandler(Sender: TObject);
    procedure AddToProjectUpdateHandler(Sender: TObject);
    procedure IDEStarted; override;
  public
    constructor Create; override;
  end;

{ TEditorContextWizard }

constructor TEditorContextWizard.Create;
begin
  inherited;
  CodexResources.LinkAction('AddToProjectAction', AddToProjectHandler, AddToProjectUpdateHandler);
end;

procedure TEditorContextWizard.AddToProjectHandler(Sender: TObject);
var
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetActiveProject;
  if LProject <> nil then
    LProject.AddFile(TOTAHelper.GetActiveSourceEditorFileName, True);
end;

procedure TEditorContextWizard.AddToProjectUpdateHandler(Sender: TObject);
begin
  TAction(Sender).Enabled := TPath.GetExtension(TOTAHelper.GetActiveSourceEditorFileName).ToLower.Equals('.pas') and
    (TOTAHelper.GetActiveProject <> nil); // TODO: And not already part of the project!
end;

procedure TEditorContextWizard.IDEStarted;
begin
  inherited;
  CheckEditorActionList;
end;

procedure TEditorContextWizard.CheckEditorActionList;
{$IF CompilerVersion > 35}
var
  LActionList: TActionList;
begin
  LActionList := CodexProvider.GetEditorActionList;
  if LActionList <> nil then
    (BorlandIDEServices as IOTAEditorServices).GetEditorLocalMenu.RegisterActionList(LActionList, 'Codex', cEdMenuCatBase);
end;
{$ELSE}
begin
  // Do nothing in earlier versions
end;
{$ENDIF}

initialization
  {$IF CompilerVersion >= 36}
  TOTAWizard.RegisterWizard(TEditorContextWizard);
  {$ENDIF}

end.
