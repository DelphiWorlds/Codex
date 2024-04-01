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

uses
  ToolsAPI,
  DW.OTA.Types,
  Codex.Types;

type
  TDeployConfig = record
    PlatformName: string;
    Configs: TArray<string>;
  end;

  TDeployConfigs = TArray<TDeployConfig>;

  TCodexOTAHelper = record
  public
    class function AddMessage(const AMsg: string; const AGroupName: string = 'Codex'): IOTAMessageGroup; overload; static;
    class function AddMessage(const AMsg: string; const AColor: TTextColor; const AGroupName: string = 'Codex'): IOTAMessageGroup; overload; static;
    class function CheckProjectChanged: Boolean; static;
    class function DeployFolder(const ALocalPath, ARemotePath: string; const ADeployConfigs: TDeployConfigs): Boolean; static;
    class function ExecuteIDEAction(const AActionName: string): Boolean; static;
    class function GetDeployConfigs(const APlatformNames: TArray<string>; out ADeployConfigs: TDeployConfigs): Boolean; static;
    class function GetColoredText(const AColor, AText: string): string; static;
    class function GetMsgColoredText(const AColor: TTextColor; const AText: string): string; static;
    class function GetProjectEnabledPlatforms(const AProject: IOTAProject): TProjectPlatforms; static;
    class procedure HideWait; static;
    class procedure HideWaitSync; static;
    class procedure ShowWait(const AMessage: string; const ACaption: string = ''); static;
  end;

implementation

uses
  System.SysUtils, System.IOUtils, System.StrUtils, System.Classes,
  DeploymentAPI, PlatformAPI,
  Xml.XmlIntf, Xml.XMLDoc,
  Vcl.ActnList,
  DW.OTA.Helpers, DW.IOUtils.Helpers, DW.OTA.Consts, DW.OTA.CustomMessage, DW.Proj,
  Codex.Core, Codex.Consts.Text, Codex.Consts;

{ TCodexOTAHelper }

class function TCodexOTAHelper.AddMessage(const AMsg: string; const AGroupName: string = 'Codex'): IOTAMessageGroup;
var
  LServices: IOTAMessageServices;
  LGroup: IOTAMessageGroup;
  LComponent: TComponent;
  LMessage: IOTACustomMessage;
begin
  LGroup := nil;
  LServices := BorlandIDEServices as IOTAMessageServices;
  if not AGroupName.IsEmpty then
  begin
    LGroup := LServices.GetGroup(AGroupName);
    if LGroup = nil then
      LGroup := LServices.AddMessageGroup(AGroupName);
    LMessage := THighlightedCustomMessage.Create(AMsg);
    LServices.AddCustomMessage(LMessage, LGroup);
    LComponent := FindGlobalComponent('MessageViewForm');
    if LComponent <> nil then
      LServices.ShowMessageView(LGroup);
  end
  else
    LServices.AddTitleMessage(AMsg);
  Result := LGroup;
end;

class function TCodexOTAHelper.AddMessage(const AMsg: string; const AColor: TTextColor; const AGroupName: string = 'Codex'): IOTAMessageGroup;
begin
  Result := AddMessage(GetMsgColoredText(AColor, AMsg), AGroupName);
end;

class function TCodexOTAHelper.CheckProjectChanged: Boolean;
var
  LProject: IOTAProject;
  LPlatform: TProjectPlatform;
  LProperties: TProjectProperties;
begin
  Result := False;
  LProject := TOTAHelper.GetActiveProject;
  if LProject <> nil then
  begin
    LPlatform := TOTAHelper.GetProjectCurrentPlatform(TOTAHelper.GetActiveProject);
    LProperties.ProjectFileName := LProject.FileName;
    LProperties.ProjectPlatform := LPlatform;
    LProperties.Platform := cProjectPlatformsLong[LPlatform];
    LProperties.Config := LProject.CurrentConfiguration;
    LProperties.BuildType := TOTAHelper.GetProjectCurrentBuildType(LProject);
    LProperties.Profile := TOTAHelper.GetProjectCurrentConnectionProfile(LProject);
    if ActiveProjectProperties.Update(LProperties) then
      Result := True;
  end
  else if not ActiveProjectProperties.ProjectFileName.IsEmpty then
  begin
    ActiveProjectProperties.Clear;
    Result := True;
  end;
