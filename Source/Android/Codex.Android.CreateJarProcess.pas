unit Codex.Android.CreateJarProcess;

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
  TJarProcessStep = (None, BuildJava, BuildJar, DexJar);

  TCreateJarProcess = class(TRunProcess)
  private
    FAPILevelPath: string;
    FCurrentDir: string;
    FDebugConfig: Boolean;
    FDexPath: string;
    FIncludedJars: TStrings;
    FIsError: Boolean;
    FJarFilename: string;
    FJavaFiles: TStrings;
    FJavaSourceFiles: TStrings;
    FJavaSourcesFileName: string;
    FJDKPath: string;
    FShouldDex: Boolean;
    FShouldRetainWorkingFiles: Boolean;
    FSourceVersion: string;
    FStep: TJarProcessStep;
    FTargetVersion: string;
    FWorkingDir: string;
    FWorkingPath: string;
    function BuildJava: Boolean;
    procedure BuildJar;
    function CheckRequirements: Boolean;
    procedure Cleanup;
    procedure DexJar;
    function GetJavaFiles: Boolean;
    procedure OutputExecuting;
  protected
    procedure DoTerminated(const AExitCode: Cardinal); override;
  public
    constructor Create;
    destructor Destroy; override;
    function Run: Boolean; override;
    // TODO: Add property to exclude warnings (-nowarn). In some cases (e.g. rebuilding fmx.jar), they can be many
    property APILevelPath: string read FAPILevelPath write FAPILevelPath;
    property DebugConfig: Boolean read FDebugConfig write FDebugConfig;
    property DexPath: string read FDexPath write FDexPath;
    property IncludedJars: TStrings read FIncludedJars;
    property JarFilename: string read FJarFilename write FJarFilename;
    property JavaSourceFiles: TStrings read FJavaSourceFiles;
    property JDKPath: string read FJDKPath write FJDKPath;
    property ShouldDex: Boolean read FShouldDex write FShouldDex;
    property ShouldRetainWorkingFiles: Boolean read FShouldRetainWorkingFiles write FShouldRetainWorkingFiles;
    property SourceVersion: string read FSourceVersion write FSourceVersion;
    property TargetVersion: string read FTargetVersion write FTargetVersion;
    property OnProcessOutput;
  end;

implementation

uses
  System.IOUtils, System.SysUtils, System.Math,
  DW.IOUtils.Helpers,
  Codex.Core, Codex.Consts.Text;

const
  cJavaCompilerCommand = '%s\javac';
  cJavaCompilerParams = '-Xlint:deprecation -classpath "%s\android.jar;%s" -d "%s\classes" -target %s -source %s @"%s"'; // -verbose -nowarn
  cJavaCompileTimeout = 30000;
  cJarBuildCommand = '%s\jar';
  cJarBuildParams = 'cvf %s %s';
  cJarClassDirOptionParam = '-C %s\classes %s';
  cJarBuildTimeout = 15000;
  cDexCommand = '%s\dx.bat'; // TODO: This command may have been deprecated
  cDexParams = '--dex --output="%s" --positions=lines "%s"';

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

{ TCreateJarProcess }

constructor TCreateJarProcess.Create;
begin
  inherited;
  FSourceVersion := '1.10';
  FTargetVersion := '1.10';
  FIncludedJars := TStringList.Create;
  FJavaSourceFiles := TStringList.Create;
  FJavaFiles := TStringList.Create;
end;

destructor TCreateJarProcess.Destroy;
begin
  FIncludedJars.Free;
  FJavaSourceFiles.Free;
  FJavaFiles.Free;
  inherited;
end;

function TCreateJarProcess.GetJavaFiles: Boolean;
var
  I: Integer;
  LFile, LFolder, LFolderFolder, LCommonFolder: string;
begin
  FWorkingDir := '';
  FJavaFiles.Clear;
  for I := 0 to FJavaSourceFiles.Count - 1 do
  begin
    if FJavaSourceFiles[I].EndsWith('*.java') then
    begin
      for LFile in TDirectory.GetFiles(TPath.GetDirectoryName(FJavaSourceFiles[I]), '*.java', TSearchOption.soAllDirectories) do
        FJavaFiles.Add(LFile);
    end
    else if TFile.Exists(FJavaSourceFiles[I]) then
      FJavaFiles.Add(JavaSourceFiles[I]);
  end;
  if FJavaFiles.Count > 0 then
    LCommonFolder := TPath.GetDirectoryName(FJavaFiles[0]);
  if FJavaFiles.Count > 1 then
  begin
    for I := 1 to FJavaFiles.Count - 1 do
    begin
      LFolder := TPath.GetDirectoryName(FJavaFiles[I]);
      while not LFolder.IsEmpty and not LCommonFolder.StartsWith(LFolder) do
      begin
        LFolderFolder := TPath.GetDirectoryName(LFolder);
        if not LFolder.Equals(LFolderFolder) then
          LFolder := LFolderFolder
        else
          LFolder := '';
      end;
      if not LFolder.IsEmpty then
        LCommonFolder := LFolder;
    end;
  end;
  for I := FJavaFiles.Count - 1 downto 0 do
  begin
    if FJavaFiles[I].StartsWith(LCommonFolder) then
      FJavaFiles[I] := FJavaFiles[I].Substring(Length(LCommonFolder) + 1)
    else
      FJavaFiles.Delete(I);
  end;
  Result := FJavaFiles.Count > 0;
  if Result then
    FWorkingDir := LCommonFolder;
end;

procedure TCreateJarProcess.OutputExecuting;
begin
  DoOutput(Format(Babel.Tx(sExecutingCommand), [CommandLine]));
end;

function TCreateJarProcess.CheckRequirements: Boolean;
var
  LEncoding: TEncoding;
