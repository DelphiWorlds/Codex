unit Codex.Android.Java2OPProcess;

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
  TPostProcessState = (None, UnitStart, ForwardDeclarations, ClassDeclaration, InstanceDeclaration, ImplementationSection, IgnoreDeclaration, UnitEnd);

  TJava2OPProcess = class(TRunProcess)
  private
    FClassPath: TStrings;
    FCurrentDir: string;
    FIncludedClasses: TStrings;
    FJarFiles: TStrings;
    FJavaSourceFolders: TStrings;
    FNeedsPostProcessing: Boolean;
    FOutputFilename: string;
    function CheckClassDeclaration(const ALine: string; const AWriter: TStreamWriter): TPostProcessState;
    function IsInternalClass(const ALine: string): Boolean;
    procedure PerformPostProcessing;
    procedure ProcessImplementationDeclaration(const ALine: string; const AWriter: TStreamWriter);
  protected
    procedure DoTerminated(const AExitCode: Cardinal); override;
  public
    constructor Create;
    destructor Destroy; override;
    function Run: Boolean; override;
    property ClassPath: TStrings read FClassPath;
    property IncludedClasses: TStrings read FIncludedClasses;
    property JarFiles: TStrings read FJarFiles;
    property JavaSourceFolders: TStrings read FJavaSourceFolders;
    property NeedsPostProcessing: Boolean read FNeedsPostProcessing write FNeedsPostProcessing;
    property OutputFilename: string read FOutputFilename write FOutputFilename;
    property OnProcessOutput;
  end;

implementation

uses
  System.IOUtils, System.SysUtils,
  DW.OSLog,
  DW.OS.Win, DW.IOUtils.Helpers,
  Codex.Consts, Codex.Core, Codex.Consts.Text;

const
  cJava2OPFilePath = 'converters\java2op\Java2OP.exe';
  cJava2OPClassesParam = '-classes %s';
  cJava2OPClassPathParam = '-classpath %s';
  cJava2OPExcludeParam = '-exclude %s';
  cJava2OPJarParam = '-jar %s';
  cJava2OPSourceParam = '-src %s';
  cJava2OPUnitParam = '-unit "%s"';

  cPostProcessStartsWithUnitDeclaration = 'unit';
  cPostProcessEqualsTypeDeclaration = 'type';
  cPostProcessEqualsImplementationDeclaration = 'implementation';
  cPostProcessContainsForwardDeclaration = 'interface;';
  cPostProcessContainsDeclaration = 'interface(';
  cPostProcessContainsClassDeclaration = 'Class = interface(';
  cPostProcessContainsInternalClassZZPrefix = 'Jzz';
  cPostProcessContainsInternalClassZZSuffix = '_zz';
  cPostProcessEndStatement = 'end.';

resourcestring
  sPerformingPostProcessing = 'Performing post processing..';

type
  TStringsHelper = class helper for TStrings
  public
    function CombineText(const ASeparator: string; const AQuoted: Boolean): string;
  end;

{ TStringsHelper }

function TStringsHelper.CombineText(const ASeparator: string; const AQuoted: Boolean): string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to Count - 1 do
  begin
    if I > 0 then
      Result := Result + ASeparator;
    if AQuoted then
      Result := Result + '"' + Strings[I] + '"'
    else
      Result := Result + Strings[I];
  end;
end;

{ TJava2OPProcess }

constructor TJava2OPProcess.Create;
begin
  inherited;
  FClassPath := TStringList.Create;
  FIncludedClasses := TStringList.Create;
  FJavaSourceFolders := TStringList.Create;
  FJarFiles := TStringList.Create;
end;

destructor TJava2OPProcess.Destroy;
begin
  FClassPath.Free;
  FIncludedClasses.Free;
  FJavaSourceFolders.Free;
  FJarFiles.Free;
  inherited;
end;

function TJava2OPProcess.Run: Boolean;
var
  LCmd, LClasses, LJarFiles, LFolders, LJava2OPFilePath, LOutputFileName, LClassPath: string;
begin
  Result := False;
  LJava2OPFilePath := TPath.Combine(TPlatformOS.GetEnvironmentVariable(cEnvVarBDSBin), cJava2OPFilePath);
  if TFile.Exists(LJava2OPFilePath) then
  begin
    LClasses := FIncludedClasses.CombineText(' ', True);
    LFolders := FJavaSourceFolders.CombineText(' ', True);
    LJarFiles := FJarFiles.CombineText(' ', True);
    LClassPath := FClassPath.CombineText(' ', True);
    LCmd := TPath.GetFileName(LJava2OPFilePath);
    if not LClasses.IsEmpty then
      LCmd := LCmd + ' ' + Format(cJava2OPClassesParam, [LClasses]);
    if not LFolders.IsEmpty then
      LCmd := LCmd + ' ' + Format(cJava2OPSourceParam, [LFolders]);
    if not LJarFiles.IsEmpty then
      LCmd := LCmd + ' ' + Format(cJava2OPJarParam, [LJarFiles]);
    if not LClassPath.IsEmpty then
      LCmd := LCmd + ' ' + Format(cJava2OPClassPathParam, [LClassPath]);
    if not FOutputFilename.IsEmpty then
    begin
      LOutputFileName := TPath.ChangeExtension(FOutputFilename, '');
      LCmd := LCmd + ' ' + Format(cJava2OPUnitParam, [LOutputFileName.Substring(0, Length(LOutputFileName) - 1)]);
    end;
    // As a minumum, needs classes, or jars
    if (not LClasses.IsEmpty or not LJarFiles.IsEmpty) and not FOutputFilename.IsEmpty then
    begin
      FCurrentDir := GetCurrentDir;
      ChDir(TPath.GetDirectoryName(LJava2OPFilePath));
      Process.CommandLine := LCmd;
      TOSLog.d('Command line: %s', [LCmd]);
      Result := InternalRun;
    end
    else ; // Insufficient parameters
  end
  else ; // Cannot find Java2OP
