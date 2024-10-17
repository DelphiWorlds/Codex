unit Codex.Mosco.OptionsView;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Actions, System.JSON,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ActnList, Vcl.Samples.Spin,
  Mosco.RESTClient, Mosco.API,
  Codex.Options;

type
  TMoscoOptionsView = class(TForm, IConfigOptionsSection)
    RootPanel: TPanel;
    ActionList: TActionList;
    ServerTestAction: TAction;
    OKAction: TAction;
    ServerLabel: TLabel;
    ServerPanel: TPanel;
    ServerHostPanel: TPanel;
    HostEdit: TEdit;
    ServerPortPanel: TPanel;
    ServerPortLabel: TLabel;
    PortEdit: TEdit;
    ErrorsPanel: TPanel;
    ErrorsDiagnosticCheckBox: TCheckBox;
    ErrorsInMessagesCheckBox: TCheckBox;
    ErrorsLabel: TLabel;
    OthersLabel: TLabel;
    OthersPanel: TPanel;
    DisableLockCheckCheckBox: TCheckBox;
    ServerTimeoutPanel: TPanel;
    ServerTimeoutLabel: TLabel;
    ServerTimeoutEdit: TSpinEdit;
    ServerTestButton: TButton;
    CertWarningPanel: TPanel;
    CertWarnEdit: TSpinEdit;
    CertWarnCheckBox: TCheckBox;
    CheckValidProfileCheckBox: TCheckBox;
    AutoFillMacCertsCheckBox: TCheckBox;
    ServerDetailsPanel: TPanel;
    ServerTestPanel: TPanel;
    ProfilePanel: TPanel;
    ProfileRadioButton: TRadioButton;
    HostRadioButton: TRadioButton;
    ProfileLabel: TLabel;
    procedure ServerTestActionExecute(Sender: TObject);
    procedure ServerTestActionUpdate(Sender: TObject);
    procedure OKActionUpdate(Sender: TObject);
    procedure ErrorsInMessagesCheckBoxClick(Sender: TObject);
    procedure HostRadioButtonClick(Sender: TObject);
    procedure ProfileRadioButtonClick(Sender: TObject);
  private
    FClient: TMoscoRESTClient;
    FProfile: string;
    function CanTest: Boolean;
    procedure CreateClient;
    function GetProfileHost: string;
    procedure DestroyClient;
    procedure ShowPingResult(const AVersion: string);
  public
    { IConfigOptionsSection }
    function GetRootControl: TControl;
    function SectionID: string;
    function SectionTitle: string;
    procedure Save;
    procedure ShowSection;
  public
    destructor Destroy; override;
  end;

var
  MoscoOptionsView: TMoscoOptionsView;

implementation

{$R *.dfm}

uses
  DW.Classes.Helpers, DW.OTA.Registry,
  Codex.Mosco.Consts, Codex.Config, Codex.Core, Codex.ProgressView, Codex.Mosco.Helpers, Codex.Consts.Text;

{ TOptionsView }

destructor TMoscoOptionsView.Destroy;
begin
  FClient.Free;
  inherited;
end;

procedure TMoscoOptionsView.CreateClient;
begin
  FClient := TMoscoRESTClient.Create;
end;

procedure TMoscoOptionsView.DestroyClient;
begin
  FClient.Free;
  FClient := nil;
end;

function TMoscoOptionsView.CanTest: Boolean;
begin
  Result := False;
  if StrToIntDef(PortEdit.Text, 0) > 0 then
  begin
    if ProfileRadioButton.Checked then
      Result := not GetProfileHost.IsEmpty
    else if HostRadioButton.Checked then
      Result := not string(HostEdit.Text).IsEmpty;
  end
end;

procedure TMoscoOptionsView.ShowSection;
var
  LCertWarn: Boolean;
  LRegistry: TBDSRegistry;
  LProfileHost: string;
begin
  inherited;
  LRegistry := TBDSRegistry.Current;
  FProfile := LRegistry.GetDefaultRemoteProfileName('OSX64');
  if not FProfile.IsEmpty then
    LProfileHost := GetProfileHost
  else
    LProfileHost := '';
  if not LProfileHost.IsEmpty then
    ProfileLabel.Caption := Format(Babel.Tx(sCurrentProfileWithHost), [FProfile, LProfileHost])
  else if not FProfile.IsEmpty then
    ProfileLabel.Caption := Format(Babel.Tx(sCurrentProfileNoHost), [FProfile]);
  ProfileRadioButton.Enabled := not LProfileHost.IsEmpty;
  HostEdit.Text := Config.Mosco.Host;
  if Config.Mosco.UseProfile then
  begin
    ProfileRadioButton.Checked := not LProfileHost.IsEmpty;
    HostRadioButton.Checked := not ProfileRadioButton.Checked;
  end
  else
  begin
    HostRadioButton.Checked := True;
    ProfileRadioButton.Checked := False;
  end;
  LCertWarn := Config.Mosco.CertExpiryWarnDays > -1;
  CertWarnCheckBox.Checked := LCertWarn;
  CertWarnEdit.Visible := LCertWarn;
  if LCertWarn then
    CertWarnEdit.Value := Config.Mosco.CertExpiryWarnDays
  else
    CertWarnEdit.Value := 7;
  AutoFillMacCertsCheckBox.Checked := Config.Mosco.AutoFillMacCerts;
  CheckValidProfileCheckBox.Checked := Config.Mosco.CheckValidProfile;
  DisableLockCheckCheckBox.Checked := Config.Mosco.DisableLockCheck;
  ErrorsInMessagesCheckBox.Checked := Config.Mosco.ErrorsInMessages;
  ErrorsDiagnosticCheckBox.Checked := Config.Mosco.ErrorsDiagnostic;
  PortEdit.Text := Config.Mosco.Port.ToString;
  ServerTimeoutEdit.Value := Round(Config.Mosco.ServerTimeout / 1000);
