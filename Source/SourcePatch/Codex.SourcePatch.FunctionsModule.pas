unit Codex.SourcePatch.FunctionsModule;

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
  System.SysUtils, System.Classes, System.Win.Registry,
  Vcl.Dialogs,
  DW.Environment.RADStudio, DW.RunProcess.Win;

type
  TPatchProcessKind = (Diff, Patch);

  TPatchInfo = record
    IsFromEditor: Boolean;
    PatchFileName: string;
    SourceFileName: string;
  end;

  TSourcePatchFunctionsModule = class(TDataModule)
    SourceOpenDialog: TFileOpenDialog;
    SourceCopyFolderOpenDialog: TFileOpenDialog;
    PatchOpenDialog: TFileOpenDialog;
    PatchSaveDialog: TFileSaveDialog;
  private
    FEnvironment: TRSEnvironment;
    FPatchInfo: TPatchInfo;
    FProcess: TRunProcess;
    FProcessKind: TPatchProcessKind;
    FRegistry: TRegistry;
    procedure ExecutePatch;
    function GetCommandCaption: string;
    function GetCurrentDelphiVersion: string;
    function GetPatchFileName(const APatchFilesPath: string; const AFileName: string = ''; const AFileMask: string = ''): string;
    function GetSourceFileNameFromPatchFileName(const APatchFileName: string): string;
    function GetSourcePatchFileName(const AFileName: string): string;
    function GetSourceCopyPath(const AUseActiveProject: Boolean = False): string;
    function GetGitPath: string;
    function InternalCopySourceFile(const AFileName: string; const AUseActiveProject: Boolean = False): string;
    procedure InternalDiffFile(const AFileName: string);
    procedure LoadEditorFile(const AFileName: string; const ACloseCurrent: Boolean);
    procedure ProcessOutputHandler(Sender: TObject; const AOutput: string);
    procedure ProcessTerminatedHandler(Sender: TObject; const AExitCode: Cardinal);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CanApplyPatch(const AFileName: string): Boolean;
    function CanCreatePatch(const AFileName: string): Boolean;
    procedure CopySourceFiles;
    procedure CopySourceEditorFile(const AFileName: string);
    procedure CopySourceEditorFileToProject;
    procedure DiffEditorFile(const AFileName: string);
    procedure DiffFile;
    function GetGitEXE: string;
    function GetPatchEXE: string;
    function GetSourceFolder: string;
    function GetSourceFileName(const AFileName: string): string;
    function IsSourceFile(const AFileName: string): Boolean;
    procedure PatchEditorFile(const AFileName: string);
    procedure PatchSourceFile(const AUseActiveProject: Boolean = False);
  end;

var
  SourcePatchFunctionsModule: TSourcePatchFunctionsModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  System.IOUtils,
  Winapi.Windows,
  ToolsAPI,
  Vcl.Controls,
  DW.IOUtils.Helpers.Win, DW.OTA.Helpers, DW.IOUtils.Helpers, DW.OS.Win,
  Codex.Config, Codex.Consts, Codex.Core, Codex.Consts.Text;

const
  cGitRegKey = 'SOFTWARE\GitForWindows';
  cGitRegNameInstallPath = 'InstallPath';
  cGitPatchCommandTemplate = '"%s" "%s" "%s"';
  cGitDiffCommandTemplate = '"%s" diff --output "%s" "%s" "%s"';

resourcestring
  sAllPatches = 'All patches';
  sCouldNotOpenFile = 'Could not open %s';
  sDiffFailed = 'Failed to create patch from %s and %s, exit code: %d';
  sDiffSuccessful = 'Successfully created patch %s from %s and %s';
  sPatchesForFileWithMask = 'Patches for %s (%s)';
  sPatchFailed = 'Failed to patch %s using %s, exit code: %d';
  sPatchSuccessful = 'Successfully patched %s using %s';
  sXFilesCopiedToFolder = '%d file(s) copied to %s';

{ TSourcePatchResources }

