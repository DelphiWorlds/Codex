unit Codex.Project.ProjectManagerMenu;

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
  System.Classes,
  ToolsAPI,
  DW.OTA.ProjectManagerMenu;

type
  TProjectProjectManagerMenuNotifier = class(TProjectManagerMenuNotifier)
  private
    procedure AddFolders;
    procedure DeployFolder;
    procedure TotalClean;
  public
    procedure DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
      AIsMultiSelect: Boolean); override;
    procedure DoAddGroupMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
      AIsMultiSelect: Boolean); override;
  end;

implementation

uses
  System.SysUtils,
  DW.OTA.Helpers,
  Codex.Consts, Codex.Core;

type
  TAddFoldersProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

  TDeployFolderProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

resourcestring
  sAddFoldersCaption = 'Add Folders';
  sDeployFolderCaption = 'Deploy Folder';
  sTotalCleanCaption = 'Total Clean';

{ TAddFoldersProjectManagerMenu }

constructor TAddFoldersProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sAddFoldersCaption), 'CodexAddFolders', APosition, AExecuteProc);
end;

function TAddFoldersProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := TOTAHelper.GetCurrentSelectedProject <> nil;
end;

{ TDeployFolderProjectManagerMenu }

constructor TDeployFolderProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sDeployFolderCaption), 'CodexDeployFolder', APosition, AExecuteProc);
end;

function TDeployFolderProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := TOTAHelper.GetCurrentSelectedProject <> nil;
end;

{ TProjectProjectManagerMenuNotifier }

procedure TProjectProjectManagerMenuNotifier.DoAddGroupMenu(const AProject: IOTAProject; const AIdentList: TStrings;
  const AProjectManagerMenuList: IInterfaceList; AIsMultiSelect: Boolean);
begin
  //
end;

procedure TProjectProjectManagerMenuNotifier.DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings;
  const AProjectManagerMenuList: IInterfaceList; AIsMultiSelect: Boolean);
begin
  AProjectManagerMenuList.Add(TProjectManagerMenu.Create(Babel.Tx(sTotalCleanCaption), 'TotalClean', pmmpClean + 1, TotalClean));
  AProjectManagerMenuList.Add(TProjectManagerMenuSeparator.Create(cPMMPCodexMainSection));
  AProjectManagerMenuList.Add(TAddFoldersProjectManagerMenu.Create(cPMMPCodexMainSection + 40, AddFolders));
  AProjectManagerMenuList.Add(TDeployFolderProjectManagerMenu.Create(cPMMPCodexMainSection + 50, DeployFolder));
end;

procedure TProjectProjectManagerMenuNotifier.AddFolders;
begin
  ProjectToolsProvider.AddFolders;
end;

procedure TProjectProjectManagerMenuNotifier.DeployFolder;
begin
  ProjectToolsProvider.DeployProjectFolder;
end;

procedure TProjectProjectManagerMenuNotifier.TotalClean;
begin
  ProjectToolsProvider.TotalCleanProject;
end;

end.
