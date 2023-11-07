unit Codex.SourcePatch.PatchProcess;

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
  DW.RunProcess.Win;

type
  TPatchProcess = class(TRunProcess)
  private
    FOutputPath: string;
    FPatchEXEPath: string;
    FSourceCopy: string;
    FSourceFilePath: string;
    FSourcePatchPath: string;
    FSourceWasCopied: Boolean;
  protected
    procedure DoOutput(const AOutput: string); override;
    procedure DoTerminated(const AExitCode: Cardinal); override;
  public
    function Run: Boolean; override;
    property OutputPath: string read FOutputPath write FOutputPath;
    property PatchEXEPath: string read FPatchEXEPath write FPatchEXEPath;
    property SourceFilePath: string read FSourceFilePath write FSourceFilePath;
    property SourcePatchPath: string read FSourcePatchPath write FSourcePatchPath;
  end;

implementation

uses
  DW.OSLog,
  System.SysUtils, System.IOUtils;

const
  // e.g. C:\Utils\Patch C:\Copied\FMX.VirtualKeyboard.Android.pas FMX.VirtualKeyboard.Android.10.2.2.patch
  cPatchCommand = '%s %s %s';

{ TPatchProcess }

procedure TPatchProcess.DoOutput(const AOutput: string);
begin
  inherited;
  TOSLog.d('TPatchProcess Output: %s', [AOutput]);
end;

procedure TPatchProcess.DoTerminated(const AExitCode: Cardinal);
begin
  inherited;
  if (AExitCode <> 0) and FSourceWasCopied then
    TFile.Delete(FSourceCopy);
end;

function TPatchProcess.Run: Boolean;
begin
  FSourceWasCopied := False;
  FSourceCopy := TPath.Combine(FOutputPath, TPath.GetFileName(FSourceFilePath));
  if not TFile.Exists(FSourceCopy) then
  begin
    TFile.Copy(FSourceFilePath, FSourceCopy);
    FSourceWasCopied := True;
  end;
  Process.CommandLine := Format(cPatchCommand, [FPatchEXEPath, FSourceCopy, FSourcePatchPath]);
  TOSLog.d('Command line is: %s', [Process.CommandLine]);
  Result := InternalRun;
end;

end.
