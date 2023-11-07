unit Codex.Project.ResourcesModule;

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
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls, System.Actions, Vcl.ActnList, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.VirtualImageList, Vcl.Dialogs,
  Codex.CustomResourcesModule;

type
  TProjectResourcesModule = class(TDataModule)
    ActionList: TActionList;
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
    DeployAction: TAction;
    VirtualImageList: TVirtualImageList;
    ImageCollection: TImageCollection;
    CommonPathsAction: TAction;
    procedure CommonProjectActionUpdate(Sender: TObject);
    procedure CompileActionExecute(Sender: TObject);
    procedure BuildActionExecute(Sender: TObject);
    procedure CleanActionExecute(Sender: TObject);
    procedure TotalCleanActionExecute(Sender: TObject);
    procedure DeployActionExecute(Sender: TObject);
    procedure ShowOptionsActionExecute(Sender: TObject);
    procedure ViewSourceActionExecute(Sender: TObject);
    procedure ShowDeployActionExecute(Sender: TObject);
    procedure InsertPathsActionExecute(Sender: TObject);
    procedure DeployActionUpdate(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  ProjectResourcesModule: TProjectResourcesModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  DW.OSLog,
  Codex.Core;

constructor TProjectResourcesModule.Create(AOwner: TComponent);
begin
  inherited;
  ProjectResources := Self;
end;

procedure TProjectResourcesModule.CompileActionExecute(Sender: TObject);
begin
  if ProjectToolsProvider <> nil then
    ProjectToolsProvider.CompileProject;
end;

procedure TProjectResourcesModule.DeployActionExecute(Sender: TObject);
begin
  if ProjectToolsProvider <> nil then
    ProjectToolsProvider.DeployProject;
end;

procedure TProjectResourcesModule.DeployActionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (ProjectToolsProvider <> nil) and ProjectToolsProvider.CanDeployProject;
end;

procedure TProjectResourcesModule.InsertPathsActionExecute(Sender: TObject);
begin
  if ProjectToolsProvider <> nil then
    ProjectToolsProvider.InsertProjectPaths;
end;

procedure TProjectResourcesModule.ShowDeployActionExecute(Sender: TObject);
begin
  if ProjectToolsProvider <> nil then
    ProjectToolsProvider.ShowProjectDeployment;
end;

procedure TProjectResourcesModule.ShowOptionsActionExecute(Sender: TObject);
begin
  if ProjectToolsProvider <> nil then
    ProjectToolsProvider.ShowProjectOptions;
end;

procedure TProjectResourcesModule.TotalCleanActionExecute(Sender: TObject);
begin
  if ProjectToolsProvider <> nil then
    ProjectToolsProvider.TotalCleanProject;
end;

procedure TProjectResourcesModule.ViewSourceActionExecute(Sender: TObject);
begin
  if ProjectToolsProvider <> nil then
    ProjectToolsProvider.ViewProjectSource;
end;

procedure TProjectResourcesModule.BuildActionExecute(Sender: TObject);
begin
  if ProjectToolsProvider <> nil then
    ProjectToolsProvider.BuildProject;
end;

procedure TProjectResourcesModule.CleanActionExecute(Sender: TObject);
begin
  if ProjectToolsProvider <> nil then
    ProjectToolsProvider.CleanProject;
end;

procedure TProjectResourcesModule.CommonProjectActionUpdate(Sender: TObject);
begin
  TAction(Sender).Enabled := (ProjectToolsProvider <> nil) and ProjectToolsProvider.HasActiveProject;
end;

end.
