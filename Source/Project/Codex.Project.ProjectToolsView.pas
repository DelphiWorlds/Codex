unit Codex.Project.ProjectToolsView;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Actions, System.ImageList,
  {$IF Defined(EXPERT)}
  DockForm,
  {$ENDIF}
  Vcl.Controls, Vcl.Graphics, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ToolWin, Vcl.BaseImageCollection, Vcl.ImageCollection,
  Vcl.ImgList, Vcl.VirtualImageList, Vcl.ActnList,
  Codex.Interfaces;

type
  TProjectToolsView = class({$IF Defined(EXPERT)}TDockableForm{$ELSE}TForm{$ENDIF}, ICodexView)
    ToolBar: TToolBar;
    CompileToolButton: TToolButton;
    BuildToolButton: TToolButton;
    CleanToolButton: TToolButton;
    TotalCleanToolButton: TToolButton;
    OptionsSepToolButton: TToolButton;
    ProjectOptionsToolButton: TToolButton;
    PlatformSepToolButton: TToolButton;
    Win32ToolButton: TToolButton;
    Android32ToolButton: TToolButton;
    MacOSToolButton: TToolButton;
    iOSToolButton: TToolButton;
    SourceSepToolButton: TToolButton;
    ViewSourceToolButton: TToolButton;
    ShowDeployToolButton: TToolButton;
    InsertPathsToolButton: TToolButton;
    ProjectActionList: TActionList;
    CompileAction: TAction;
    BuildAction: TAction;
    CleanAction: TAction;
    TotalCleanAction: TAction;
    ShowOptionsAction: TAction;
    Win32Action: TAction;
    Android32Action: TAction;
    MacOSAction: TAction;
    iOSAction: TAction;
    ViewSourceAction: TAction;
    ShowDeployAction: TAction;
    InsertPathsAction: TAction;
    DeployToolButton: TToolButton;
    DeployAction: TAction;
    procedure CommonProjectActionExecute(Sender: TObject);
    procedure CommonProjectActionUpdate(Sender: TObject);
    procedure DeployActionUpdate(Sender: TObject);
  private
    class var Instance: TProjectToolsView;
  private
    FDesignHeight: Integer;
    function CanDeploy: Boolean;
    function HasActiveProject: Boolean;
  protected
    procedure DoDock(NewDockSite: TWinControl; var ARect: TRect); override;
    procedure DoShow; override;
  {$IF Defined(EXPERT)}
  public
    class function CreateView: TProjectToolsView;
    class procedure RemoveView;
    class procedure ShowView;
  {$ENDIF}
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses
{$IF Defined(EXPERT)}
  DW.OSLog,
  DW.OTA.Wizard, DW.OTA.Helpers,
{$ENDIF}
  Codex.Config, Codex.Core;

{ TProjectToolsView }

constructor TProjectToolsView.Create(AOwner: TComponent);
begin
  inherited;
  Toolbar.Images := ProjectResources.GetImageList;
  FDesignHeight := Constraints.MinHeight;
  {$IF Defined(EXPERT)}
  DeskSection := 'CodexProjectTools';
  AutoSave := True;
  SaveStateNecessary := True;
  TOTAHelper.ApplyTheme(Self);
  {$ENDIF}
end;

destructor TProjectToolsView.Destroy;
begin
  {$IF Defined(EXPERT)}
  SaveStateNecessary := True;
  {$ENDIF}
  Instance := nil;
  inherited;
end;

{$IF Defined(EXPERT)}
class function TProjectToolsView.CreateView: TProjectToolsView;
begin
  if Instance = nil then
    TOTAWizard.CreateDockableForm(Instance, TProjectToolsView);
  Result := Instance;
end;

class procedure TProjectToolsView.RemoveView;
begin
  TOTAWizard.FreeDockableForm(Instance);
end;

class procedure TProjectToolsView.ShowView;
begin
  CreateView.Show;
end;
{$ENDIF}

procedure TProjectToolsView.DoDock(NewDockSite: TWinControl; var ARect: TRect);
var
  LHeight: Integer;
begin
  inherited;
  if NewDockSite = nil then
    LHeight := FDesignHeight
  else
    LHeight := ToolBar.Height;
  Constraints.MinHeight := LHeight;
  Constraints.MaxHeight := LHeight;
end;

procedure TProjectToolsView.DoShow;
begin
  inherited;
  ClientHeight := Toolbar.Height;
end;

procedure TProjectToolsView.CommonProjectActionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := HasActiveProject;
end;

procedure TProjectToolsView.DeployActionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := CanDeploy;
end;

procedure TProjectToolsView.CommonProjectActionExecute(Sender: TObject);
begin
  ProjectResources.PerformAction(TAction(Sender));
end;

function TProjectToolsView.HasActiveProject: Boolean;
begin
  Result := TOTAHelper.GetActiveProject <> nil;
end;

function TProjectToolsView.CanDeploy: Boolean;
begin
  Result := HasActiveProject and ActiveProjectProperties.Platform.StartsWith('Android', True) or not ActiveProjectProperties.Profile.IsEmpty;
end;

end.