constructor TSourcePatchFunctionsModule.Create(AOwner: TComponent);
begin
  inherited;
  FEnvironment := TRSEnvironment.Create;
  FRegistry := TRegistry.Create(KEY_READ or KEY_WOW64_64KEY);
  FRegistry.RootKey := HKEY_LOCAL_MACHINE;
  FProcess := TRunProcess.Create;
  FProcess.OnProcessOutput := ProcessOutputHandler;
  FProcess.OnProcessTerminated := ProcessTerminatedHandler;
end;

destructor TSourcePatchFunctionsModule.Destroy;
begin
  FEnvironment.Free;
  FRegistry.Free;
  FProcess.Free;
  inherited;
end;

function TSourcePatchFunctionsModule.GetSourceFolder: string;
begin
  Result := TPath.Combine(TPlatformOS.GetEnvironmentVariable(cEnvVarBDS), 'source');
end;

procedure TSourcePatchFunctionsModule.InternalDiffFile(const AFileName: string);
begin
  PatchSaveDialog.DefaultFolder := Config.SourcePatch.PatchFilesPath;
  PatchSaveDialog.FileName := Format('%s.%s.patch', [TPath.GetFileNameWithoutExtension(TPath.GetFileName(AFileName)), GetCurrentDelphiVersion]);
  if PatchSaveDialog.Execute then
  begin
    FPatchInfo.PatchFileName := AFileName;
    FProcessKind := TPatchProcessKind.Diff;
    FProcess.CommandLine := Format(cGitDiffCommandTemplate, [GetGitEXE, PatchSaveDialog.FileName, FPatchInfo.SourceFileName, AFileName]);
    FProcess.Run;
  end;
end;

procedure TSourcePatchFunctionsModule.DiffEditorFile(const AFileName: string);
begin
  if IsSourceFile(AFileName) then
  begin
    // AFileName is an ORIGINAL file from the current Delphi source, so it needs to be copied first
    FPatchInfo.SourceFileName := InternalCopySourceFile(AFileName);
    if not FPatchInfo.SourceFileName.IsEmpty then
      InternalDiffFile(AFileName);
  end
  else
  begin
    // AFileName is a COPY of a file from the current Delphi source
    FPatchInfo.SourceFileName := GetSourceFileName(AFileName);
    InternalDiffFile(AFileName);
  end;
end;

procedure TSourcePatchFunctionsModule.DiffFile;
var
  LSourceCopyFileName, LSourceFileName: string;
  LOptions: TFileDialogOptions;
begin
  LSourceCopyFileName := '';
  LSourceFileName := '';
  SourceOpenDialog.DefaultFolder := GetSourceCopyPath;
  LOptions := SourceOpenDialog.Options;
  try
    SourceOpenDialog.Options := SourceOpenDialog.Options - [TFileDialogOption.fdoAllowMultiSelect];
    if SourceOpenDialog.Execute then
    begin
      LSourceCopyFileName := SourceOpenDialog.FileName;
      LSourceFileName := GetSourceFileName(LSourceCopyFileName);
      if LSourceFileName.IsEmpty then
      begin
        SourceOpenDialog.FileName := TPath.GetFileName(LSourceCopyFileName);
        SourceOpenDialog.DefaultFolder := GetSourceFolder;
        if SourceOpenDialog.Execute then
          LSourceFileName := SourceOpenDialog.FileName;
      end;
    end;
  finally
    SourceOpenDialog.Options := LOptions;
  end;
  if not LSourceCopyFileName.IsEmpty and not LSourceFileName.IsEmpty then
  begin
    FPatchInfo.IsFromEditor := False;
    FPatchInfo.SourceFileName := LSourceFileName;
    InternalDiffFile(LSourceCopyFileName);
  end;
end;

procedure TSourcePatchFunctionsModule.ProcessOutputHandler(Sender: TObject; const AOutput: string);
begin
  // Might need to capture any errors
end;

function TSourcePatchFunctionsModule.GetCommandCaption: string;
begin
  Result := Format(Babel.Tx(sCommandLine), [FProcess.CommandLine]);
end;

procedure TSourcePatchFunctionsModule.ProcessTerminatedHandler(Sender: TObject; const AExitCode: Cardinal);
var
  LOutput: string;
