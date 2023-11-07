unit Codex.Config.PreVersion2;

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
  TCodexConfigPreVersion2 = record
  private
    procedure SaveAsVersion2;
  public
    class procedure Migrate; static;
  public
    AlwaysPromptSourceCopyPath: Boolean;
    EnableReadOnlyEditorMenuItem: Boolean;
    GradlePath: string;
    HideEditModeSelector: Boolean;
    HideViewSelector: Boolean;
    IsSourceCopyProjectRelative: Boolean;
    KillRunningProcess: Boolean;
    LastProject: string;
    OpenedFilesMRU: TArray<string>;
    PatchEXEPath: string;
    PatchFilesPath: string;
    RunRunIntercept: Boolean;
    ShouldOpenSourceFiles: Boolean;
    ShowErrorInsightMessages: Boolean;
    ShowPlatformConfigCaption: Boolean;
    ShowProjectManager: Boolean;
    SourceCopyPath: string;
    StartupLoadLastProject: Boolean;
    SuppressBuildEventsWarning: Boolean;
  end;

implementation

uses
  System.JSON, System.IOUtils, System.SysUtils,
  Neon.Core.Persistence, Neon.Core.Persistence.JSON,
  Codex.Config, Codex.Config.NEON;

type
  TAndroidConfigPreVersion2 = record
    ADBConnectDismissOnSuccess: Boolean;
    ADBConnectIP: string;
    ADBConnectPort: Integer;
    DefaultAABFileName: string;
    DefaultClassPathFolder: string;
    DefaultJarFolder: string;
    DefaultKeyStoreAlias: string;
    DefaultKeyStoreFileName: string;
    DefaultSourceFolder: string;
    GradlePath: string;
    JarFolder: string;
    JarOutputFolder: string;
    JavaFolder: string;
    PackageDownloadFolder: string;
    ResourcesFolder: string;
  end;

  TMoscoConfigPreVersion2 = record
    AutoFillMacCerts: Boolean;
    CheckValidProfile: Boolean;
    CertExpiryWarnDays: Integer;
    DisableLockCheck: Boolean;
    ErrorsDiagnostic: Boolean;
    ErrorsInMessages: Boolean;
    PreventReminder: Boolean;
    ServerHost: string;
    ServerPort: Integer;
    ServerTimeout: Integer;
  end;

{ TCodexConfigPreVersion2 }

class procedure TCodexConfigPreVersion2.Migrate;
var
  LJSON: TJSONValue;
  LStartupLoadLastProject: Boolean;
  LConfigPreVersion2: TCodexConfigPreVersion2;
  LFileName: string;
begin
  LFileName := Config.GetConfigFileName;
  if TFile.Exists(LFileName) then
  begin
    LJSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(LFileName));
    if LJSON <> nil then
    try
      // Test if it's a pre V2 config
      if LJSON.TryGetValue('startupLoadLastProject', LStartupLoadLastProject) then
      begin
        LConfigPreVersion2 := TNeon.JSONToValue<TCodexConfigPreVersion2>(LJSON, TNeonConfiguration.Camel);
        LConfigPreVersion2.SaveAsVersion2;
      end;
    finally
      LJSON.Free;
    end;
  end;
end;

procedure TCodexConfigPreVersion2.SaveAsVersion2;
var
  LAndroidConfigPreVersion2: TAndroidConfigPreVersion2;
  LMoscoConfigPreVersion2: TMoscoConfigPreVersion2;
  LConfigFileName: string;
