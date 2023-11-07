unit Codex.Android.ADBConnectView;

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

{$SCOPEDENUMS ON}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Mask,
  DW.RunProcess.Win,
  Codex.BaseView,
  Codex.SDKRegistry, Codex.IPAddressView;

type
  TADBProcessStep = (None, KillServer, Connect, Devices, Connected);
  TADBProcessSuccess = set of TADBProcessStep;

  TADBConnectView = class(TForm)
    ReminderLabel: TLabel;
    IPAddressLabel: TLabel;
    ButtonsPanel: TPanel;
    CloseButton: TButton;
    ConnectButton: TButton;
    DismissCheckBox: TCheckBox;
    IPPanel: TPanel;
    OutputMemo: TMemo;
    IPComboBox: TComboBox;
    RecentIPLabel: TLabel;
    IPAddressPanel: TPanel;
    procedure CloseButtonClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ConnectButtonClick(Sender: TObject);
    procedure IPComboBoxChange(Sender: TObject);
  private
    FADBProcess: TRunProcess;
    FIPAddress: TIPAddressView;
    FSDKRegistry: TSDKRegistry;
    FStep: TADBProcessStep;
    FSuccess: TADBProcessSuccess;
    procedure ADBProcessOutputHandler(Sender: TObject; const AOutput: string);
    procedure ADBProcessTerminatedHandler(Sender: TObject; const AExitCode: Cardinal);
    procedure Connect;
    procedure ProcessFinished;
    procedure RunADB;
    procedure SelectAndroidPlatform;
    procedure ShowFailure(const AExitCode: Cardinal);
    procedure ShowSuccess;
    procedure UpdateMRU;
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  ADBConnectView: TADBConnectView;

implementation

{$R *.dfm}

uses
  System.IOUtils, System.StrUtils,
  ToolsAPI,
  VCL.ActnList,
  DW.OTA.Helpers, DW.OTA.Consts, DW.OTA.Types,
  Codex.Config, Codex.Core;

resourcestring
  sExecuting = 'Executing';
  sCommandFailed = 'The command: %s failed with an exit code of: %d';
  sSucceededNotConnected = 'All commands succeeded, however device connection was not detected';
  sConnectedSuccessfully = 'Connected successfully with device at: %s';

{ TADBConnectView }

constructor TADBConnectView.Create(AOwner: TComponent);
begin
  inherited;
  FSDKRegistry := TSDKRegistry.Current;
  FADBProcess := TRunProcess.Create;
  FADBProcess.OnProcessOutput := ADBProcessOutputHandler;
  FADBProcess.OnProcessTerminated := ADBProcessTerminatedHandler;
  DismissCheckBox.Checked := Config.Android.ADBConnect.DismissOnSuccess;
  FIPAddress := TIPAddressView.Create(Self);
  FIPAddress.Align := alClient;
  FIPAddress.Parent := IPAddressPanel;
  FIPAddress.IP := Config.Android.ADBConnect.IP;
  FIPAddress.Port := Config.Android.ADBConnect.Port;
  UpdateMRU;
end;

destructor TADBConnectView.Destroy;
begin
  FADBProcess.Free;
  inherited;
end;

procedure TADBConnectView.DoShow;
begin
  if not IsShown then
    FIPAddress.IPByte1Edit.SetFocus;
  inherited;
end;

procedure TADBConnectView.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Config.Android.ADBConnect.DismissOnSuccess := DismissCheckBox.Checked;
  Config.Save;
end;

procedure TADBConnectView.IPComboBoxChange(Sender: TObject);
var
  LIPParts: TArray<string>;
begin
  LIPParts := IPComboBox.Items[IPComboBox.ItemIndex].Split([':']);
  FIPAddress.IP := LIPParts[0].Trim;
  FIPAddress.Port := LIPParts[1].Trim;
end;

procedure TADBConnectView.ProcessFinished;
begin
  FStep := TADBProcessStep.None;
end;

procedure TADBConnectView.RunADB;
var
  LADBPath: string;