begin
  case FProcessKind of
    TPatchProcessKind.Diff:
    begin
      // Created a patch - exit code of 1 is success?? :-)
      if AExitCode = 1 then
        TOTAHelper.AddTitleMessage(Format(Babel.Tx(sDiffSuccessful), [PatchSaveDialog.FileName, FPatchInfo.SourceFileName, FPatchInfo.PatchFileName]), 'Codex')
      else
      begin
        TOTAHelper.AddTitleMessage(Format(Babel.Tx(sDiffFailed), [FPatchInfo.SourceFileName, FPatchInfo.PatchFileName, AExitCode]), 'Codex');
        TOTAHelper.AddTitleMessage(GetCommandCaption, 'Codex');
        for LOutput in FProcess.CapturedOutput do
          TOTAHelper.AddTitleMessage(LOutput, 'Codex');
      end;
    end;
    TPatchProcessKind.Patch:
    begin
      if AExitCode = 0 then
      begin
        // Applied patch file
        TOTAHelper.AddTitleMessage(Format(Babel.Tx(sPatchSuccessful), [FPatchInfo.SourceFileName, FPatchInfo.PatchFileName]), 'Codex');
        LoadEditorFile(FPatchInfo.SourceFileName, FPatchInfo.IsFromEditor);
      end
      else
      begin
        TOTAHelper.AddTitleMessage(Format(Babel.Tx(sPatchFailed), [FPatchInfo.SourceFileName, FPatchInfo.PatchFileName, AExitCode]), 'Codex');
        TOTAHelper.AddTitleMessage(GetCommandCaption, 'Codex');
        for LOutput in FProcess.CapturedOutput do
          TOTAHelper.AddTitleMessage(LOutput, 'Codex');
      end;
    end;
  end;
end;

function TSourcePatchFunctionsModule.GetGitEXE: string;
var
  LPath: string;
begin
  LPath := GetGitPath;
  if TDirectoryHelper.Exists(LPath) then
    Result := TPath.Combine(LPath, 'bin\git.exe');
end;

function TSourcePatchFunctionsModule.GetGitPath: string;
begin
  Result := '';
  if FRegistry.OpenKey(cGitRegKey, False) then
  try
    Result := FRegistry.ReadString(cGitRegNameInstallPath);
  finally
    FRegistry.CloseKey;
  end;
end;

function TSourcePatchFunctionsModule.GetPatchEXE: string;
var
  LPath: string;
begin
  LPath := GetGitPath;
  if TDirectoryHelper.Exists(LPath) then
    Result := TPath.Combine(LPath, 'usr\bin\patch.exe');
end;

function TSourcePatchFunctionsModule.GetCurrentDelphiVersion: string;
begin
  Result := FEnvironment.GetVersionNumber(TPlatformOS.GetEnvironmentVariable('ProductVersion'));
end;

function TSourcePatchFunctionsModule.GetSourceCopyPath(const AUseActiveProject: Boolean = False): string;
var
  LProjectPath: string;
begin
  LProjectPath := TOTAHelper.GetActiveProjectPath;
  if AUseActiveProject and TDirectoryHelper.Exists(LProjectPath) then
    Result := LProjectPath
  else
  begin
    Result := Config.SourcePatch.SourceCopyPath;
    if Config.SourcePatch.IsSourceCopyProjectRelative then
    begin
      if not LProjectPath.IsEmpty then
      begin
        Result := ExpandPath(LProjectPath, Result);
        if not ForceDirectories(Result) then
          Result := '';
      end
      else
        Result := '';
    end;
  end;
end;

function TSourcePatchFunctionsModule.GetSourceFileName(const AFileName: string): string;
var
  LFiles: TArray<string>;
begin
  Result := '';
  if not AFileName.StartsWith(GetSourceFolder, True) then
  begin
    LFiles := TDirectory.GetFiles(GetSourceFolder, TPath.GetFileName(AFileName), TSearchOption.soAllDirectories);
    if Length(LFiles) > 0 then
      Result := LFiles[0];
  end;
