unit Codex.OTA.Helpers;

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

type
  TDeployConfig = record
    PlatformName: string;
    Configs: TArray<string>;
  end;

  TDeployConfigs = TArray<TDeployConfig>;

  TCodexOTAHelper = record
  public
    class function GetDeployConfigs(const APlatformNames: TArray<string>; out ADeployConfigs: TDeployConfigs): Boolean; static;
    class function DeployFolder(const ALocalPath, ARemotePath: string; const ADeployConfigs: TDeployConfigs): Boolean; static;
    class procedure ExecuteIDEAction(const AActionName: string); static;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.StrUtils,
  ToolsAPI, DeploymentAPI, PlatformAPI,
  Vcl.ActnList,
  DW.OTA.Helpers, DW.IOUtils.Helpers;

{ TCodexOTAHelper }

class function TCodexOTAHelper.DeployFolder(const ALocalPath, ARemotePath: string; const ADeployConfigs: TDeployConfigs): Boolean;
var
  LProject: IOTAProject;
  LDeployment: IProjectDeployment;
  LDeploymentFile: IProjectDeploymentFile;
  LRemoteDir, LLocalDir, LFileName, LSourcePath, LRemoteName, LConfigName: string;
  LDeployConfig: TDeployConfig;
  LDeployed: Boolean;
begin
  Result := False;
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if Supports(LProject, IProjectDeployment, LDeployment) then
  begin
    LDeployed := False;
    // eg: Z:\Kastri\ThirdParty\Android\androidx-biometric-1.1.0\res
    LSourcePath := IncludeTrailingPathDelimiter(ALocalPath);
    // Remote: res
    LDeployment.BlockNotifications := True;
    try
      for LFileName in TDirectory.GetFiles(ALocalPath, '*.*', TSearchOption.soAllDirectories) do
      begin
        // e.g. Z:\Kastri\ThirdParty\Android\androidx-biometric-1.1.0\res\values
        LLocalDir := ExcludeTrailingPathDelimiter(TPath.GetDirectoryName(LFileName));
        // res\values\
        LRemoteDir := IncludeTrailingPathDelimiter(TPath.Combine(ARemotePath, LLocalDir.Substring(Length(LSourcePath))));
        LLocalDir := TPathHelper.GetRelativePath(TPath.GetDirectoryName(LProject.FileName), LLocalDir);
        if LLocalDir.StartsWith('.\') then
          LLocalDir := LLocalDir.Substring(2);
        for LDeployConfig in ADeployConfigs do
        begin
          for LConfigName in LDeployConfig.Configs do
          begin
            LRemoteName := TPath.GetFileName(LFileName);
            LDeploymentFile := LDeployment.CreateFile(LConfigName, LDeployConfig.PlatformName, TPath.Combine(LLocalDir, TPath.GetFileName(LFileName)));
            LDeploymentFile.Enabled[LDeployConfig.PlatformName] := True;
            LDeploymentFile.DeploymentClass := 'File';
            LDeploymentFile.FilePlatform := LDeployConfig.PlatformName;
            LDeploymentFile.Configuration := LConfigName;
            LDeploymentFile.RemoteDir[LDeployConfig.PlatformName] := LRemoteDir;
            LDeploymentFile.RemoteName[LDeployConfig.PlatformName] := LRemoteName;
            LDeployment.AddFile(LConfigName, LDeployConfig.PlatformName, LDeploymentFile);
            LDeployed := True;
          end;
        end;
      end;
    finally
      LDeployment.BlockNotifications := False;
    end;
    if LDeployed then
    begin
      LDeployment.Reconcile;
      LDeployment.SaveToMSBuild;
      TOTAHelper.MarkActiveProjectModified;
      Result := True;
    end;
  end;
end;

class procedure TCodexOTAHelper.ExecuteIDEAction(const AActionName: string);
var
  LAction: TCustomAction;
begin
  if TOTAHelper.FindActionGlobal(AActionName, LAction) then
    LAction.Execute;
end;

class function TCodexOTAHelper.GetDeployConfigs(const APlatformNames: TArray<string>; out ADeployConfigs: TDeployConfigs): Boolean;
var
  LProject: IOTAProject;
  LProjectOptionsConfigs: IOTAProjectOptionsConfigurations;
  I: Integer;
  LConfig: IOTABuildConfiguration;
  LPlatform: string;
  LProjectPlatforms: IOTAProjectPlatforms;
  LPlatforms: TArray<string>;
  LDeployConfig: TDeployConfig;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if (LProject <> nil) and Supports(LProject, IOTAProjectPlatforms, LProjectPlatforms) then
  begin
    LPlatforms := LProjectPlatforms.SupportedPlatforms;
    LProjectOptionsConfigs := TOTAHelper.GetProjectOptionsConfigurations(LProject);
    for LPlatform in LPlatforms do
    begin
      if IndexStr(LPlatform, APlatformNames) > -1 then
      begin
        LDeployConfig.PlatformName := LPlatform;
        LDeployConfig.Configs := [];
        for I := 0 to LProjectOptionsConfigs.ConfigurationCount - 1 do
        begin
          LConfig := LProjectOptionsConfigs.Configurations[I];
          if not LConfig.Name.Equals('Base') then
            LDeployConfig.Configs := LDeployConfig.Configs + [LConfig.Name];
        end;
        if Length(LDeployConfig.Configs) > 0 then
          ADeployConfigs := ADeployConfigs + [LDeployConfig];
      end;
    end;
  end;
  Result := Length(ADeployConfigs) > 0;
end;

end.