end;

procedure TJava2OPProcess.DoTerminated(const AExitCode: Cardinal);
begin
  if FNeedsPostProcessing and TFile.Exists(FOutputFilename) then
    PerformPostProcessing;
  if not FCurrentDir.IsEmpty then
    ChDir(FCurrentDir);
  DoOutput(Format(Babel.Tx(sCommandExitedWithCode), [Process.CommandLine, AExitCode]));
  inherited;
end;

function TJava2OPProcess.IsInternalClass(const ALine: string): Boolean;
begin
  Result := ALine.Contains(cPostProcessContainsInternalClassZZSuffix) or ALine.Contains(cPostProcessContainsInternalClassZZPrefix);
end;

function TJava2OPProcess.CheckClassDeclaration(const ALine: string; const AWriter: TStreamWriter): TPostProcessState;
begin
  if not IsInternalClass(ALine) then
  begin
    AWriter.WriteLine(ALine);
    Result := TPostProcessState.ClassDeclaration;
  end
  else
    Result := TPostProcessState.IgnoreDeclaration;
end;

procedure TJava2OPProcess.ProcessImplementationDeclaration(const ALine: string; const AWriter: TStreamWriter);
begin
  // Skip the unwanted text
  AWriter.WriteLine(ALine);
  AWriter.WriteLine;
  AWriter.WriteLine(cPostProcessEndStatement);
end;

procedure TJava2OPProcess.PerformPostProcessing;
var
  LBackupFileName, LLine: string;
  LReader: TStreamReader;
  LWriter: TStreamWriter;
  LState: TPostProcessState;
  LParts: TArray<string>;
begin
  DoOutput(Babel.Tx(sPerformingPostProcessing));
  LBackupFileName := FOutputFilename + '.bak';
  TFile.Copy(FOutputFilename, LBackupFileName);
  LState := TPostProcessState.None;
  LReader := TStreamReader.Create(LBackupFileName);
  try
    LWriter := TStreamWriter.Create(FOutputFilename);
    try
      while (LState <> TPostProcessState.UnitEnd) and not LReader.EndOfStream do
      begin
        LLine := LReader.ReadLine;
        case LState of
          TPostProcessState.None:
          begin
            // Skip blank lines at beginning
            if not LLine.Trim.IsEmpty then
            begin
              if LLine.StartsWith(cPostProcessStartsWithUnitDeclaration) then
              begin
                LParts := LLine.Split([' '], 2);
                if (Length(LParts) > 1) and (Pos(':', LParts[1]) = 2)  then
                  LLine := Format('%s %s', [LParts[0], TPath.GetFileName(LParts[1])]);
                LState := TPostProcessState.UnitStart;
              end;
              LWriter.WriteLine(LLine);
            end;
          end;
          TPostProcessState.UnitStart:
          begin
            if LLine.Equals(cPostProcessEqualsTypeDeclaration) then
              LState := TPostProcessState.ForwardDeclarations;
            LWriter.WriteLine(LLine);
          end;
          TPostProcessState.ForwardDeclarations:
          begin
            if LLine.Contains(cPostProcessContainsClassDeclaration) then
              LState := CheckClassDeclaration(LLine, LWriter)
            else if not LLine.Contains(cPostProcessContainsForwardDeclaration) or not IsInternalClass(LLine) then
              LWriter.WriteLine(LLine);
          end;
          TPostProcessState.ClassDeclaration:
          begin
            if LLine.Contains(cPostProcessContainsClassDeclaration) then
              LState := CheckClassDeclaration(LLine, LWriter)
            else if LLine.Equals(cPostProcessEqualsImplementationDeclaration) then
            begin
              ProcessImplementationDeclaration(LLine, LWriter);
              LState := TPostProcessState.UnitEnd;
            end
            else
              LWriter.WriteLine(LLine);
          end;
          TPostProcessState.IgnoreDeclaration:
          begin
            if LLine.Contains(cPostProcessContainsClassDeclaration) then
            begin
              if not IsInternalClass(LLine) then
              begin
                LWriter.WriteLine(LLine);
                LState := TPostProcessState.ClassDeclaration;
              end
              else if LLine.Equals(cPostProcessEqualsImplementationDeclaration) then
              begin
                ProcessImplementationDeclaration(LLine, LWriter);
                LState := TPostProcessState.UnitEnd;
              end;
            end
          end;
        end;
      end;
    finally
      LWriter.Free;
    end;
  finally
    LReader.Free;
  end;
  TFile.Delete(LBackupFileName);
end;

end.
