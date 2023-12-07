unit Codex.IDEActions.Wizard;

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
  System.Classes, System.SysUtils,
  Winapi.Windows,
  ToolsAPI,
  Vcl.Menus,
  DelphiAST.Classes, DelphiAST.Consts,
  DW.OTA.Wizard, DW.OTA.Helpers, DW.Menus.Helpers, DW.Vcl.DialogService,
  DW.RunProcess.Win,
  Codex.Core, Codex.Consts, Codex.AST;

implementation

type
  TIDEActionsWizard = class(TWizard)
  private
    FProcess: TRunProcess;
    procedure EnvVarsActionExecuteHandler(Sender: TObject);
    procedure GotoImplementationUsesActionExecuteHandler(Sender: TObject);
    procedure GotoInterfaceUsesActionExecuteHandler(Sender: TObject);
    procedure GotoUses(const ASection: TSyntaxNodeType);
    procedure KillLSPActionExecuteHandler(Sender: TObject);
    procedure SDKManagerActionExecuteHandler(Sender: TObject);
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

{ TIDEActionsWizard }

constructor TIDEActionsWizard.Create;
begin
  inherited;
  FProcess := TRunProcess.Create;
  CodexResources.LinkAction('GotoInterfaceUsesAction', GotoInterfaceUsesActionExecuteHandler);
  CodexResources.LinkAction('GotoImplementationUsesAction', GotoImplementationUsesActionExecuteHandler);
  CodexResources.LinkAction('EnvVarsAction', EnvVarsActionExecuteHandler);
  CodexResources.LinkAction('SDKManagerAction', SDKManagerActionExecuteHandler);
  CodexResources.LinkAction('KillLSPAction', KillLSPActionExecuteHandler);
end;

destructor TIDEActionsWizard.Destroy;
begin
  FProcess.Free;
  inherited;
end;

procedure TIDEActionsWizard.EnvVarsActionExecuteHandler(Sender: TObject);
begin
  TOTAHelper.GetEnvironmentOptions.EditOptions(cIDEOptionsSectionEnvironment + '.Environment Variables');
end;

procedure TIDEActionsWizard.GotoImplementationUsesActionExecuteHandler(Sender: TObject);
begin
  GotoUses(TSyntaxNodeType.ntImplementation);
end;

procedure TIDEActionsWizard.GotoInterfaceUsesActionExecuteHandler(Sender: TObject);
begin
  GotoUses(TSyntaxNodeType.ntInterface);
end;

procedure TIDEActionsWizard.GotoUses(const ASection: TSyntaxNodeType);
var
  LNode, LChildNode: TSyntaxNode;
  LEditor: IOTASourceEditor;
  LEditView: IOTAEditView;
begin
  LEditor := TOTAHelper.GetActiveSourceEditor;
  if (LEditor <> nil) and LEditor.FileName.EndsWith('.pas', True) and TOTAHelper.FindTopEditView(LEditor, LEditView) then
  begin
    LNode := TCodexAST.RunSourceEditor(LEditor);
    try
      LChildNode := LNode.FindNode(ASection);
      if LChildNode <> nil then
      begin
        LChildNode := LChildNode.FindNode(TSyntaxNodeType.ntUses);
        if LChildNode <> nil then
        begin
          LEditView.Position.Move(LChildNode.Line, LChildNode.Col);
          LEditView.MoveViewToCursor;
          LEditView.Paint;
        end;
      end;
    finally
      LNode.Free;
    end;
  end;
end;

procedure TIDEActionsWizard.KillLSPActionExecuteHandler(Sender: TObject);
var
  LMenuItem: TMenuItem;
begin
  if not (TOTAHelper.FindToolsMenu(LMenuItem) and TOTAHelper.FindMenuByCaption(LMenuItem, '%LSP%', LMenuItem)) then
  begin
    FProcess.CommandLine := 'taskkill /f /IM delphilsp.exe';
    FProcess.RunAndWait(2000);
  end
  else
    LMenuItem.Click;
end;

procedure TIDEActionsWizard.SDKManagerActionExecuteHandler(Sender: TObject);
begin
  TOTAHelper.GetEnvironmentOptions.EditOptions(cIDEOptionsSectionDeployment + '.SDK Manager');
end;

initialization
  TOTAWizard.RegisterWizard(TIDEActionsWizard);

end.