end;

function TSourcePatchFunctionsModule.GetSourceFileNameFromPatchFileName(const APatchFileName: string): string;
var
  LPatchFileName, LSourceFileName, LSourceFileNameStart: string;
begin
  Result := '';
  LPatchFileName := TPath.GetFileName(APatchFileName);
  for LSourceFileName in TDirectory.GetFiles(GetSourceFolder, '*.pas', TSearchOption.soAllDirectories) do
  begin
    LSourceFileNameStart := TPath.GetFileNameWithoutExtension(TPath.GetFileName(LSourceFileName)) + '.';
    if LPatchFileName.StartsWith(LSourceFileNameStart, True) then
    begin
      Result := LSourceFileName;
      Break;
    end;
  end;
end;

// Patch files will have the name:  sssssss.xx.y.z.patch  e.g. FMX.Canvas.D2D.10.4.2.patch or even FMX.Canvas.D2D.RSP-17030.10.4.2.patch
// As long as they end in the version number and .patch

function TSourcePatchFunctionsModule.GetPatchFileName(const APatchFilesPath: string; const AFileName: string = ''; const AFileMask: string = ''): string;
var
  LItem: TFileTypeItem;
begin
  PatchOpenDialog.DefaultFolder := APatchFilesPath;
  PatchOpenDialog.FileTypes.Clear;
  if not AFileName.IsEmpty then
  begin
    LItem := PatchOpenDialog.FileTypes.Add;
    LItem.DisplayName := Format(Babel.Tx(sPatchesForFileWithMask), [AFileName, AFileMask]);
    LItem.FileMask := AFileMask;
  end;
  LItem := PatchOpenDialog.FileTypes.Add;
  LItem.DisplayName := Babel.Tx(sAllPatches) + ' (*.patch)';
  LItem.FileMask := '*.patch';
  if PatchOpenDialog.Execute then
    Result := PatchOpenDialog.FileName;
end;

function TSourcePatchFunctionsModule.GetSourcePatchFileName(const AFileName: string): string;
var
  LPatchFilesPath, LSourceFileName, LFileMask, { LExactMatchFileName, } LDelphiVersion, LSourceFileNameNoExt: string;
  LPatchFiles: TArray<string>;
begin
  Result := '';
  LSourceFileName := TPath.GetFileName(AFileName);
  LSourceFileNameNoExt := TPath.GetFileNameWithoutExtension(LSourceFileName);
  LDelphiVersion := GetCurrentDelphiVersion;
  LFileMask := Format('%s*%s.patch', [LSourceFileNameNoExt, LDelphiVersion]);
  // LExactMatchFileName := Format('%s.%s.patch', [LSourceFileNameNoExt, LDelphiVersion]);
  LPatchFilesPath := Config.SourcePatch.PatchFilesPath;
  if TDirectoryHelper.Exists(LPatchFilesPath) then
  begin
    LPatchFiles := TDirectory.GetFiles(LPatchFilesPath, LFileMask, TSearchOption.soTopDirectoryOnly);
    // If more than one is found, the dialog will be presented
    if Length(LPatchFiles) = 1 then
      Result := LPatchFiles[0];
  end
  else
    LPatchFilesPath := '';
  if Result.IsEmpty or not TDirectoryHelper.Exists(LPatchFilesPath) then
    Result := GetPatchFileName(LPatchFilesPath, LSourceFileName, LFileMask);
end;

procedure TSourcePatchFunctionsModule.PatchSourceFile(const AUseActiveProject: Boolean = False);
var
  LPatchFileName, LSourceFileName, LCopyFileName: string;
  LOptions: TFileDialogOptions;