end;

procedure TMoscoOptionsView.ErrorsInMessagesCheckBoxClick(Sender: TObject);
begin
  ErrorsDiagnosticCheckBox.Enabled := ErrorsInMessagesCheckBox.Checked;
  if not ErrorsInMessagesCheckBox.Checked then
    ErrorsDiagnosticCheckBox.Checked := False;
end;

function TMoscoOptionsView.GetProfileHost: string;
begin
  if not FProfile.IsEmpty then
    Result := TBDSRegistry.Current.GetRemoteProfileValue(FProfile, 'HostName')
  else
    Result := '';
end;

function TMoscoOptionsView.GetRootControl: TControl;
begin
  Result := RootPanel;
end;

procedure TMoscoOptionsView.HostRadioButtonClick(Sender: TObject);
begin
  if HostRadioButton.Checked then
    ProfileRadioButton.Checked := False;
end;

procedure TMoscoOptionsView.ProfileRadioButtonClick(Sender: TObject);
begin
  if ProfileRadioButton.Checked then
    HostRadioButton.Checked := False;
end;

procedure TMoscoOptionsView.OKActionUpdate(Sender: TObject);
begin
  OKAction.Enabled := CanTest;
end;

procedure TMoscoOptionsView.Save;
begin
  if CertWarnCheckBox.Checked then
    Config.Mosco.CertExpiryWarnDays := CertWarnEdit.Value
  else
    Config.Mosco.CertExpiryWarnDays := -1;
  Config.Mosco.AutoFillMacCerts := AutoFillMacCertsCheckBox.Checked;
  Config.Mosco.CheckValidProfile := CheckValidProfileCheckBox.Checked;
  Config.Mosco.DisableLockCheck := DisableLockCheckCheckBox.Checked;
  Config.Mosco.ErrorsInMessages := ErrorsInMessagesCheckBox.Checked;
  Config.Mosco.ErrorsDiagnostic := ErrorsDiagnosticCheckBox.Checked;
  Config.Mosco.UseProfile := ProfileRadioButton.Checked;
  Config.Mosco.Host := HostEdit.Text;
  Config.Mosco.Port := StrToInt(PortEdit.Text);
  Config.Mosco.ServerTimeout := ServerTimeoutEdit.Value * 1000;
end;

function TMoscoOptionsView.SectionID: string;
begin
  Result := cMoscoOptionsSectionID;
end;

function TMoscoOptionsView.SectionTitle: string;
begin
  Result := cMoscoOptionsSectionTitle;
end;

procedure TMoscoOptionsView.ServerTestActionExecute(Sender: TObject);
var
  LVersion: string;
begin
  if FClient = nil then
    CreateClient;
  if ProfileRadioButton.Checked then
    FClient.Host := GetProfileHost
  else if HostRadioButton.Checked then
    FClient.Host := HostEdit.Text
  else
    FClient.Host := string.Empty;
  if not FClient.Host.IsEmpty then
  begin
    FClient.Port := StrToIntDef(PortEdit.Text, 8080);
    if FClient.GetVersion(LVersion) then
      ShowPingResult(LVersion)
    else
      ProgressView.ShowStatic(Babel.Tx(sConnectionTestTitle), Babel.Tx(sConnectionTestUnableToConnect));
  end
  else
    ProgressView.ShowStatic(Babel.Tx(sConnectionTestTitle), Babel.Tx(sConnectionTestCannotDetermineHost));
end;

procedure TMoscoOptionsView.ShowPingResult(const AVersion: string);
begin
  ProgressView.ShowStatic(Babel.Tx(sConnectionTestTitle), Format(Babel.Tx(sConnectionTestConnected), [AVersion]));
  DestroyClient;
end;

procedure TMoscoOptionsView.ServerTestActionUpdate(Sender: TObject);
begin
  ServerTestAction.Enabled := CanTest;
end;

initialization
  TConfigOptionsHelper.RegisterOptions(TMoscoOptionsView);

end.
