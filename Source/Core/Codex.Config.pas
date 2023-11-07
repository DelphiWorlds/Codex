unit Codex.Config;

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
  Codex.Types;

type
  TAIItem = record
    AI: string;
    APIKey: string;
  end;

  TAIItems = TArray<TAIItem>;

  TAIConfig = record
    NeedsHistory: Boolean;
    Items: TAIItems;
  end;

  TADBConnectMRU = TArray<string>;

  TADBConnectConfig = record
    DismissOnSuccess: Boolean;
    IP: string;
    MRU: TADBConnectMRU;
    Port: string;
    SelectAndroidOnSuccess: Boolean;
    procedure AddMRU(const AIP, APort: string);
  end;

  TJava2OPConfig = record
    DefaultClassPathFolder: string;
    DefaultJarFolder: string;
    DefaultSourceFolder: string;
  end;

  TKeyStoreItem = record
    KeyStoreFileName: string;
    KeyStorePass: string;
    KeyAlias: string;
    KeyAliasPass: string;
  end;

  TKeyStoreItems = TArray<TKeyStoreItem>;

  TAndroidConfig = record
  private
    function FindKeyStoreItem(const AKeyStoreFileName, AKeyAlias: string; out AKeyStoreItem: TKeyStoreItem): Boolean;
    function IndexOfKeyStoreItem(const AKeyStoreFileName, AKeyAlias: string): Integer;
  public
    ADBConnect: TADBConnectConfig;
    DefaultAABFileName: string;
    DefaultAndroidPackageFolder: string;
    DefaultKeyStoreFileName: string;
    DefaultKeyStoreAlias: string;
    GradlePath: string;
    JarFolder: string;
    JarOutputFolder: string;
    JavaFolder: string;
    Java2OP: TJava2OPConfig;
    KeyStoreItems: TKeyStoreItems;
    ResourcesFolder: string;
    function FindKeyStoreItemDefault(out AKeyStoreItem: TKeyStoreItem): Boolean;
    function GetKeyStoreItem(const AKeyStoreFileName, AKeyAlias: string): TKeyStoreItem;
    procedure SetKeyStoreItem(const AKeyStoreFileName, AKeyStorePass, AKeyAlias, AKeyAliasPass: string; const AIsDefault: Boolean = False);
  end;

  TMoscoConfig = record
    AutoFillMacCerts: Boolean;
    CertExpiryWarnDays: Integer;
    CheckValidProfile: Boolean;
    DisableLockCheck: Boolean;
    ErrorsInMessages: Boolean;
    ErrorsDiagnostic: Boolean;
    Host: string;
    Port: Integer;
    PreventReminder: Boolean;
    ServerTimeout: Integer;
    UseProfile: Boolean;
    function CanRemind: Boolean;
    function CanSend: Boolean;
  end;

  TSourcePatchConfig = record
    AlwaysPromptSourceCopyPath: Boolean;
    SourceCopyPath: string;
    IsSourceCopyProjectRelative: Boolean;
    PatchFilesPath: string;
    ShouldOpenSourceFiles: Boolean;
  end;

  TIDEConfig = record
    DisplayWarningOnRunForAppStoreBuild: Boolean;
    DisplayWarningWhenSysJarsNotFound: Boolean;
    EnableEditorContextReadOnlyMenuItem: Boolean;
    HideFormDesignerViewSelector: Boolean;
    KillProjectProcess: Boolean;
    LoadProjectLastOpened: Boolean;
    ProjectLastOpenedFileName: string;
    ShowErrorInsightMessages: Boolean;
    ShowPlatformConfigCaption: Boolean;
    ShowProjectManagerOnProjectOpen: Boolean;
    SuppressBuildEventsWarning: Boolean;
  end;

  TFormProps = record
    Left: Integer;
    Height: Integer;
    Name: string;
    Top: Integer;
    Width: Integer;
    constructor Create(const AName: string; const ALeft, ATop, AWidth, AHeight: Integer);
  end;

  TFormsProps = TArray<TFormProps>;

  TDiagnostics = record
    LogFileOps: Boolean;
  end;

  TCodexConfig = record
    AI: TAIConfig;
    Android: TAndroidConfig;
    CommonPathsProjects: TArray<string>;
    Diagnostics: TDiagnostics;
    FormsProps: TFormsProps;
    IDE: TIDEConfig;
    IsLogEnabled: Boolean;
    Mosco: TMoscoConfig;
    OpenedFilesMRU: TArray<string>;
    ProjectPaths: TArray<string>;
    SourcePatch: TSourcePatchConfig;
    procedure AddCommonPathsProject(const AFileName: string);
    procedure AddOpenedFile(const AFileName: string);
    function GetFormProps(const AName: string; out AProps: TFormProps): Boolean;
    procedure Load;
    function RemoveCommonPathsProject(const AIndex: Integer): Boolean;
    procedure Save;
    procedure SetFormProps(const AName: string; const ALeft, ATop, AWidth, AHeight: Integer);
  end;

var
  Config: TCodexConfig;

implementation

uses
  System.SysUtils, System.IOUtils,
  Codex.Config.NEON;

{ TFormProps }

constructor TFormProps.Create(const AName: string; const ALeft, ATop, AWidth, AHeight: Integer);
begin
  Name := AName;
  Left := ALeft;
  Top := ATop;
  Width := AWidth;
  Height := AHeight;
end;

{ TCodexConfig }

function TCodexConfig.GetFormProps(const AName: string; out AProps: TFormProps): Boolean;
var
  LProps: TFormProps;