begin
  LPatchFileName := GetPatchFileName(Config.SourcePatch.PatchFilesPath);
  if not LPatchFileName.IsEmpty then
  begin
    LSourceFileName := GetSourceFileNameFromPatchFileName(LPatchFileName);
    if LSourceFileName.IsEmpty then
    begin
      // Could not find a matching source file, so prompt for selection
      SourceOpenDialog.DefaultFolder := GetSourceFolder;
      LOptions := SourceOpenDialog.Options;
      try
        SourceOpenDialog.Options := SourceOpenDialog.Options - [TFileDialogOption.fdoAllowMultiSelect];
        if SourceOpenDialog.Execute then
          LSourceFileName := SourceOpenDialog.FileName;
      finally
        SourceOpenDialog.Options := LOptions;
      end;
    end;
    if not LSourceFileName.IsEmpty then
    begin
      LCopyFileName := InternalCopySourceFile(LSourceFileName, AUseActiveProject);
      if not LCopyFileName.IsEmpty then
      begin
        FPatchInfo.IsFromEditor := False;
        FPatchInfo.PatchFileName := LPatchFileName;
        FPatchInfo.SourceFileName := LCopyFileName;
        ExecutePatch;
      end;
    end;
  end;
end;

function TSourcePatchFunctionsModule.InternalCopySourceFile(const AFileName: string; const AUseActiveProject: Boolean = False): string;
var
  LSourceCopyPath: string;
begin
  Result := '';
  LSourceCopyPath := GetSourceCopyPath;
  // If always prompt, or path is invalid, use the folder dialog
  if Config.SourcePatch.AlwaysPromptSourceCopyPath or not TDirectoryHelper.Exists(LSourceCopyPath) then
  begin
    if TDirectoryHelper.Exists(LSourceCopyPath) then
      SourceCopyFolderOpenDialog.DefaultFolder := LSourceCopyPath;
    if SourceCopyFolderOpenDialog.Execute then
      LSourceCopyPath := SourceCopyFolderOpenDialog.FileName
    else
      LSourceCopyPath := '';
  end;
  // If the user cancels, the folder will be blank, otherwise all good to go
  if TDirectoryHelper.Exists(LSourceCopyPath) and TPlatformPath.CopyFiles([AFileName], LSourceCopyPath) then
    Result := TPath.Combine(LSourceCopyPath, TPath.GetFileName(AFileName));
end;

function TSourcePatchFunctionsModule.IsSourceFile(const AFileName: string): Boolean;
begin
  Result := TFile.Exists(AFileName) and TPath.GetDirectoryName(AFileName).StartsWith(GetSourceFolder, True);
end;

procedure TSourcePatchFunctionsModule.ExecutePatch;
begin
  FProcessKind := TPatchProcessKind.Patch;
  FProcess.CommandLine := Format(cGitPatchCommandTemplate, [GetPatchEXE, FPatchInfo.SourceFileName, FPatchInfo.PatchFileName]);
  FProcess.Run;
end;

procedure TSourcePatchFunctionsModule.PatchEditorFile(const AFileName: string);
var
  LPatchFileName, LCopyFileName: string;
begin
  if IsSourceFile(AFileName) then
  begin
    // AFileName is an ORIGINAL file from the current Delphi source, so it needs to be copied first
    LPatchFileName := GetSourcePatchFileName(AFileName);
    if not LPatchFileName.IsEmpty then
    begin
      LCopyFileName := InternalCopySourceFile(AFileName);
      if not LCopyFileName.IsEmpty then
      begin
        FPatchInfo.IsFromEditor := True;
        FPatchInfo.PatchFileName := LPatchFileName;
        FPatchInfo.SourceFileName := LCopyFileName;
        ExecutePatch;
      end;
    end;
  end
  else
  begin
    // AFileName is a COPY of a file from the current Delphi source
    LPatchFileName := GetSourcePatchFileName(AFileName);
    if not LPatchFileName.IsEmpty then
    begin
      FPatchInfo.IsFromEditor := True;
      FPatchInfo.PatchFileName := LPatchFileName;
      FPatchInfo.SourceFileName := AFileName;
      ExecutePatch;
    end;
  end;
end;

procedure TSourcePatchFunctionsModule.LoadEditorFile(const AFileName: string; const ACloseCurrent: Boolean);
begin
  // TODO: Make closing the original file an option?
  if ACloseCurrent then
    TOTAHelper.CloseCurrentModule;
  // TODO: Restore whatever the selected line of the file was in the editor
  if not TOTAHelper.OpenFile(AFileName) then
    TOTAHelper.AddTitleMessage(Format(Babel.Tx(sCouldNotOpenFile), [AFileName]), 'Codex');
