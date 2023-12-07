unit Codex.IDETweaks.Wizard;

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
  System.TypInfo, System.Classes, System.SysUtils, System.IOUtils, System.StrUtils,
  Winapi.Windows,
  Xml.XmlIntf, Xml.XMLDoc,
  ToolsAPI, CommonOptionStrs,
  Vcl.ActnList, Vcl.Controls, Vcl.StdCtrls, Vcl.Forms,
  DW.OSLog,
  DW.OTA.Helpers, DW.OTA.Wizard, DW.OTA.Types, DW.OTA.Consts, DW.OTA.Notifiers, DW.OTA.Registry,DW.Vcl.DialogService, DW.OS.Win,
  Codex.Config, Codex.Types, Codex.Consts, Codex.Core;

type
  TEditorWindowHandler = reference to procedure(const Form: TForm);

  TIDEUICheck = (EditorWindowGeneral, ViewBar, WelcomePage);

  TIDEUIChecks = set of TIDEUICheck;

  TIDETweaksMessageNotifier = class(TMessageNotifier)
  private
    FProjectWarningsGroup: IOTAMessageGroup;
  public
    procedure AddProjectWarning(const AMessage: string);
    procedure ClearProjectWarnings;
    procedure MessageGroupDeleted(const Group: IOTAMessageGroup); override;
  end;

  TIDETweaksWizard = class(TWizard)
  private
    FApplicationTitle: string;
    FApplicationWidth: Integer;
    FBDSRegistry: TBDSRegistry;
    FIDEUIChecks: TIDEUIChecks;
    FMessageNotifier: TIDETweaksMessageNotifier;
    FProjectTargetLabel: TLabel;
    FRunRunCommandExecuteEvent: TNotifyEvent;
    procedure ActiveProjectChanged;
    procedure BaseActionList2UpdateHandler(Sender: TBasicAction; var AHandled: Boolean);
    procedure CheckApplicationProperties;
    procedure CheckEditorWindowGeneral(const AForm: TForm);
    procedure CheckEditorWindows(const AHandler: TEditorWindowHandler);
    procedure CheckProject;
    procedure CheckProjectSysJars;
    procedure CreateProjectTargetLabel;
    function GetProjectEnabledPlatforms(const AProject: IOTAProject): TProjectPlatforms;
    procedure HookBaseActionList2;
    procedure ModifyEditWindowViewSelector(const AForm: TComponent);
    procedure RunRunCommandExecuteHandler(Sender: TObject);
    procedure TrustProjectBuildEvents(const AProject: IOTAProject);
    procedure UpdateProjectTargetLabel;
  protected
    procedure ActiveFormChanged; override;
    procedure ConfigChanged; override;
    procedure FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string); override;
    procedure IDEBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: Boolean; var ACancel: Boolean); override;
    procedure IDEStarted; override;
    procedure PeriodicTimer; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

  TComponentHelper = class helper for TComponent
  public
    function FindComponentClass(const AClassName: string): TComponent;
    function FindChildComponent(const AHierarchy: array of string): TComponent;
  end;

resourcestring
  sConfirmContinueWithDistBuildType = 'Build type is: %s. Continue?';
  sJarFilesMissing = 'One or more jar files for this project are not present in this version of Delphi';

{ TComponentHelper }

function TComponentHelper.FindChildComponent(const AHierarchy: array of string): TComponent;
var
  I: Integer;
begin
  Result := Self;
  for I := Low(AHierarchy) to High(AHierarchy) do
  begin
    Result := Result.FindComponent(AHierarchy[I]);
    if Result = nil then
      Break;
  end;
end;

function TComponentHelper.FindComponentClass(const AClassName: string): TComponent;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I].ClassName.Equals(AClassName) then
    begin
      Result := Components[I];
      Break;
    end;
  end;
end;

{ TIDETweaksMessageNotifier }

procedure TIDETweaksMessageNotifier.AddProjectWarning(const AMessage: string);
begin
  // Do not localize
  FProjectWarningsGroup := TOTAHelper.AddTitleMessage(AMessage, 'Codex Project Warnings');
end;

procedure TIDETweaksMessageNotifier.ClearProjectWarnings;
begin
  (BorlandIDEServices as IOTAMessageServices).RemoveMessageGroup(FProjectWarningsGroup);
end;