begin
  LConfigFileName := TPath.Combine(TPath.GetDirectoryName(Config.GetConfigFileName), 'AndroidConfig.json');
  if TFile.Exists(LConfigFileName) then
  begin
    LAndroidConfigPreVersion2 := TNeon.JSONToValue<TAndroidConfigPreVersion2>(TFile.ReadAllText(LConfigFileName), TNeonConfiguration.Camel);
    Config.Android.ADBConnect.DismissOnSuccess := LAndroidConfigPreVersion2.ADBConnectDismissOnSuccess;
    Config.Android.ADBConnect.IP := LAndroidConfigPreVersion2.ADBConnectIP;
    Config.Android.ADBConnect.Port := LAndroidConfigPreVersion2.ADBConnectPort.ToString;
    Config.Android.GradlePath := GradlePath;
    Config.Android.DefaultAABFileName := LAndroidConfigPreVersion2.DefaultAABFileName;
    Config.Android.DefaultAndroidPackageFolder := LAndroidConfigPreVersion2.PackageDownloadFolder;
    Config.Android.DefaultKeyStoreFileName := LAndroidConfigPreVersion2.DefaultKeyStoreFileName;
    Config.Android.DefaultKeyStoreAlias := LAndroidConfigPreVersion2.DefaultKeyStoreAlias;
    Config.Android.GradlePath := LAndroidConfigPreVersion2.GradlePath;
    Config.Android.JarFolder :=  LAndroidConfigPreVersion2.JarFolder;
    Config.Android.JarOutputFolder := LAndroidConfigPreVersion2.JarOutputFolder;
    Config.Android.JavaFolder := LAndroidConfigPreVersion2.JavaFolder;
    Config.Android.Java2OP.DefaultClassPathFolder := LAndroidConfigPreVersion2.DefaultClassPathFolder;
    Config.Android.Java2OP.DefaultJarFolder := LAndroidConfigPreVersion2.DefaultJarFolder;
    Config.Android.Java2OP.DefaultSourceFolder := LAndroidConfigPreVersion2.DefaultSourceFolder;
    Config.Android.ResourcesFolder := LAndroidConfigPreVersion2.ResourcesFolder;
  end;
  Config.IDE.EnableEditorContextReadOnlyMenuItem := EnableReadOnlyEditorMenuItem;
  Config.IDE.HideFormDesignerViewSelector := HideViewSelector;
  Config.IDE.KillProjectProcess := KillRunningProcess;
  Config.IDE.LoadProjectLastOpened := StartupLoadLastProject;
  Config.IDE.ProjectLastOpenedFileName := LastProject;
  Config.IDE.ShowErrorInsightMessages := ShowErrorInsightMessages;
  Config.IDE.ShowPlatformConfigCaption := ShowPlatformConfigCaption;
  Config.IDE.ShowProjectManagerOnProjectOpen := ShowProjectManager;
  Config.IDE.SuppressBuildEventsWarning := SuppressBuildEventsWarning;
  Config.IDE.DisplayWarningOnRunForAppStoreBuild := RunRunIntercept;
  LConfigFileName := TPath.Combine(TPath.GetDirectoryName(Config.GetConfigFileName), 'Mosco.json');
  if TFile.Exists(LConfigFileName) then
  begin
    LMoscoConfigPreVersion2 := TNeon.JSONToValue<TMoscoConfigPreVersion2>(TFile.ReadAllText(LConfigFileName), TNeonConfiguration.Camel);
    Config.Mosco.AutoFillMacCerts := LMoscoConfigPreVersion2.AutoFillMacCerts;
    Config.Mosco.CertExpiryWarnDays := LMoscoConfigPreVersion2.CertExpiryWarnDays;
    Config.Mosco.CheckValidProfile := LMoscoConfigPreVersion2.CheckValidProfile;
    Config.Mosco.DisableLockCheck := LMoscoConfigPreVersion2.DisableLockCheck;
    Config.Mosco.ErrorsDiagnostic := LMoscoConfigPreVersion2.ErrorsDiagnostic;
    Config.Mosco.ErrorsInMessages := LMoscoConfigPreVersion2.ErrorsInMessages;
    Config.Mosco.Host := LMoscoConfigPreVersion2.ServerHost;
    Config.Mosco.Port := LMoscoConfigPreVersion2.ServerPort;
    Config.Mosco.PreventReminder := LMoscoConfigPreVersion2.PreventReminder;
    Config.Mosco.ServerTimeout := LMoscoConfigPreVersion2.ServerTimeout;
  end;
  Config.OpenedFilesMRU := OpenedFilesMRU;
  Config.SourcePatch.AlwaysPromptSourceCopyPath := AlwaysPromptSourceCopyPath;
  Config.SourcePatch.SourceCopyPath := SourceCopyPath;
  Config.SourcePatch.IsSourceCopyProjectRelative := IsSourceCopyProjectRelative;
  Config.SourcePatch.PatchFilesPath := PatchFilesPath;
  Config.SourcePatch.ShouldOpenSourceFiles := ShouldOpenSourceFiles;
  Config.Save;
end;

end.
