unit Codex.Android.GradleDepsProcess;

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
  DW.RunProcess.Win;

type
  TGradleDepsStage = (None, Initialize, GetDependencies);

  TGradleDepsProcess = class(TRunProcess)
  private
    FBuildPath: string;
    FCurrentDir: string;
    FGradlePath: string;
    FIsError: Boolean;
    FStage: TGradleDepsStage;
    FOnCompleted: TNotifyEvent;
    function CheckRequirements: Boolean;
    procedure Cleanup;
    procedure DoCompleted;
    procedure OutputExecuting;
  protected
    procedure DoTerminated(const AExitCode: Cardinal); override;
    function GradleInit: Boolean;
    procedure GetDependencies;
  public
    function Run: Boolean; override;
    property BuildPath: string read FBuildPath write FBuildPath;
    property GradlePath: string read FGradlePath write FGradlePath;
    property OnProcessOutput;
    property OnCompleted: TNotifyEvent read FOnCompleted write FOnCompleted;
  end;

implementation

uses
  System.IOUtils, System.SysUtils,
  DW.IOUtils.Helpers,
  Codex.Core, Codex.Consts.Text;

resourcestring
  sGetDependenciesFailed = 'Get dependencies failed with exit code: %d';
  sInitializationFailed = 'Initialization failed with exit code: %d';

{ TGradleDepsProcess }

function TGradleDepsProcess.CheckRequirements: Boolean;
begin
  Result := not FBuildPath.Trim.IsEmpty and TDirectory.Exists(FBuildPath) and
    not FGradlePath.Trim.IsEmpty and TFile.Exists(FGradlePath);
end;

procedure TGradleDepsProcess.Cleanup;
begin
  TDirectoryHelper.Delete(FBuildPath);
  TDirectory.SetCurrentDirectory(FCurrentDir);
end;

procedure TGradleDepsProcess.DoCompleted;
begin
  if Assigned(FOnCompleted) then
    FOnCompleted(Self);
end;

procedure TGradleDepsProcess.OutputExecuting;
begin
  DoOutput(Format(Babel.Tx(sExecutingCommand), [CommandLine]));
end;

procedure TGradleDepsProcess.DoTerminated(const AExitCode: Cardinal);
begin
  FIsError := FIsError or (AExitCode <> 0);
  case FStage of
    TGradleDepsStage.Initialize:
    begin
      if FIsError then
      begin
        DoOutput(Format(Babel.Tx(sInitializationFailed), [AExitCode]));
        Cleanup;
      end
      else
        GetDependencies;
    end;
    TGradleDepsStage.GetDependencies:
    begin
      if not FIsError then
      begin
        // DoOutput(Format('Successfully downloaded packages to: ', []));
        DoCompleted;
        Cleanup;
      end
      else
      begin
        DoOutput(Format(Babel.Tx(sGetDependenciesFailed), [AExitCode]));
        Cleanup;
      end;
      inherited;
    end;
  end;
end;

procedure TGradleDepsProcess.GetDependencies;
begin
  FStage := TGradleDepsStage.GetDependencies;
  CommandLine := Format('"%s" -q getDeps', [FGradlePath]);
  OutputExecuting;
  InternalRun;
end;

function TGradleDepsProcess.GradleInit: Boolean;
begin
  FCurrentDir := TDirectory.GetCurrentDirectory;
  TDirectory.SetCurrentDirectory(FBuildPath);
  FStage := TGradleDepsStage.Initialize;
  CommandLine := Format('"%s"', [FGradlePath]);
  OutputExecuting;
  Result := InternalRun;
end;

function TGradleDepsProcess.Run: Boolean;
begin
  Result := False;
  FIsError := False;
  FStage := TGradleDepsStage.None;
  if CheckRequirements then
    Result := GradleInit;
end;

end.