procedure TIDETweaksMessageNotifier.MessageGroupDeleted(const Group: IOTAMessageGroup);
begin
  inherited;
  if Group = FProjectWarningsGroup then
    FProjectWarningsGroup := nil;
end;

{ TIDETweaksWizard }

constructor TIDETweaksWizard.Create;
begin
  inherited;
  FBDSRegistry := TBDSRegistry.Current;
  FMessageNotifier := TIDETweaksMessageNotifier.Create;
end;

destructor TIDETweaksWizard.Destroy;
begin
  FMessageNotifier.RemoveNotifier;
  inherited;
end;

procedure TIDETweaksWizard.IDEStarted;
begin
  inherited;
  FApplicationTitle := '';
  FApplicationWidth := Application.MainForm.Width;
  CreateProjectTargetLabel;
  HookBaseActionList2;
end;

procedure TIDETweaksWizard.ConfigChanged;
var
  LComponent: TComponent;
  LAction: TBasicAction;
begin
  if Config.IDE.DisplayWarningOnRunForAppStoreBuild and not Assigned(FRunRunCommandExecuteEvent) then
  begin
    if TOTAHelper.FindComponentGlobal('RunRunCommand', LComponent) then
    begin
      LAction := TBasicAction(LComponent);
      FRunRunCommandExecuteEvent := LAction.OnExecute;
      LAction.OnExecute := RunRunCommandExecuteHandler;
    end;
  end;
  if not Config.IDE.DisplayWarningOnRunForAppStoreBuild and Assigned(FRunRunCommandExecuteEvent) then
  begin
    if TOTAHelper.FindComponentGlobal('RunRunCommand', LComponent) then
    begin
      LAction := TBasicAction(LComponent);
      LAction.OnExecute := FRunRunCommandExecuteEvent;
      FRunRunCommandExecuteEvent := nil;
    end;
  end;
  UpdateProjectTargetLabel;
  inherited;
end;

procedure TIDETweaksWizard.ActiveProjectChanged;
begin
  Include(FIDEUIChecks, TIDEUICheck.EditorWindowGeneral);
end;

procedure TIDETweaksWizard.FileNotification(const ANotifyCode: TOTAFileNotification; const AFileName: string);
begin
  inherited;
  case ANotifyCode of
    TOTAFileNotification.ofnFileOpened:
    begin
      if AFileName.EndsWith('.dproj', True) then
        CheckProject;
      Include(FIDEUIChecks, TIDEUICheck.EditorWindowGeneral);
    end;
    TOTAFileNotification.ofnActiveProjectChanged:
      ActiveProjectChanged;
  end;
end;

procedure TIDETweaksWizard.IDEBeforeCompile(const AProject: IOTAProject; const AIsCodeInsight: Boolean; var ACancel: Boolean);
begin
  if not AIsCodeInsight then
  begin
    if Config.IDE.SuppressBuildEventsWarning then
    try
      TrustProjectBuildEvents(TOTAHelper.GetActiveProject);
    except
      on E: Exception do
        TOTAHelper.AddTitleException(E, 'TrustProjectBuildEvents', 'Codex');
    end;
  end;
  inherited;
end;

procedure TIDETweaksWizard.ActiveFormChanged;
begin
  inherited;
  Include(FIDEUIChecks, TIDEUICheck.EditorWindowGeneral);
end;

procedure TIDETweaksWizard.PeriodicTimer;
begin
  inherited;
  UpdateProjectTargetLabel;
  if TIDEUICheck.EditorWindowGeneral in FIDEUIChecks then
  begin
    CheckEditorWindows(CheckEditorWindowGeneral);
    Exclude(FIDEUIChecks, TIDEUICheck.EditorWindowGeneral);
  end;
end;

procedure TIDETweaksWizard.CheckEditorWindows(const AHandler: TEditorWindowHandler);
var
  I: Integer;
begin
  for I := 0 to Screen.FormCount - 1 do
  begin
    if Screen.Forms[I].ClassName.Equals('TEditWindow') then
      AHandler(Screen.Forms[I]);
  end;
end;

procedure TIDETweaksWizard.CheckProject;
begin
  ActiveProjectChanged;
  FMessageNotifier.ClearProjectWarnings;
  if Config.IDE.DisplayWarningWhenSysJarsNotFound then
    CheckProjectSysJars;
end;

function TIDETweaksWizard.GetProjectEnabledPlatforms(const AProject: IOTAProject): TProjectPlatforms;
var
  LProj: IXMLDocument;
  LNode, LPlatformNode: IXMLNode;
  I: Integer;
  LPlatform: string;
