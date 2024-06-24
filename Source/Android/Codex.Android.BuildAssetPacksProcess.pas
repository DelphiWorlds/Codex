unit Codex.Android.BuildAssetPacksProcess;

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
  DW.RunProcess.Win,
  Codex.Android.AssetPackTypes;

type
  TBuildAssetPackStage = (None, CreateLinkedFile);

  TAssetPackResult = record
    AssetPackFileName: string;
    ExitCode: Cardinal;
    function IsSuccess: Boolean;
  end;

  TAssetPackResults = TArray<TAssetPackResult>;

  TBuildAssetPacksResultsEvent = procedure(Sender: TObject; const AssetPackResults: TAssetPackResults) of object;
  TBuildAssetPacksOutputEvent = procedure(Sender: TObject; const Output: string) of object;

  TBuildAssetPacksProcess = class(TObject)
  private
    FAAPT2ExePath: string;
    FAPILevelPath: string;
    FAssetPackPaths: TArray<string>;
    FAssetPackResults: TAssetPackResults;
    FAssetPackRoot: string;
    FAssetPacksPath: string;
    FJarFileName: string;
    FLinkedFileName: string;
    FManifest: TAssetPackManifest;
    FRunProcess: TRunProcess;
    FStage: TBuildAssetPackStage;
    FOnOutput: TBuildAssetPacksOutputEvent;
    FOnResults: TBuildAssetPacksResultsEvent;
    procedure AssetPackComplete(const AAssetPackResult: TAssetPackResult);
    procedure BuildAssetPack;
    procedure CheckFilePath(const AFileName: string; var ASuccess: Boolean);
    function CheckFilePaths: Boolean;
    procedure CreateAssetPackZip;
    procedure DoResults;
    procedure DoOutput(const AOutput: string);
    procedure RunProcessTerminatedHandler(Sender: TObject; const AExitCode: Cardinal);
    procedure RunProcessOutputHandler(Sender: TObject; const AOutput: string);
    function UpdateAssetPackPaths(const AAssetPacksPath: string): Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    ///   Starts the asset pack build process for the packs in the subfolders of AAssetPacksPath. Returns True if the start requirements are met
    ///   Use the OnAssetPackResult event to determine success
    /// </summary>
    /// <remarks>
    ///   This method expects Asset Packs to use the following structure:
    ///     <root>                    (This is the path passed to the Build method)
    ///       AndroidManifest.xml     (See comments below regarding how this file should look)
    ///       \pack
    ///         \assets
    ///           <assetfiles>        (Can be organized into subfolders)
    ///   The structure is to help simplify the build process
    /// </remarks>
    function Build(const AAssetPacksPath: string): Boolean;
    property AAPT2ExePath: string read FAAPT2ExePath write FAAPT2ExePath;
    property APILevelPath: string read FAPILevelPath write FAPILevelPath;
    property OnOutput: TBuildAssetPacksOutputEvent read FOnOutput write FOnOutput;
    property OnResults: TBuildAssetPacksResultsEvent read FOnResults write FOnResults;
  end;

implementation

uses
  DW.OSLog,
  System.Zip, System.IOUtils, System.SysUtils,
  DW.IOUtils.Helpers,
  Codex.Core, Codex.Consts.Text;

const
  cAAPT2LinkCommandLine = '"%s" link --proto-format --auto-add-overlay -o "%s" -I "%s" --manifest "%s" -A "%s"';
  cJavaExeFileName = 'java.exe';
  cAndroidManifestFileName = 'AndroidManifest.xml';
  cAndroidJarFileName = 'android.jar';
  cLinkedWorkingFileName = 'working.zip';
  cPackFolder = 'pack';
  cPackAssetsFolder = 'pack\assets';
  cPackManifestFolder = 'pack\manifest';

{ TAssetPackResult }

function TAssetPackResult.IsSuccess: Boolean;
begin
  Result := ExitCode = 0;
end;

{ TBuildAssetPacksProcess }

constructor TBuildAssetPacksProcess.Create;
begin
  inherited;
  FManifest := TAssetPackManifest.Create;
  FRunProcess := TRunProcess.Create;
  FRunProcess.OnProcessTerminated := RunProcessTerminatedHandler;
  FRunProcess.OnProcessOutput := RunProcessOutputHandler;
end;

destructor TBuildAssetPacksProcess.Destroy;
begin
  FManifest.Free;
  FRunProcess.Free;
  inherited;
end;

procedure TBuildAssetPacksProcess.DoResults;
begin
  if Assigned(FOnResults) then
    FOnResults(Self, FAssetPackResults);
end;

procedure TBuildAssetPacksProcess.DoOutput(const AOutput: string);
begin
  if Assigned(FOnOutput) then
    FOnOutput(Self, AOutput);
end;

function TBuildAssetPacksProcess.UpdateAssetPackPaths(const AAssetPacksPath: string): Boolean;
var
  LAssetPackPath, LManifestFileName, LAssetsFolder: string;
  LPaths: TArray<string>;
