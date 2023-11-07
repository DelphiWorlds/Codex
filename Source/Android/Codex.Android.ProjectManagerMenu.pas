unit Codex.Android.ProjectManagerMenu;

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
  System.Classes, ToolsAPI, DW.OTA.ProjectManagerMenu;

type
  TAndroidProjectManagerMenuNotifier = class(TProjectManagerMenuNotifier)
  private
    procedure AddAndroidPackage;
    procedure BuildAssetPacks;
    procedure ShowAddAndroidPackage;
  public
    procedure DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
      AIsMultiSelect: Boolean); override;
  end;

implementation

uses
  System.SysUtils, System.IOUtils,
  CommonOptionStrs,
  Vcl.Forms,
  DW.OTA.Helpers, DW.OTA.Consts, DW.Vcl.DialogService,
  Codex.Android.PackagesView, Codex.Core;

resourcestring
  sAddAndroidPackageCaption = 'Add Android Package';
  sBuildAssetPacksCaption = 'Build Asset Packs';
  sPerformDeployment = 'Please perform a deployment before adding an Android package';

const
  cPMMPAndroidToolsSection = pmmpVersionControlSection + 501000;

type
  TBuildAssetPacksProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

  TAddAndroidPackageProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

{ TBuildAssetPacksProjectManagerMenu }

constructor TBuildAssetPacksProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sBuildAssetPacksCaption), 'BuildAssetPacks', APosition, AExecuteProc);
end;

function TBuildAssetPacksProjectManagerMenu.GetEnabled: Boolean;
var
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  Result :=  (LProject <> nil) and (TOTAHelper.GetProjectCurrentPlatform(LProject) in cAndroidProjectPlatforms);
end;

{ TAddAndroidPackageProjectManagerMenu }

constructor TAddAndroidPackageProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sAddAndroidPackageCaption), 'CodexAddAndroidPackage', APosition, AExecuteProc);
end;

function TAddAndroidPackageProjectManagerMenu.GetEnabled: Boolean;
var
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  Result := (LProject <> nil) and LProject.CurrentPlatform.StartsWith('Android');
end;

{ TAndroidProjectManagerMenuNotifier }

procedure TAndroidProjectManagerMenuNotifier.DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings;
  const AProjectManagerMenuList: IInterfaceList; AIsMultiSelect: Boolean);
begin
  AProjectManagerMenuList.Add(TAddAndroidPackageProjectManagerMenu.Create(cPMMPAndroidToolsSection + 100, AddAndroidPackage));
  AProjectManagerMenuList.Add(TBuildAssetPacksProjectManagerMenu.Create(cPMMPAndroidToolsSection + 105, BuildAssetPacks));
end;

procedure TAndroidProjectManagerMenuNotifier.AddAndroidPackage;
var
  LProject: IOTAProject;
  LProjectName, LDeployedPath: string;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if LProject <> nil then
  begin
    LProjectName := TOTAHelper.GetProjectActiveBuildConfigurationValue(LProject, sSanitizedProjectName);
    LDeployedPath := TPath.Combine(TOTAHelper.GetProjectOutputDir(LProject), LProjectName);
    if TDirectory.Exists(TPath.Combine(LDeployedPath, 'res')) then
      ShowAddAndroidPackage
    else
      TDialog.Warning(Babel.Tx(sPerformDeployment));
  end;
end;

procedure TAndroidProjectManagerMenuNotifier.ShowAddAndroidPackage;
var
  LDialog: TForm;
begin
  LDialog := TPackagesView.Create(nil);
  try
    LDialog.ShowModal;
  finally
    LDialog.Free;
  end;
end;

procedure TAndroidProjectManagerMenuNotifier.BuildAssetPacks;
begin
  // TODO
end;

end.