begin
  Result := [];
  LProj := LoadXMLDocument(AProject.FileName);
  LNode := LProj.DocumentElement.ChildNodes.FindNode('ProjectExtensions');
  if LNode <> nil then
  begin
    LNode := LNode.ChildNodes.FindNode('BorlandProject');
    if LNode <> nil then
    begin
      LNode := LNode.ChildNodes.FindNode('Platforms');
      if LNode <> nil then
      begin
        for I := 0 to LNode.ChildNodes.Count - 1 do
        begin
          LPlatformNode := LNode.ChildNodes[I];
          if SameText(LPlatformNode.Text, 'True') then
          begin
            LPlatform := LPlatformNode.Attributes['value'];
            if IndexStr(LPlatform, cProjectPlatforms) > -1 then
              Include(Result, TOTAHelper.GetProjectPlatform(LPlatform));
          end;
        end;
      end;
    end;
  end;
end;

procedure TIDETweaksWizard.CheckProjectSysJars;
var
  LConfigs: IOTAProjectOptionsConfigurations;
  LBuildConfig, LPlatformConfig: IOTABuildConfiguration;
  I: Integer;
  LSysJar, LSysJarFileName, LJarsPath, LPlatform: string;
  LIsSysJarMissing: Boolean;
  LProject: IOTAProject;
  LEnabledPlatforms: TProjectPlatforms;
begin
  LProject := TOTAHelper.GetActiveProject;
  if (LProject <> nil) and TFile.Exists(LProject.FileName) then
  begin
    LEnabledPlatforms := GetProjectEnabledPlatforms(LProject);
    LConfigs := TOTAHelper.GetProjectOptionsConfigurations(LProject);
    if (LConfigs <> nil) and (LEnabledPlatforms * [TProjectPlatform.Android32, TProjectPlatform.Android64] <> []) then
    begin
      LJarsPath := TPlatformOS.GetEnvironmentVariable(cEnvVarBDSLib) + '\android\release';
      LIsSysJarMissing := False;
      for I := 0 to LConfigs.ConfigurationCount - 1 do
      begin
        LBuildConfig := LConfigs.Configurations[I];
        for LPlatform in LBuildConfig.Platforms do
        begin
          if LPlatform.StartsWith('Android', True) then
          begin
            LPlatformConfig := LBuildConfig.PlatformConfiguration[LPlatform];
            for LSysJar in LPlatformConfig.Value['EnabledSysJars'].Split([';']) do
            begin
              LSysJarFileName := TPath.Combine(LJarsPath, LSysJar);
              if not LSysJar.IsEmpty and not TFile.Exists(LSysJarFileName) then
              begin
                LIsSysJarMissing := True;
                Break;
              end;
            end;
            if LIsSysJarMissing then
              Break;
          end;
        end;
      end;
      if LIsSysJarMissing then
        FMessageNotifier.AddProjectWarning(Babel.Tx(sJarFilesMissing));
    end;
  end;
end;

procedure TIDETweaksWizard.CheckEditorWindowGeneral(const AForm: TForm);
begin
  if Config.IDE.HideFormDesignerViewSelector then
    ModifyEditWindowViewSelector(AForm);
end;

procedure TIDETweaksWizard.ModifyEditWindowViewSelector(const AForm: TComponent);
var
  LViewSelector: TFrame;
begin
  LViewSelector := TFrame(AForm.FindChildComponent([cFormsEditWindowEditorFormDesigner, cFormsEditWindowViewSelector]));
  if LViewSelector <> nil then
    LViewSelector.Visible := False;
end;

procedure TIDETweaksWizard.CreateProjectTargetLabel;
var
  LComponent: TComponent;
  LTitleBarPanel: TWinControl;
begin
  if TOTAHelper.FindComponentGlobal('TitleBarPanel', LComponent) and (LComponent is TWinControl) then
  begin
    LTitleBarPanel := TWinControl(LComponent);
    FProjectTargetLabel := TLabel.Create(LTitleBarPanel.Owner);
    FProjectTargetLabel.AlignWithMargins := True;
    FProjectTargetLabel.Margins.SetBounds(0, 6, 0, 0);
    FProjectTargetLabel.Align := TAlign.alLeft;
    FProjectTargetLabel.Parent := LTitleBarPanel;
    UpdateProjectTargetLabel;
  end;