begin
  Result := False;
  for LProps in FormsProps do
  begin
    if LProps.Name.Equals(AName) then
    begin
      AProps := LProps;
      Result := True;
      Break;
    end;
  end;
end;

procedure TCodexConfig.Load;
begin
  DoLoad;
end;

procedure TCodexConfig.Save;
begin
  DoSave;
end;

procedure TCodexConfig.SetFormProps(const AName: string; const ALeft, ATop, AWidth, AHeight: Integer);
var
  I, LIndex: Integer;
begin
  LIndex := -1;
  for I := 0 to Length(FormsProps) - 1 do
  begin
    if FormsProps[I].Name.Equals(AName) then
    begin
      LIndex := I;
      Break;
    end;
  end;
  if LIndex = -1 then
  begin
    LIndex := Length(FormsProps);
    SetLength(FormsProps, LIndex + 1);
  end;
  FormsProps[LIndex] := TFormProps.Create(AName, ALeft, ATop, AWidth, AHeight);
end;

function TCodexConfig.RemoveCommonPathsProject(const AIndex: Integer): Boolean;
begin
  if (AIndex >= 0) and (AIndex < Length(CommonPathsProjects)) then
  begin
    Delete(CommonPathsProjects, AIndex, 1);
    Result := True;
  end
  else
    Result := False;
  if Result then
    Save;
end;

procedure TCodexConfig.AddCommonPathsProject(const AFileName: string);
begin
  CommonPathsProjects := [AFileName] + CommonPathsProjects;
  Save;
end;

procedure TCodexConfig.AddOpenedFile(const AFileName: string);
var
  I: Integer;
begin
  if Length(OpenedFilesMRU) = 15 then
    Delete(OpenedFilesMRU, 14, 1);
  for I := Low(OpenedFilesMRU) to High(OpenedFilesMRU) do
  begin
    if SameText(OpenedFilesMRU[I], AFileName) then
    begin
      Delete(OpenedFilesMRU, I, 1);
      Break;
    end;
  end;
  OpenedFilesMRU := [AFileName] + OpenedFilesMRU;
  Save;
end;

{ TADBConnectConfig }

procedure TADBConnectConfig.AddMRU(const AIP, APort: string);
var
  LIP: string;
  I, LIndex: Integer;
begin
  LIndex := -1;
  LIP := AIP + ':' + APort;
  for I := 0 to Length(MRU) - 1 do
  begin
    if LIP.Equals(MRU[I]) then
    begin
      LIndex := I;
      Break;
    end;
  end;
  if LIndex > -1 then
    Delete(MRU, LIndex, 1);
  MRU := [LIP] + MRU;
  IP := AIP;
  Port := APort;
end;

{ TAndroidConfig }

function TAndroidConfig.IndexOfKeyStoreItem(const AKeyStoreFileName, AKeyAlias: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(KeyStoreItems) - 1 do
  begin
    if SameText(KeyStoreItems[I].KeyStoreFileName, AKeyStoreFileName) and KeyStoreItems[I].KeyAlias.Equals(AKeyAlias) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function TAndroidConfig.FindKeyStoreItem(const AKeyStoreFileName, AKeyAlias: string; out AKeyStoreItem: TKeyStoreItem): Boolean;
var
  LIndex: Integer;
begin
  Result := False;
  LIndex := IndexOfKeyStoreItem(AKeyStoreFileName, AKeyAlias);
  if LIndex > -1 then
  begin
    AKeyStoreItem := KeyStoreItems[LIndex];
    Result := True;
  end;
end;

function TAndroidConfig.FindKeyStoreItemDefault(out AKeyStoreItem: TKeyStoreItem): Boolean;
begin
  Result := FindKeyStoreItem(DefaultKeyStoreFileName, DefaultKeyStoreAlias, AKeyStoreItem);
end;

function TAndroidConfig.GetKeyStoreItem(const AKeyStoreFileName, AKeyAlias: string): TKeyStoreItem;
begin
  if FindKeyStoreItem(AKeyStoreFileName, AKeyAlias, Result) then
  begin
    Result.KeyStoreFileName := AKeyStoreFileName;
    Result.KeyAlias := AKeyAlias;
  end;
end;

procedure TAndroidConfig.SetKeyStoreItem(const AKeyStoreFileName, AKeyStorePass, AKeyAlias, AKeyAliasPass: string; const AIsDefault: Boolean);
var
  LIndex: Integer;
  LItem: TKeyStoreItem;
begin
  LIndex := IndexOfKeyStoreItem(AKeyStoreFileName, AKeyAlias);
  if LIndex > -1 then
    LItem := KeyStoreItems[LIndex];
  LItem.KeyStoreFileName := AKeyStoreFileName;
  LItem.KeyAlias := AKeyAlias;
  LItem.KeyStorePass := AKeyStorePass;
  LItem.KeyAliasPass := AKeyAliasPass;
  if LIndex > -1 then
    KeyStoreItems[LIndex] := LItem
  else
    KeyStoreItems := KeyStoreItems + [LItem];
  if AIsDefault then
  begin
    DefaultKeyStoreFileName := AKeyStoreFileName;
    DefaultKeyStoreAlias := AKeyAlias;
  end;
end;

{ TMoscoConfig }

function TMoscoConfig.CanRemind: Boolean;
begin
  // Not sure what this was for - seems like to remind the user that they do not have any setting for the host?
  Result := not PreventReminder and not CanSend;
end;

function TMoscoConfig.CanSend: Boolean;
begin
  Result := not Host.IsEmpty and (Port <> 0);
end;

end.