end;

function TSourcePatchFunctionsModule.CanApplyPatch(const AFileName: string): Boolean;
begin
  // Needs patch, and is either a source file or matches a source file
  // In the case where it is a source file, the file will be copied first (user prompted if necessary)
  Result := TFile.Exists(GetPatchEXE) and (IsSourceFile(AFileName) or not GetSourceFileName(AFileName).IsEmpty);
end;

function TSourcePatchFunctionsModule.CanCreatePatch(const AFileName: string): Boolean;
begin
  // Needs git diff, and is not an actual source file, but matches a source file
  Result := TFile.Exists(GetGitEXE) and not IsSourceFile(AFileName) and not GetSourceFileName(AFileName).IsEmpty;
end;

procedure TSourcePatchFunctionsModule.CopySourceEditorFile(const AFileName: string);
var
  LCopyFileName: string;
begin
  LCopyFileName := InternalCopySourceFile(AFileName);
  if not LCopyFileName.IsEmpty then
    LoadEditorFile(LCopyFileName, True);
end;

procedure TSourcePatchFunctionsModule.CopySourceEditorFileToProject;
var
  LProjectPath, LCopyFileName: string;
begin
  LProjectPath := TOTAHelper.GetActiveProjectPath;
  if not LProjectPath.IsEmpty then
  begin
    LCopyFileName := TPath.Combine(LProjectPath, TPath.GetFileName(TOTAHelper.GetActiveSourceEditorFileName));
    if not TFile.Exists(LCopyFileName) or (MessageDlg(sConfirmOverwiteFile, TMsgDlgType.mtConfirmation, mbYesNo, 0) = mrYes) then
    begin
      TFile.Copy(TOTAHelper.GetActiveSourceEditorFileName, LCopyFileName, True);
      LoadEditorFile(LCopyFileName, True);
    end;
  end;
end;

procedure TSourcePatchFunctionsModule.CopySourceFiles;
var
  LSourceCopyPath, LSourceFileName, LSourceCopyFileName: string;
  LOptions: TFileDialogOptions;
begin
  SourceOpenDialog.DefaultFolder := GetSourceFolder;
  LOptions := SourceOpenDialog.Options;
  try
    SourceOpenDialog.Options := SourceOpenDialog.Options + [TFileDialogOption.fdoAllowMultiSelect];
    if SourceOpenDialog.Execute then
    begin
      LSourceCopyPath := GetSourceCopyPath;
      // If always prompt, or path is invalid, use the folder dialog
      if Config.SourcePatch.AlwaysPromptSourceCopyPath or not TDirectoryHelper.Exists(LSourceCopyPath) then
      begin
        if TDirectoryHelper.Exists(LSourceCopyPath) then
          SourceCopyFolderOpenDialog.DefaultFolder := LSourceCopyPath;
        if SourceCopyFolderOpenDialog.Execute then
          LSourceCopyPath := SourceCopyFolderOpenDialog.FileName;
      end;
      if TDirectoryHelper.Exists(LSourceCopyPath) and TPlatformPath.CopyFiles(SourceOpenDialog.Files.ToStringArray, LSourceCopyPath) then
      begin
        if Config.SourcePatch.ShouldOpenSourceFiles then
        begin
          for LSourceFileName in SourceOpenDialog.Files.ToStringArray do
          begin
            LSourceCopyFileName := TPath.Combine(LSourceCopyPath, TPath.GetFileName(LSourceFileName));
            if TFile.Exists(LSourceCopyFileName) then
              TOTAHelper.OpenFile(LSourceCopyFileName);
          end;
        end;
        TOTAHelper.AddTitleMessage(Format(Babel.Tx(sXFilesCopiedToFolder), [SourceOpenDialog.Files.Count, LSourceCopyPath]), 'Codex');
      end;
    end;
  finally
    SourceOpenDialog.Options := LOptions;
  end;
end;

end.