begin
  FAssetPackPaths := [];
  LPaths := TDirectory.GetDirectories(AAssetPacksPath, '*', TSearchOption.soTopDirectoryOnly);
  for LAssetPackPath in LPaths do
  begin
    LAssetsFolder := TPath.Combine(LAssetPackPath, cPackAssetsFolder);
    if TDirectoryHelper.Exists(LAssetsFolder) and not TDirectory.IsEmpty(LAssetsFolder) then
    begin
      FManifest.Reset;
      LManifestFileName := TPath.Combine(LAssetPackPath, cAndroidManifestFileName);
      if TFile.Exists(LManifestFileName) and FManifest.LoadFromFile(LManifestFileName) then
        FAssetPackPaths := FAssetPackPaths + [LAssetPackPath]
      else
        DoOutput(Format(Babel.Tx(sManifestMissingOrInvalid), [LAssetPackPath]));
    end
    else
      DoOutput(Format(Babel.Tx(sAssetsFolderMissingOrEmpty), [LAssetPackPath]));
  end;
  Result := Length(FAssetPackPaths) > 0;
end;

procedure TBuildAssetPacksProcess.CheckFilePath(const AFileName: string; var ASuccess: Boolean);
begin
  if not TFile.Exists(AFileName) then
  begin
    ASuccess := False;
    DoOutput(Format(Babel.Tx(sFileNoExist), [AFileName]));
  end;
end;

function TBuildAssetPacksProcess.CheckFilePaths: Boolean;
begin
  Result := True;
  FJarFileName := TPath.Combine(FAPILevelPath, cAndroidJarFileName);
  CheckFilePath(FJarFileName, Result);
  CheckFilePath(FAAPT2ExePath, Result);
end;

function TBuildAssetPacksProcess.Build(const AAssetPacksPath: string): Boolean;
begin
  Result := False;
  FAssetPacksPath := AAssetPacksPath;
  FAssetPackResults := [];
  if CheckFilePaths then
  begin
    if UpdateAssetPackPaths(AAssetPacksPath) then
    begin
      Result := True;
      BuildAssetPack;
    end
    else
      DoOutput(Format(Babel.Tx(sNoValidAssetPacksFound), [AAssetPacksPath]));
  end;
end;

procedure TBuildAssetPacksProcess.BuildAssetPack;
var
  LAssetsFolder, LManifestFileName: string;
begin
  FAssetPackRoot := FAssetPackPaths[0];
  Delete(FAssetPackPaths, 0, 1);
  FLinkedFileName := TPath.Combine(FAssetPackRoot, cLinkedWorkingFileName);
  LAssetsFolder := TPath.Combine(FAssetPackRoot, cPackAssetsFolder);
  LManifestFileName := TPath.Combine(FAssetPackRoot, cAndroidManifestFileName);
  FStage := TBuildAssetPackStage.CreateLinkedFile;
  FRunProcess.CommandLine := Format(cAAPT2LinkCommandLine, [FAAPT2ExePath, FLinkedFileName, FJarFileName, LManifestFileName, LAssetsFolder]);
  TOSLog.d('Build Asset Pack: ' + FRunProcess.CommandLine);
  FRunProcess.Run;
end;

procedure TBuildAssetPacksProcess.RunProcessTerminatedHandler(Sender: TObject; const AExitCode: Cardinal);
var
  LResult: TAssetPackResult;
begin
  LResult.ExitCode := AExitCode;
  case FStage of
    TBuildAssetPackStage.CreateLinkedFile:
    begin
      if AExitCode = 0 then
        CreateAssetPackZip
      else
        AssetPackComplete(LResult);
    end;
  end;
end;

procedure TBuildAssetPacksProcess.CreateAssetPackZip;
var
  LZip: TZipFile;
  LResult: TAssetPackResult;
begin
  FStage := TBuildAssetPackStage.None;
  // Extract manifest into pack manifest folder
  LZip := TZipFile.Create;
  try
    LZip.Open(FLinkedFileName, TZipMode.zmRead);
    LZip.Extract(cAndroidManifestFileName, TPath.Combine(FAssetPackRoot, cPackManifestFolder));
  finally
    LZip.Free;
  end;
  // Create asset pack zip file
  LResult.AssetPackFileName := TPath.Combine(FAssetPacksPath, TPath.ChangeExtension(TPath.GetFileName(FAssetPackRoot).ToLower, '.zip'));
  TZipFile.ZipDirectoryContents(LResult.AssetPackFileName, TPath.Combine(FAssetPackRoot, cPackFolder));
  TFile.Delete(FLinkedFileName);
  LResult.ExitCode := 0;
  AssetPackComplete(LResult);
end;

procedure TBuildAssetPacksProcess.AssetPackComplete(const AAssetPackResult: TAssetPackResult);
begin
  FAssetPackResults := FAssetPackResults + [AAssetPackResult];
  if Length(FAssetPackPaths) > 0 then
    BuildAssetPack
  else
    DoResults;
end;

procedure TBuildAssetPacksProcess.RunProcessOutputHandler(Sender: TObject; const AOutput: string);
begin
  DoOutput(AOutput);
end;

end.
