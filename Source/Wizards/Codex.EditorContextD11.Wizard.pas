unit Codex.EditorContextD11.Wizard;

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
  Codex.Core, Codex.Consts.Text;

type
  TEditorContextWizard = class(TWizard)
  private
    FEditorMenuItem: TMenuItem;
    FEditorPopupEvent: TMethod;
    procedure AddToProjectHandler(Sender: TObject);
    procedure AddToProjectUpdateHandler(Sender: TObject);
    procedure EditorMenuPopupHandler(Sender: TObject);
    procedure HookEditorPopup;
    function FindEditorPopup(out APopup: TPopupActionBar): Boolean;
  protected
    procedure IDEStarted; override;
  end;

{ TEditorContextWizard }

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
  HookEditorPopup;
end;

function TEditorContextWizard.FindEditorPopup(out APopup: TPopupActionBar): Boolean;
var
  LComponent: TComponent;
begin
  Result := False;
  if TOTAHelper.FindComponentGlobal('EditorLocalMenu', LComponent) and (LComponent is TPopupActionBar) then
  begin
    APopup := TPopupActionBar(LComponent);
    Result := True;
  end;
end;

procedure TEditorContextWizard.HookEditorPopup;
var
  LPopup: TPopupActionBar;
begin
  if FindEditorPopup(LPopup) then
  begin
    if Assigned(LPopup.OnPopup) then
    begin
      FEditorPopupEvent := TMethod(LPopup.OnPopup);
      LPopup.OnPopup := EditorMenuPopupHandler;
    end
    else
      LPopup.OnPopup := EditorMenuPopupHandler;
  end;
end;

procedure TEditorContextWizard.EditorMenuPopupHandler(Sender: TObject);
var
  LPopup: TPopupActionBar;
  LIndex: Integer;
  LEvent: TNotifyEvent;
  LMenuItem: TMenuItem;
begin
  FEditorMenuItem.Free;
  FEditorMenuItem := nil;
  if Assigned(FEditorPopupEvent.Data) then
  begin
    LEvent := TNotifyEvent(FEditorPopupEvent);
    LEvent(Sender);
  end;
  if FindEditorPopup(LPopup) then
  begin
    LIndex := TOTAHelper.FindMenuSeparatorIndex(LPopup.Items, 'EditAddToDoItemCommand');
    if LIndex > -1 then
    begin
      TMenuItem.CreateSeparator(LPopup.Items, LIndex);
      FEditorMenuItem := TMenuItem.Create(LPopup); // .Items
      FEditorMenuItem.Caption := 'Codex';
      LPopup.Items.Insert(LIndex + 1, FEditorMenuItem);
      // Now add the submenu items, using FCodexEditorMenuItem as owner and FCodexEditorMenuItem.Add
      LMenuItem := TMenuItem.CreateWithAction(FEditorMenuItem, Babel.Tx(sAddToProjectMenuCaption), AddToProjectHandler);
      LMenuItem.Action.OnUpdate := AddToProjectUpdateHandler;
      FEditorMenuItem.Insert(FEditorMenuItem.Count, LMenuItem);
      TMenuItem.CreateSeparator(FEditorMenuItem);
      CodexProvider.NotifyContextMenu(FEditorMenuItem);
    end;
  end;
end;

initialization
  {$IF CompilerVersion < 36}
  TOTAWizard.RegisterWizard(TEditorContextWizard);
  {$ENDIF}

end.