end;

procedure TIDETweaksWizard.CheckApplicationProperties;
var
  LDC: HDC;
  LTextSize: TSize;
  LSaveFont: HFONT;
begin
  if Application.Title <> FApplicationTitle then
  begin
    FApplicationTitle := Application.Title;
    if FProjectTargetLabel <> nil then
    begin
      LDC := GetDC(0);
      try
        LSaveFont := SelectObject(LDC, Application.MainForm.Font.Handle);
        GetTextExtentPoint32(LDC, FApplicationTitle, Length(FApplicationTitle), LTextSize);
        SelectObject(LDC, LSaveFont);
      finally
        ReleaseDC(0, LDC);
      end;
      FProjectTargetLabel.Margins.Left := LTextSize.cx + GetSystemMetrics(SM_CXSIZE) + 12;
    end;
  end;
  if Application.MainForm.Width <> FApplicationWidth then
    FApplicationWidth := Application.MainForm.Width;
end;

procedure TIDETweaksWizard.UpdateProjectTargetLabel;
var
  LProject: IOTAProject;
  LProperties: TProjectProperties;
  LPlatform: TProjectPlatform;
begin
  if FProjectTargetLabel <> nil then
  begin
    // Check if there is an active project - get current target etc
    LProject := TOTAHelper.GetActiveProject;
    if Config.IDE.ShowPlatformConfigCaption and (LProject <> nil) then
    begin
      LPlatform := TOTAHelper.GetProjectCurrentPlatform(LProject);
      LProperties.Platform := cProjectPlatformsLong[LPlatform];
      LProperties.Config := LProject.CurrentConfiguration;
      LProperties.BuildType := TOTAHelper.GetProjectCurrentBuildType(LProject);
      LProperties.Profile := TOTAHelper.GetProjectCurrentConnectionProfile(LProject);
      if ActiveProjectProperties.Update(LProperties) then
      begin
        FProjectTargetLabel.Caption := ActiveProjectProperties.GetCaption;
        FApplicationWidth := 0; // Force re-centre of the label
      end;
    end
    else
    begin
      ActiveProjectProperties.Clear;
      FProjectTargetLabel.Caption := '';
    end;
  end;
  CheckApplicationProperties;
end;

procedure TIDETweaksWizard.HookBaseActionList2;
var
  LComponent: TComponent;
  LBaseActionList2: TActionList;
begin
  if TOTAHelper.FindComponentGlobal('BaseActionList2', LComponent) and (LComponent is TActionList) then
  begin
    LBaseActionList2 := TActionList(LComponent);
    if not Assigned(LBaseActionList2.OnUpdate) then
      LBaseActionList2.OnUpdate := BaseActionList2UpdateHandler;
  end
  else
    TOSLog.d('Did not find BaseActionList2 or is not TActionList');
end;

procedure TIDETweaksWizard.BaseActionList2UpdateHandler(Sender: TBasicAction; var AHandled: Boolean);
begin
  if Config.IDE.EnableEditorContextReadOnlyMenuItem and (Sender.Name = 'ecReadOnlyItem') and (Sender is TAction) then
  begin
    Sender.OnUpdate(Sender);
    TAction(Sender).Enabled := True;
    AHandled := True;
  end;
end;

procedure TIDETweaksWizard.RunRunCommandExecuteHandler(Sender: TObject);
begin
  // Check current build type
  if not ActiveProjectProperties.IsDistributionBuildType or
    TDialog.Confirm(Format(Babel.Tx(sConfirmContinueWithDistBuildType), [ActiveProjectProperties.GetLongBuildType]), False) then
  begin
    FRunRunCommandExecuteEvent(Sender);
  end;
end;

procedure TIDETweaksWizard.TrustProjectBuildEvents(const AProject: IOTAProject);
var
  LProjectName: string;
begin
  if TOTAHelper.HasBuildEvents(AProject) then
  begin
    LProjectName := TOTAHelper.GetProjectActiveBuildConfigurationValue(AProject, sSanitizedProjectName);
    if FBDSRegistry.OpenSubKey('\Compiling\TrustedBuildEvents', True) then
    try
      FBDSRegistry.WriteString(AProject.ProjectGUID.ToString, LProjectName);
    finally
      FBDSRegistry.CloseKey;
    end;
  end;
end;

initialization
  TOTAWizard.RegisterWizard(TIDETweaksWizard);

end.