begin
  if GetJavaFiles then
  begin
    FWorkingPath := MakeWorkingPath;
    FJavaSourcesFileName := TPath.Combine(FWorkingPath, 'JavaSources.txt');
    // For some reason, on some systems, having a BOM makes javac fail??
    LEncoding := TUTF8Encoding.Create(False);
    try
      FJavaFiles.SaveToFile(FJavaSourcesFileName, LEncoding);
    finally
      LEncoding.Free;
    end;
    Result := True;
  end
  else
  begin
    DoOutput(Babel.Tx(sNoJavaFilesSpecified));
    Result := False;
  end;
end;

function TCreateJarProcess.Run: Boolean;
begin
  Result := False;
  FIsError := False;
  FStep := TJarProcessStep.None;
  if CheckRequirements then
    Result := BuildJava;
end;

function TCreateJarProcess.BuildJava: Boolean;
var
  LCmd, LParams, LClassesPath: string;
begin
  Result := False;
  FCurrentDir := TDirectory.GetCurrentDirectory;
  TDirectory.SetCurrentDirectory(FWorkingDir);
  FStep := TJarProcessStep.BuildJava;
  LClassesPath := TPath.Combine(FWorkingPath, 'classes');
  ForceDirectories(LClassesPath);
  if TDirectory.Exists(LClassesPath) then
  begin
    LCmd := Format(cJavaCompilerCommand, [FJDKPath]);
    LParams := Format(cJavaCompilerParams, [FAPILevelPath, FIncludedJars.CombineText(';', False), FWorkingPath, FTargetVersion, FSourceVersion,
      FJavaSourcesFileName]);
    CommandLine := LCmd + ' ' + LParams;
    DoOutput(Babel.Tx(sCompilingJavaSources));
    OutputExecuting;
    Result := InternalRun;
  end
  else
    DoOutput(Format(Babel.Tx(sUnableToCreateFolder), [LClassesPath]));
end;

procedure TCreateJarProcess.BuildJar;
var
  LCmd, LParams, LClassesOptions: string;
  LSubfolders: TArray<string>;
  I: Integer;
begin
  FStep := TJarProcessStep.BuildJar;
  LCmd := Format(cJarBuildCommand, [FJDKPath]);
  LSubfolders := TDirectory.GetDirectories(TPath.Combine(FWorkingPath, 'classes'), '*.*', TSearchOption.soTopDirectoryOnly);
  if Length(LSubfolders) > 0 then
  begin
    for I := 0 to Length(LSubfolders) - 1 do
      LSubfolders[I] := Format(cJarClassDirOptionParam, [FWorkingPath, TPath.GetFileName(LSubFolders[I])]);
    LClassesOptions := string.Join(' ', LSubfolders);
    LParams := Format(cJarBuildParams, [FJarFilename, LClassesOptions]);
    CommandLine := LCmd + ' ' + LParams;
    DoOutput(Format(Babel.Tx(sBuildingJar), [TPath.GetFileName(FJarFilename)]));
    OutputExecuting;
    InternalRun;
  end
  else
    DoOutput(Format(Babel.Tx(sUnableToDetermineSubfolders), [FWorkingPath]));
end;

procedure TCreateJarProcess.DexJar;
var
  LCmd, LParams: string;
begin
  FStep := TJarProcessStep.DexJar;
  LCmd := Format(cDexCommand, [FDexPath]);
  LParams := Format(cDexParams, [TPath.ChangeExtension(FJarFilename, '.dex.jar'), FJarFilename]);
  DoOutput(Format('Dexing %s..', [TPath.GetFileName(FJarFilename)]));
  Process.CommandLine := LCmd + ' ' + LParams;
  InternalRun;
end;

procedure TCreateJarProcess.DoTerminated(const AExitCode: Cardinal);
begin
  FIsError := FIsError or (AExitCode <> 0);
  case FStep of
    TJarProcessStep.BuildJava:
    begin
      TDirectory.SetCurrentDirectory(FCurrentDir);
      if FIsError then
      begin
        DoOutput(Format(Babel.Tx(sCompileFailedWithExitCode), [AExitCode]));
        Cleanup;
      end
      else
        BuildJar;
    end;
    TJarProcessStep.BuildJar:
    begin
      if not FIsError then
      begin
        DoOutput(Format(Babel.Tx(sSuccessfullyBuiltJar), [FJarFilename]));
        if FShouldDex then
          DexJar
        else
          Cleanup;
      end
      else
      begin
        DoOutput(Format(Babel.Tx(sBuildFailedWithExitCode), [AExitCode]));
        Cleanup;
      end;
      inherited;
    end;
    TJarProcessStep.DexJar:
    begin
      if not FIsError then
        DoOutput(Format(Babel.Tx(sSuccessfullyDexedJar), [FJarFilename]))
      else
        DoOutput(Format(Babel.Tx(sDexingFailedWithExitCode), [AExitCode]));
      Cleanup;
      inherited;
    end;
  end;
end;

procedure TCreateJarProcess.Cleanup;
var
  LWorkingFilesMessage: string;
begin
  LWorkingFilesMessage := '';
  if not FShouldRetainWorkingFiles then
    TDirectory.Delete(FWorkingPath, True)
  else
    LWorkingFilesMessage := Format(Babel.Tx(sLeftWorkingFilesIntact), [FWorkingPath]);
  if FIsError then
    DoOutput('**** ' + Babel.Tx(sProcessFailed) + ' ****')
  else
    DoOutput('**** ' + Babel.Tx(sProcessComplete) + ' ****');
  if not LWorkingFilesMessage.IsEmpty then
    DoOutput(LWorkingFilesMessage);
end;

end.