begin
  LADBPath := FSDKRegistry.GetADBPath;
  case FStep of
    TADBProcessStep.KillServer:
      FADBProcess.CommandLine := Format('%s kill-server', [LADBPath]);
    TADBProcessStep.Connect:
      FADBProcess.CommandLine := Format('%s connect %s:%s', [LADBPath, FIPAddress.IP, FIPAddress.Port]);
    TADBProcessStep.Devices:
      FADBProcess.CommandLine := Format('%s devices', [LADBPath]);
  else
    Exit;
  end;
  OutputMemo.Lines.Add(Babel.Tx(sExecuting) + ': ' + FADBProcess.CommandLine);
  FADBProcess.Run;
end;

procedure TADBConnectView.ShowFailure(const AExitCode: Cardinal);
begin
  ProcessFinished;
  if AExitCode <> 0 then
  begin
    MessageDlg(Format(Babel.Tx(sCommandFailed), [FADBProcess.CommandLine, AExitCode]),
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
  end
  else
    MessageDlg(Babel.Tx(sSucceededNotConnected), TMsgDlgType.mtWarning, [TMsgDlgBtn.mbOK], 0);
end;

procedure TADBConnectView.SelectAndroidPlatform;
var
  LProject: IOTAProject;
  LAndroidPlatform: string;
begin
  LProject := TOTAHelper.GetActiveProject;
  LAndroidPlatform := cProjectPlatformsIDE[TProjectPlatform.Android32];
  if (LProject <> nil) and (IndexStr(LAndroidPlatform, LProject.SupportedPlatforms) > -1) then
    LProject.CurrentPlatform := LAndroidPlatform;
end;

procedure TADBConnectView.ShowSuccess;
var
  LAction: TCustomAction;
begin
  ProcessFinished;
  if Config.Android.ADBConnect.SelectAndroidOnSuccess then
    SelectAndroidPlatform;
  if TOTAHelper.FindActionGlobal('ActionRefreshDevicesToolbar', LAction) then
    LAction.Execute;
  Config.Android.ADBConnect.AddMRU(FIPAddress.IP, FIPAddress.Port);
  UpdateMRU;
  if DismissCheckBox.Checked then
    Close
  else
    MessageDlg(Format(Babel.Tx(sConnectedSuccessfully), [FIPAddress.IP]), TMsgDlgType.mtInformation, [TMsgDlgBtn.mbOK], 0);
end;

procedure TADBConnectView.UpdateMRU;
begin
  IPComboBox.Items.Clear;
  IPComboBox.Items.AddStrings(Config.Android.ADBConnect.MRU);
  if IPComboBox.Items.Count > 0 then
    IPComboBox.ItemIndex := 0;
end;

procedure TADBConnectView.ADBProcessOutputHandler(Sender: TObject; const AOutput: string);
begin
  case FStep of
    TADBProcessStep.Connect:
    begin
      OutputMemo.Lines.Add(AOutput);
      if AOutput.StartsWith('connected to ' + FIPAddress.IP) then
        Include(FSuccess, TADBProcessStep.Connect)
      else if AOutput.StartsWith('failed to connect to ' + FIPAddress.IP) then
        FStep := TADBProcessStep.None;
    end;
    TADBProcessStep.Devices:
    begin
      OutputMemo.Lines.Add(AOutput);
      if AOutput.Contains('devices attached') then
        Include(FSuccess, TADBProcessStep.Devices);
      if AOutput.StartsWith(FIPAddress.IP) then
        Include(FSuccess, TADBProcessStep.Connected);
    end;
  end;
end;

procedure TADBConnectView.ADBProcessTerminatedHandler(Sender: TObject; const AExitCode: Cardinal);
begin
  if AExitCode = 0 then
  begin
    if not (FStep in [TADBProcessStep.None, TADBProcessStep.Devices]) then
    begin
      FStep := Succ(FStep);
      RunADB;
    end
    else if TADBProcessStep.Connected in FSuccess then
      ShowSuccess
    else
      ShowFailure(0);
  end
  else
    ShowFailure(AExitCode);
end;

procedure TADBConnectView.CloseButtonClick(Sender: TObject);
begin
  FADBProcess.Terminate;
  Close;
end;

procedure TADBConnectView.Connect;
begin
  OutputMemo.Lines.Clear;
  ConnectButton.Enabled := False;
  FSuccess := [];
  FStep := TADBProcessStep.KillServer;
  RunADB;
end;

procedure TADBConnectView.ConnectButtonClick(Sender: TObject);
begin
  Connect;
end;

end.
