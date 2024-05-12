unit Codex.Android.PackageDownloadView;

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
  System.SysUtils, System.Variants, System.Classes, System.Actions,
  Winapi.Windows, Winapi.Messages, Winapi.WebView2, Winapi.ActiveX,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ActnList, Vcl.CheckLst, Vcl.ComCtrls, Vcl.Edge,
  Vcl.WinXCtrls,
  Codex.OutputView, Codex.Android.GradleDepsProcess, Codex.BaseView;

type
  TGradleTemplateItem = record
    ConfigurationName: string;
    RepositoryName: string;
    Version: string;
    constructor Create(const APackage: string);
    function GetDependency: string;
    function IsValid: Boolean;
    function IsValidVersion: Boolean;
  end;

  TGradleTemplateItems = TArray<TGradleTemplateItem>;

  TMavenStep = (None, Search, GetArtifacts, NavigateArtifact, GetPackageVersions);

  TArtifact = record
    HREF: string;
    Name: string;
    Package: string;
  end;

  TArtifacts = TArray<TArtifact>;

  TPackageVersion = record
    Name: string;
    Version: string;
  end;

  TPackageVersions = TArray<TPackageVersion>;

  TPackageDownloadView = class(TForm)
    ExtractPathEdit: TEdit;
    SelectExtractPathButton: TSpeedButton;
    ExtractButtonsPanel: TPanel;
    ExtractAARButton: TButton;
    ExtractPathPanel: TPanel;
    ExtractPathLabel: TLabel;
    CloseButton: TButton;
    GradlePathPanel: TPanel;
    SelectGradlePathButton: TSpeedButton;
    GradlePathLabel: TLabel;
    GradlePathEdit: TEdit;
    PackagesPanel: TPanel;
    PackagesLabel: TLabel;
    PackagesMemo: TMemo;
    GradleOpenDialog: TFileOpenDialog;
    ExtractPathOpenDialog: TFileOpenDialog;
    ActionList: TActionList;
    ExtractAction: TAction;
    PackageSearchPanel: TPanel;
    SearchPackagesLabel: TLabel;
    PackageSearchEditPanel: TPanel;
    SearchEdit: TEdit;
    PackageSearchButton: TButton;
    PackageSearchResultsPanel: TPanel;
    PackagesListView: TListView;
    ReleasesListView: TListView;
    ReleasesPanel: TPanel;
    AddPackageButton: TButton;
    AddPackageAction: TAction;
    MessageLabel: TLabel;
    URLLabel: TLabel;
    Panel1: TPanel;
    URLEdit: TEdit;
    URLGetButton: TButton;
    EdgeBrowser: TEdgeBrowser;
    SearchTimer: TTimer;
    RetainCheckBox: TCheckBox;
    procedure SelectExtractPathActionExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure SelectGradlePathButtonClick(Sender: TObject);
    procedure ExtractActionUpdate(Sender: TObject);
    procedure ExtractActionExecute(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
    procedure PackageSearchButtonClick(Sender: TObject);
    procedure PackagesListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure AddPackageActionUpdate(Sender: TObject);
    procedure AddPackageActionExecute(Sender: TObject);
    procedure URLGetButtonClick(Sender: TObject);
    procedure EdgeBrowserExecuteScript(Sender: TCustomEdgeBrowser; AResult: HRESULT; const AResultObjectAsJson: string);
    procedure SearchTimerTimer(Sender: TObject);
    procedure EdgeBrowserNavigationCompleted(Sender: TCustomEdgeBrowser; IsSuccess: Boolean; WebErrorStatus: TOleEnum);
    procedure FormResize(Sender: TObject);
    procedure SearchEditKeyPress(Sender: TObject; var Key: Char);
    procedure URLEditKeyPress(Sender: TObject; var Key: Char);
    procedure ReleasesListViewDblClick(Sender: TObject);
  private
    FActivityIndicator: TActivityIndicator;
    FArtifacts: TArtifacts;
    FPackageVersions: TPackageVersions;
    FMavenStep: TMavenStep;
    FProcess: TGradleDepsProcess;
    FOutputView: TOutputView;
    procedure DoQueuedOutput(const AOutput: string);
    procedure ExecuteExtraction;
    procedure ExtractAARFiles(const AExtractPath: string);
    function GenerateBuildGradle(const APath: string): Boolean;
    function GetGradleConfigurations(const AItems: TGradleTemplateItems): string;
    function GetGradleCopyCommands(const AItems: TGradleTemplateItems): string;
    function GetGradleDependencies(const AItems: TGradleTemplateItems): string;
    function GetJavaScriptFileName(const AFileName: string): string;
    procedure GradleDepsProcessCompletedHandler(Sender: TObject);
    procedure GradleDepsProcessOutputHandler(Sender: TObject; const AOutput: string);
    function HasValidPackages: Boolean;
    function IsValidExtractPath: Boolean;
    function IsValidGradlePath: Boolean;
    procedure OutputHandler(const AOutput: string);
    procedure RepositionActivityIndicator;
    procedure SetErrorMessage(const AMessage: string);
    procedure SetSearchBusy(const ABusy: Boolean);
    procedure ShowWaiting(const AShow: Boolean; const AText: string = '');
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  PackageDownloadView: TPackageDownloadView;

implementation

{$R *.dfm}

uses
  System.IOUtils, System.Zip, System.Generics.Collections, System.Generics.Defaults,
  Xml.XmlDoc, Xml.XmlIntf,
  BrandingAPI,
  Vcl.GraphUtil,
  Neon.Core.Persistence.JSON,
  DW.OSLog,
  DW.IOUtils.Helpers, DW.Classes.Helpers,
  Codex.Config, Codex.Core, Codex.OTA.Helpers, Codex.Consts.Text;

const
  cMvnRepositoryRootURL = 'https://mvnrepository.com';
  cMvnRepositorSearchURL = cMvnRepositoryRootURL + '/search?q=';

  cJavaScriptGetArtifactsFileName = 'GetArtifacts.js';
  cJavaScriptGetArtifactPackagesFileName = 'GetArtifactPackageVersions.js';

  cCopyCommandTemplate =
    '    copy {'#13#10 +
    '      duplicatesStrategy = ''exclude'''#13#10 +
    '      from configurations.%s.resolve() into ''..'''#13#10 +
    '    }';

  // Ensures that the Android variant is chosen for packages/dependencies that have variants (e.g. Android and JVM)
  cConfigurationTemplate =
    '  register(''%s'') {'#13#10 +
    '    attributes {'#13#10 +
    '      attribute('#13#10 +
    '        TargetJvmEnvironment.TARGET_JVM_ENVIRONMENT_ATTRIBUTE,'#13#10 +
    '        objects.named(TargetJvmEnvironment, TargetJvmEnvironment.ANDROID)'#13#10 +
    '      )'#13#10 +
    '    }'#13#10 +
    '  }';

resourcestring
  sErrorUnknown = 'Unknown error';
  sErrorTimedOut = 'Timed out';

function ExtractAAR(const AFileName, APath: string; const AUseFullPackageName: Boolean = False): string;
var
  LPackageName, LWorkingFolder, LPackageFolder, LWorkingJarFileName, LJarFileName, LManifestFileName, LVersion: string;
  LManifestDoc: IXMLDocument;
begin
  LPackageName := TPath.GetFileNameWithoutExtension(AFileName);
  LVersion := LPackageName.Substring(LPackageName.LastIndexOf('-') + 1);
  LWorkingFolder := TPath.Combine(APath, LPackageName);
  LManifestFileName := TPath.Combine(LWorkingFolder, 'AndroidManifest.xml');
  LWorkingJarFileName := TPath.Combine(LWorkingFolder, 'classes.jar');
  TZipFile.ExtractZipFile(AFileName, LWorkingFolder);
  if AUseFullPackageName and TFile.Exists(LManifestFileName) then
  begin
    LManifestDoc := LoadXMLDocument(LManifestFileName);
    LPackageName := LManifestDoc.DocumentElement.Attributes['package'];
    LPackageName := LPackageName.Replace('.', '-', [rfReplaceAll]) + '-' + LVersion;
  end;
  LPackageFolder := TPath.Combine(APath, LPackageName);
  // Move classes.jar as the new filename into the jar path
  LJarFileName := TPath.Combine(APath, LPackageName + '.jar');
  if TFile.Exists(LWorkingJarFileName) and not TFile.Exists(LJarFileName) then
    TFile.Move(LWorkingJarFileName, LJarFileName);
  // Rename the folder to use the "real" package name
  if not LWorkingFolder.Equals(LPackageFolder) then
    TDirectory.Move(LWorkingFolder, LPackageFolder);
  Result := LPackageFolder;
end;

{ TGradleTemplateItem }

constructor TGradleTemplateItem.Create(const APackage: string);
var
  LParts: TArray<string>;
begin
  ConfigurationName := '';
  RepositoryName := APackage;
  LParts := APackage.Split([':']);
  if Length(LParts) > 2 then
  begin
    Version := LParts[2];
    ConfigurationName := LParts[1].Replace('-', '_');
  end;
end;

function TGradleTemplateItem.GetDependency: string;
begin
  Result := '  ' + ConfigurationName + ' ''' + RepositoryName + '''';
end;

function TGradleTemplateItem.IsValid: Boolean;
begin
  Result := not ConfigurationName.IsEmpty and IsValidVersion;
end;

function TGradleTemplateItem.IsValidVersion: Boolean;
var
  LParts: TArray<string>;
begin
  Result := False;
  LParts := Version.Split(['.']);
  if Length(LParts) > 1 then
    Result := True;
end;

{ TPackageDownloadView }

constructor TPackageDownloadView.Create(AOwner: TComponent);
begin
  inherited;
  EdgeBrowser.Visible := False;
  FActivityIndicator := TActivityIndicator.Create(Self);
  FActivityIndicator.Visible := False;
  FActivityIndicator.Parent := Self;
  FActivityIndicator.IndicatorSize := aisLarge;
  FOutputView := TOutputView.Create(Self);
  FProcess := TGradleDepsProcess.Create;
  FProcess.OnProcessOutput := GradleDepsProcessOutputHandler;
  FProcess.OnCompleted := GradleDepsProcessCompletedHandler;
  GradlePathEdit.Text := Config.Android.GradlePath;
  ExtractPathEdit.Text := Config.Android.ResourcesFolder;
end;

destructor TPackageDownloadView.Destroy;
begin
  FProcess.Free;
  inherited;
end;

procedure TPackageDownloadView.DoShow;
begin
  if ThemeProperties <> nil then
  begin
    if not ColorIsBright(ThemeProperties.MainToolBarColor) then
      FActivityIndicator.IndicatorColor := aicWhite;
  end;
  if Config.Android.PackageSearchTimeout < 30000 then
  begin
    Config.Android.PackageSearchTimeout := 30000;
    Config.Save;
  end;
  SearchTimer.Interval := Config.Android.PackageSearchTimeout;
  SearchEdit.Text := '';
  PackagesListView.Items.Clear;
  ReleasesListView.Items.Clear;
  inherited;
end;

procedure TPackageDownloadView.AddPackageActionExecute(Sender: TObject);
var
  LItem: TListItem;
begin
  LItem := ReleasesListView.Selected;
  if LItem <> nil then
    PackagesMemo.Lines.Add(FArtifacts[PackagesListView.Selected.Index].Package + ':' + FPackageVersions[LItem.Index].Version);
end;

procedure TPackageDownloadView.AddPackageActionUpdate(Sender: TObject);
begin
  AddPackageAction.Enabled := ReleasesListView.Selected <> nil;
end;

procedure TPackageDownloadView.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TPackageDownloadView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Config.Android.GradlePath := string(GradlePathEdit.Text).Trim;
  if TDirectory.Exists(ExtractPathEdit.Text) then
    Config.Android.ResourcesFolder := ExtractPathEdit.Text;
  Config.Save;
end;

procedure TPackageDownloadView.FormResize(Sender: TObject);
begin
  RepositionActivityIndicator;
end;

function TPackageDownloadView.GenerateBuildGradle(const APath: string): Boolean;
var
  LTemplateFile, LTemplate, LPackage: string;
  I: Integer;
  LItems: TGradleTemplateItems;
begin
  Result := False;
  LTemplateFile := TPathHelper.GetAppDocumentsFile('build.template.gradle');
  if TFile.Exists(LTemplateFile) then
  begin
    LTemplate := TFile.ReadAllText(LTemplateFile);
    // Could do this as the memo changes, or before even attempting to generate the file
    for I := 0 to PackagesMemo.Lines.Count - 1 do
    begin
      LPackage := PackagesMemo.Lines[I].Trim;
      if not LPackage.IsEmpty then
        LItems := LItems + [TGradleTemplateItem.Create(LPackage)];
    end;
    if Length(LItems) > 0 then
    begin
      LTemplate := LTemplate.Replace('%configurations%', GetGradleConfigurations(LItems));
      LTemplate := LTemplate.Replace('%dependencies%', GetGradleDependencies(LItems));
      LTemplate := LTemplate.Replace('%copycommands%', GetGradleCopyCommands(LItems));
      TFile.WriteAllText(TPath.Combine(APath, 'build.gradle'), LTemplate);
      Result := True;
    end;
  end;
end;

function TPackageDownloadView.GetGradleConfigurations(const AItems: TGradleTemplateItems): string;
var
  LItem: TGradleTemplateItem;
  LConfigurations: TArray<string>;
begin
  for LItem in AItems do
    LConfigurations := LConfigurations + [Format(cConfigurationTemplate, [LItem.ConfigurationName])];
  Result := string.Join(#13#10, LConfigurations);
end;

function TPackageDownloadView.GetGradleCopyCommands(const AItems: TGradleTemplateItems): string;
var
  LItem: TGradleTemplateItem;
  LCommands: TArray<string>;
begin
  for LItem in AItems do
    LCommands := LCommands + [Format(cCopyCommandTemplate, [LItem.ConfigurationName])];
  Result := string.Join(#13#10, LCommands);
end;

function TPackageDownloadView.GetGradleDependencies(const AItems: TGradleTemplateItems): string;
var
  LItem: TGradleTemplateItem;
  LDependencies: TArray<string>;
begin
  for LItem in AItems do
    LDependencies := LDependencies + [LItem.GetDependency];
  Result := string.Join(#13#10, LDependencies);
end;

function TPackageDownloadView.GetJavaScriptFileName(const AFileName: string): string;
begin
  Result := TPathHelper.GetAppDocumentsFile(AFileName, 'JS');
end;

function TPackageDownloadView.HasValidPackages: Boolean;
var
  LItem: TGradleTemplateItem;
  I: Integer;
  LPackage: string;
  LHasInvalid: Boolean;
begin
  Result := False;
  LHasInvalid := False;
  for I := 0 to PackagesMemo.Lines.Count - 1 do
  begin
    LPackage := PackagesMemo.Lines[I].Trim;
    if not LPackage.IsEmpty then
    begin
      // Has at least one package
      Result := True;
      LItem := TGradleTemplateItem.Create(LPackage);
      if not LItem.IsValid then
        LHasInvalid := True;
    end;
  end;
  // If ANY are invalid, returns False
  Result := Result and not LHasInvalid;
end;

function TPackageDownloadView.IsValidExtractPath: Boolean;
var
  LExtractPath: string;
begin
  LExtractPath := string(ExtractPathEdit.Text).Trim;
  if not LExtractPath.IsEmpty then
    LExtractPath := TPath.GetDirectoryName(LExtractPath);
  Result := not LExtractPath.IsEmpty and TDirectory.Exists(LExtractPath);
end;

function TPackageDownloadView.IsValidGradlePath: Boolean;
var
  LGradleFileName, LGradlePath: string;
begin
  Result := False;
  LGradleFileName := string(GradlePathEdit.Text).Trim;
  if not LGradleFileName.IsEmpty then
  begin
    LGradlePath := TPath.GetDirectoryName(LGradleFileName);
    LGradleFileName := TPath.GetFileName(GradlePathEdit.Text);
    Result := TDirectory.Exists(LGradlePath) and
      SameText(LGradleFileName, 'gradle.bat'); // and TFile.Exists(TPath.Combine(LGradlePath, 'gradle'));
  end;
end;

procedure TPackageDownloadView.OutputHandler(const AOutput: string);
begin
  FOutputView.Show;
  FOutputView.Memo.Lines.Add(AOutput);
end;

procedure TPackageDownloadView.PackageSearchButtonClick(Sender: TObject);
begin
  MessageLabel.Caption := '';
  PackageSearchButton.Enabled := False;
  URLGetButton.Enabled := False;
  PackagesListView.Items.Clear;
  ReleasesListView.Items.Clear;
  FMavenStep := TMavenStep.Search;
  EdgeBrowser.Navigate(cMvnRepositorSearchURL + SearchEdit.Text);
  SetSearchBusy(True);
end;

procedure TPackageDownloadView.URLEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    URLGetButtonClick(URLGetButton);
  end;
end;

procedure TPackageDownloadView.URLGetButtonClick(Sender: TObject);
begin
  MessageLabel.Caption := '';
  PackageSearchButton.Enabled := False;
  URLGetButton.Enabled := False;
  PackagesListView.Items.Clear;
  ReleasesListView.Items.Clear;
  FMavenStep := TMavenStep.GetArtifacts;
  EdgeBrowser.Navigate(URLEdit.Text);
  SetSearchBusy(True);
end;

procedure TPackageDownloadView.PackagesListViewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
  begin
    ReleasesListView.Items.Clear;
    FMavenStep := TMavenStep.NavigateArtifact;
    EdgeBrowser.Navigate(cMvnRepositoryRootURL + FArtifacts[Item.Index].HREF);
    SetSearchBusy(True);
  end;
end;

procedure TPackageDownloadView.ReleasesListViewDblClick(Sender: TObject);
begin
  if ReleasesListView.Selected <> nil then
    AddPackageAction.Execute;
end;

procedure TPackageDownloadView.RepositionActivityIndicator;
begin
  if (FActivityIndicator <> nil) and FActivityIndicator.Visible then
  begin
    FActivityIndicator.Top := (ClientHeight div 2) - (FActivityIndicator.Height div 2);
    FActivityIndicator.Left := (ClientWidth div 2) - (FActivityIndicator.Width div 2);
  end;
end;

procedure TPackageDownloadView.SetSearchBusy(const ABusy: Boolean);
begin
//  {$IF not Defined(EXPERT)}
//  EdgeBrowser.Visible := ABusy;
//  if EdgeBrowser.Visible then
//    EdgeBrowser.BringToFront;
//  {$ENDIF}
  PackageSearchButton.Enabled := not ABusy;
  ShowWaiting(ABusy, Babel.Tx(sSearchingAndroidPackages));
  SearchTimer.Enabled := ABusy;
end;

procedure TPackageDownloadView.ShowWaiting(const AShow: Boolean; const AText: string);
begin
  {$IF CompilerVersion > 35}
  if AShow then
    TCodexOTAHelper.ShowWait(AText)
  else
    TCodexOTAHelper.HideWait;
  {$ELSE}
  FActivityIndicator.Animate := AShow;
  FActivityIndicator.Visible := AShow;
  RepositionActivityIndicator;
  {$ENDIF}
end;

procedure TPackageDownloadView.EdgeBrowserExecuteScript(Sender: TCustomEdgeBrowser; AResult: HRESULT; const AResultObjectAsJson: string);
var
  LItem: TListItem;
  LArtifact: TArtifact;
  LVersion: TPackageVersion;
begin
  SetSearchBusy(False);
  case FMavenStep of
    TMavenStep.GetArtifacts:
    begin
      FArtifacts := TNeon.JSONToValue<TArtifacts>(AResultObjectAsJson);
      for LArtifact in FArtifacts do
      begin
        LItem := PackagesListView.Items.Add;
        LItem.Caption := LArtifact.Name;
        LItem.SubItems.Add(LArtifact.Package);
      end;
    end;
    TMavenStep.GetPackageVersions:
    begin
      FPackageVersions := TNeon.JSONToValue<TPackageVersions>(AResultObjectAsJson);
      for LVersion in FPackageVersions do
      begin
        LItem := ReleasesListView.Items.Add;
        LItem.Caption := LVersion.Name;
        LItem.SubItems.Add(LVersion.Version);
      end;
    end;
  end;
end;

procedure TPackageDownloadView.EdgeBrowserNavigationCompleted(Sender: TCustomEdgeBrowser; IsSuccess: Boolean; WebErrorStatus: TOleEnum);
begin
  if IsSuccess then
  begin
    case FMavenStep of
      TMavenStep.Search:
      begin
        FMavenStep := TMavenStep.GetArtifacts;
        EdgeBrowser.ExecuteScript(TFile.ReadAllText(GetJavaScriptFileName(cJavaScriptGetArtifactsFileName)));
      end;
      TMavenStep.NavigateArtifact:
      begin
        FMavenStep := TMavenStep.GetPackageVersions;
        EdgeBrowser.ExecuteScript(TFile.ReadAllText(GetJavaScriptFileName(cJavaScriptGetArtifactPackagesFileName)));
      end;
    end;
  end
  else
    SetErrorMessage(Babel.Tx(sErrorUnknown));
end;

procedure TPackageDownloadView.SearchEditKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    PackageSearchButtonClick(PackageSearchButton);
  end;
end;

procedure TPackageDownloadView.SearchTimerTimer(Sender: TObject);
begin
  SetSearchBusy(False);
  EdgeBrowser.Stop;
  SetErrorMessage(Babel.Tx(sErrorTimedOut));
end;

procedure TPackageDownloadView.SelectExtractPathActionExecute(Sender: TObject);
var
  LExtractPath: string;
begin
  LExtractPath := string(ExtractPathEdit.Text).Trim;
  if LExtractPath.IsEmpty then
    LExtractPath := Config.Android.ResourcesFolder;
  ExtractPathOpenDialog.DefaultFolder := LExtractPath;
  if ExtractPathOpenDialog.Execute then
    ExtractPathEdit.Text := ExtractPathOpenDialog.FileName;
end;

procedure TPackageDownloadView.SelectGradlePathButtonClick(Sender: TObject);
var
  LGradlePath: string;
begin
  LGradlePath := string(GradlePathEdit.Text).Trim;
  if not LGradlePath.IsEmpty then
  begin
    LGradlePath := TPath.GetDirectoryName(LGradlePath);
    if TDirectory.Exists(LGradlePath) then
      GradleOpenDialog.DefaultFolder := LGradlePath;
  end;
  if GradleOpenDialog.Execute then
    GradlePathEdit.Text := GradleOpenDialog.FileName;
end;

procedure TPackageDownloadView.SetErrorMessage(const AMessage: string);
begin
  MessageLabel.Caption := AMessage;
end;

procedure TPackageDownloadView.ExecuteExtraction;
var
  LBuildPath: string;
begin
  FOutputView.Clear;
  ForceDirectories(ExtractPathEdit.Text);
  LBuildPath := TPath.Combine(ExtractPathEdit.Text, TGUID.NewGuid.ToString.Trim(['{', '}']));
  ForceDirectories(LBuildPath);
  if GenerateBuildGradle(LBuildPath) then
  begin
    FProcess.NeedsWorkingFiles := RetainCheckBox.Checked;
    FProcess.GradlePath := GradlePathEdit.Text;
    FProcess.BuildPath := LBuildPath;
    FProcess.Run;
  end
  else
  begin
    TDirectory.Delete(LBuildPath);
    OutputHandler('Failed to generate build.gradle');
  end;
end;

procedure TPackageDownloadView.GradleDepsProcessCompletedHandler(Sender: TObject);
var
  LExtractPath: string;
begin
  // i.e. the gradle steps completed
  // AARs should now be in subfolders of ExtractPathEdit.Text
  LExtractPath := ExtractPathEdit.Text;
  // TODO: Allow process to be stopped
  TDo.Run(procedure begin ExtractAARFiles(LExtractPath); end);
end;

procedure TPackageDownloadView.GradleDepsProcessOutputHandler(Sender: TObject; const AOutput: string);
begin
  OutputHandler(AOutput);
end;

procedure TPackageDownloadView.ExtractAARFiles(const AExtractPath: string);
var
  LAARFileName, LJarFileName, LPackageFolder, LMoveJarFileName: string;
begin
  for LAARFileName in TDirectory.GetFiles(AExtractPath, '*.aar', TSearchOption.soTopDirectoryOnly) do
  begin
    DoQueuedOutput(Format('Extracting %s..', [TPath.GetFileName(LAARFileName)]));
    LPackageFolder := ExtractAAR(LAARFileName, AExtractPath);
    // TODO: Might want an option to leave them intact?
    TFile.Delete(LAARFileName);
  end;
  for LJarFileName in TDirectory.GetFiles(AExtractPath, '*.jar', TSearchOption.soTopDirectoryOnly) do
  begin
    LMoveJarFileName := TPath.Combine(AExtractPath, TPath.GetFileName(LJarFileName));
    if not TFile.Exists(LMoveJarFileName) then
      TFile.Move(LJarFileName, LMoveJarFileName);
  end;
  DoQueuedOutput('**Process completed**');
end;

procedure TPackageDownloadView.ExtractActionExecute(Sender: TObject);
begin
  ExecuteExtraction;
end;

procedure TPackageDownloadView.ExtractActionUpdate(Sender: TObject);
begin
  ExtractAction.Enabled := IsValidGradlePath and IsValidExtractPath and HasValidPackages;
end;

procedure TPackageDownloadView.DoQueuedOutput(const AOutput: string);
begin
  TThread.Queue(nil,
    procedure
    begin
      OutputHandler(AOutput);
    end
  );
end;

end.
