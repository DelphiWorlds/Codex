unit Codex.AboutView;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Imaging.pngimage,
  DW.Vcl.ExtendedLabel,
  Codex.BaseView;

type
  TAboutView = class(TForm)
    BottomBevel: TBevel;
    LogoPanel: TPanel;
    ButtonsPanel: TPanel;
    OKButton: TButton;
    LicenseButton: TButton;
    InfoPanel: TPanel;
    VersionLabel: TLabel;
    CodexLabel: TLabel;
    UpperBevel: TBevel;
    VersionEdit: TEdit;
    CopyrightLabel: TLabel;
    WebLabel: TLabel;
    SlackLabel: TLabel;
    VersionPanel: TPanel;
    IssuesLabel: TLabel;
    CreditsLabel: TLabel;
    CreditsMemo: TMemo;
    LogoImage: TImage;
    WebSitePanel: TPanel;
    WebSitePanelLabel: TLabel;
    IssuesPanel: TPanel;
    IssuesPanelLabel: TLabel;
    SupportPanel: TPanel;
    SupportPanelLabel: TLabel;
    procedure WebLabelClick(Sender: TObject);
    procedure SlackLabelClick(Sender: TObject);
    procedure IssuesLabelClick(Sender: TObject);
  private
    procedure OpenURL(const AURL: string);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  AboutView: TAboutView;

implementation

{$R *.dfm}

uses
  BrandingAPI,
  DW.OSDevice.Win, DW.OTA.Wizard, DW.OTA.Helpers,
  Winapi.ShellAPI;

const
  cCodexURL = 'https://www.delphiworlds.com/codex';
  cCodexIssuesURL = 'https://github.com/DelphiWorlds/Codex/issues';
  cSlackURL = 'https://slack.delphiworlds.com';

{ TAboutView }

constructor TAboutView.Create(AOwner: TComponent);
begin
  inherited;
  CodexLabel.Font.Color := StrToInt('$401FE0');
  WebLabel.Font.Color := ThemeProperties.LinkColor;
  SlackLabel.Font.Color := ThemeProperties.LinkColor;
  IssuesLabel.Font.Color := ThemeProperties.LinkColor;
  VersionEdit.Text := TOTAWizard.GetWizardVersion;
  CopyrightLabel.Caption := CopyrightLabel.Caption + Format(' (%s)', [TPlatformOSDevice.GetCurrentLocaleInfo.LanguageCode]);
end;

procedure TAboutView.OpenURL(const AURL: string);
begin
  ShellExecute(0, 'open', PChar(AURL), nil, nil, SW_SHOWNORMAL);
end;

procedure TAboutView.IssuesLabelClick(Sender: TObject);
begin
  OpenURL(cCodexIssuesURL);
end;

procedure TAboutView.SlackLabelClick(Sender: TObject);
begin
  OpenURL(cSlackURL);
end;

procedure TAboutView.WebLabelClick(Sender: TObject);
begin
  OpenURL(cCodexURL);
end;

end.
