unit Codex.PostDeployment.Wizard;

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
  System.IOUtils, System.DateUtils, System.SysUtils,
  ToolsAPI, CommonOptionStrs,
  DW.OSLog,
  DW.OTA.Wizard, DW.OTA.Helpers, DW.OTA.Consts, DW.RunProcess.Win,
  Codex.PListMerger, Codex.Core;

type
  TPostDeploymentWizard = class(TWizard)
  private
    procedure CheckNeedsPListMerge;
    function ExecutePostDeploy: Boolean;
  protected
    function DebuggerBeforeProgramLaunch(const Project: IOTAProject): Boolean; override;
    procedure PeriodicTimer; override;
  end;

resourcestring
  sPListMergedFileWithPList = 'Merged %s with %s';
  sPListFailedToMergeFileWithPList = 'Failed to merge %s with %s';

function TPostDeploymentWizard.DebuggerBeforeProgramLaunch(const Project: IOTAProject): Boolean;
begin
  try
    Result := ExecutePostDeploy;
  except
    on E: Exception do
    begin
      Result := False;
      // Do not localize
      TOTAHelper.AddTitleMessage(Format('ExecutePostDeploy caused an exception - %s: %s', [E.ClassName, E.Message]));
    end;
  end;
  Result := Result and inherited;
end;

function TPostDeploymentWizard.ExecutePostDeploy: Boolean;
const
  cWaitLimit = 6000;
var
  LPostDeployCmdFileName, LPostDeployCmd, LProjectName: string;
  LProcess: TRunProcess;
begin
  LPostDeployCmdFileName := TPath.Combine(TOTAHelper.GetActiveProjectPath, 'PostDeploy.command');
  if TFile.Exists(LPostDeployCmdFileName) then
  begin
    Result := True;
    LPostDeployCmd := TFile.ReadAllText(LPostDeployCmdFileName);
    if not LPostDeployCmd.IsEmpty then
    begin
      Result := False;
      LProjectName := TOTAHelper.GetProjectActiveBuildConfigurationValue(TOTAHelper.GetActiveProject, sSanitizedProjectName);
      LPostDeployCmd := LPostDeployCmd.Replace('$(EXEOutput)', TOTAHelper.GetActiveProjectOutputDir, [rfReplaceAll, rfIgnoreCase]);
      LPostDeployCmd := LPostDeployCmd.Replace('$(SanitizedProjectName)', LProjectName, [rfReplaceAll, rfIgnoreCase]);
      LPostDeployCmd := TOTAHelper.ExpandVars(LPostDeployCmd);
      TOSLog.d('Executing PostDeploy command: %s', [LPostDeployCmd]);
      LProcess := TRunProcess.Create;
      try
        LProcess.CommandLine := LPostDeployCmd;
        if LProcess.RunAndWait(cWaitLimit) = 0 then
        begin
          if LProcess.ExitCode = 0 then
          begin
            TOSLog.d('PostDeploy command executed successfully');
            Result := True
          end
          else
            TOSLog.d('PostDeploy command exited with code: %d', [LProcess.ExitCode]);
        end
        else
          TOSLog.d('Timed out waiting for PostDeploy command to finish');
      finally
        LProcess.Free;
      end;
    end;
  end
  else
    Result := True;
end;

procedure TPostDeploymentWizard.CheckNeedsPListMerge;
var
  LProject: IOTAProject;
  LProjectName, LProjectPath, LOutputPath, LPListFileName, LMergeFileName: string;
  LPListDateTime, LMergeDateTime: TDateTime;
begin
  LProject := TOTAHelper.GetActiveProject;
  if LProject <> nil then
  begin
    LProjectPath := TOTAHelper.GetProjectPath(LProject);
    LProjectName := TOTAHelper.GetProjectActiveBuildConfigurationValue(LProject, sSanitizedProjectName);
    if TOTAHelper.GetProjectCurrentPlatform(LProject) in cIOSProjectPlatforms then
    begin
      LMergeFileName := TPath.Combine(LProjectPath, 'info.plist.TemplateiOS.merge.xml');
      if TFile.Exists(LMergeFileName) then
      begin
        LMergeDateTime := TFile.GetLastWriteTime(LMergeFileName);
        LOutputPath := TOTAHelper.GetProjectOutputDir(LProject);
        LPListFileName := TPath.Combine(LOutputPath, LProjectName + '.info.plist');
        if TFile.Exists(LPListFileName) then
        begin
          LPListDateTime := TFile.GetLastWriteTime(LPListFileName);
          if LPListDateTime > LMergeDateTime then
          begin
            if TPListMerger.MergePList(LMergeFileName, LPListFileName) = 0 then
            begin
              // Set merge file to the same date/time
              TFile.SetLastWriteTime(LMergeFileName, LPListDateTime);
              TOTAHelper.AddTitleMessage(Format(Babel.Tx(sPListMergedFileWithPList), [LMergeFileName, LPListFileName]));
            end
            else
              TOTAHelper.AddTitleMessage(Format(Babel.Tx(sPListFailedToMergeFileWithPList), [LMergeFileName, LPListFileName]));
          end;
        end;
      end;
    end;
  end;
end;

procedure TPostDeploymentWizard.PeriodicTimer;
begin
  CheckNeedsPListMerge;
end;

initialization
  TOTAWizard.RegisterWizard(TPostDeploymentWizard);

end.