end;

class function TCodexOTAHelper.DeployFolder(const ALocalPath, ARemotePath: string; const ADeployConfigs: TDeployConfigs): Boolean;
var
  LProject: IOTAProject;
  LDeployment: IProjectDeployment;
  LDeploymentFile: IProjectDeploymentFile;
  LRemoteDir, LLocalDir, LFileName, LSourcePath, LLocalName, LRemoteName, LConfigName: string;
  LDeployConfig: TDeployConfig;
  LDeployed: Boolean;
  LProjDeployment: IProjDeployment;
begin
  Result := False;
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if Supports(LProject, IProjectDeployment, LDeployment) then
  begin
    LProjDeployment := TProj.Create(LProject.FileName).GetProjectDeployment;
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
            LLocalName := TPath.Combine(LLocalDir, TPath.GetFileName(LFileName));
            LRemoteName := TPath.GetFileName(LFileName);
            if not LProjDeployment.HasDeployFile(LDeployConfig.PlatformName, LConfigName, LRemoteDir, LRemoteName) then
            begin
              LDeploymentFile := LDeployment.CreateFile(LConfigName, LDeployConfig.PlatformName, LLocalName);
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

class function TCodexOTAHelper.ExecuteIDEAction(const AActionName: string): Boolean;
var
  LAction: TCustomAction;
begin
  Result := False;
  if TOTAHelper.FindActionGlobal(AActionName, LAction) then
  begin
    LAction.Execute;
    Result := True;
  end;
end;

class function TCodexOTAHelper.GetMsgColoredText(const AColor: TTextColor; const AText: string): string;
begin
  Result := GetColoredText(cMsgColors[AColor], AText);
end;

class function TCodexOTAHelper.GetColoredText(const AColor, AText: string): string;
begin
  Result := Format('<%s>%s</#>', [AColor, AText]);
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

class function TCodexOTAHelper.GetProjectEnabledPlatforms(const AProject: IOTAProject): TProjectPlatforms;
var
  LProj: IXMLDocument;
  LNode, LPlatformNode: IXMLNode;
  I: Integer;
  LPlatform: string;
begin
  Result := [];
  LProj := LoadXMLDocument(AProject.FileName);
  LNode := LProj.DocumentElement.ChildNodes.FindNode('ProjectExtensions');
  if LNode <> nil then
  begin
    LNode := LNode.ChildNodes.FindNode('BorlandProject');
    if LNode <> nil then
    begin
      LNode := LNode.ChildNodes.FindNode('Platforms');
      if LNode <> nil then
      begin
        for I := 0 to LNode.ChildNodes.Count - 1 do
        begin
          LPlatformNode := LNode.ChildNodes[I];
          if SameText(LPlatformNode.Text, 'True') then
          begin
            LPlatform := LPlatformNode.Attributes['value'];
            if IndexStr(LPlatform, cProjectPlatforms) > -1 then
              Include(Result, TOTAHelper.GetProjectPlatform(LPlatform));
          end;
        end;
      end;
    end;
  end;
end;

class procedure TCodexOTAHelper.HideWaitSync;
begin
  TThread.Queue(nil, HideWait);
end;

class procedure TCodexOTAHelper.HideWait;
{$IF CompilerVersion > 35}
begin
  (BorlandIDEServices as IOTAIDEWaitDialogServices).CloseDialog;
end;
{$ELSE}
begin
end;
{$ENDIF}

class procedure TCodexOTAHelper.ShowWait(const AMessage: string; const ACaption: string = '');
{$IF CompilerVersion > 35}
var
  LCaption: string;
begin
  if ACaption.IsEmpty then
    LCaption := sInProgress
  else
    LCaption := ACaption;
  (BorlandIDEServices as IOTAIDEWaitDialogServices).Show(Babel.Tx(LCaption), Babel.Tx(AMessage))
end;
{$ELSE}
begin
end;
{$ENDIF}

end.
