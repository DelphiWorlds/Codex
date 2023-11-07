unit Codex.IDEOptionsView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  Codex.BaseView,
  Codex.Options;

type
  TIDEOptionsView = class(TForm, IConfigOptionsSection)
    RootPanel: TPanel;
    ShowProjectManagerCheckBox: TCheckBox;
    RunRunInterceptCheckBox: TCheckBox;
    ShowPlatformConfigPathCheckBox: TCheckBox;
    StartupLoadLastProjectCheckbox: TCheckBox;
    HideViewSelectorCheckBox: TCheckBox;
    ChangesNeedRestartLabel: TLabel;
    EnableReadOnlyEditorMenuItemCheckBox: TCheckBox;
    SuppressBuildEventsWarningCheckBox: TCheckBox;
    ShowErrorInsightMessagesCheckBox: TCheckBox;
    KillProjectProcessCheckBox: TCheckBox;
    SysJarsWarningCheckBox: TCheckBox;
  public
    { IConfigOptionsSection }
    function GetRootControl: TControl;
    function SectionID: string;
    function SectionTitle: string;
    procedure Save;
    procedure ShowSection;
  end;

var
  IDEOptionsView: TIDEOptionsView;

implementation

{$R *.dfm}

uses
  Codex.Config;

{ TIDEOptionsView }

function TIDEOptionsView.GetRootControl: TControl;
begin
  Result := RootPanel;
end;

procedure TIDEOptionsView.Save;
begin
  Config.IDE.DisplayWarningOnRunForAppStoreBuild := RunRunInterceptCheckBox.Checked;
  Config.IDE.DisplayWarningWhenSysJarsNotFound := SysJarsWarningCheckBox.Checked;
  Config.IDE.EnableEditorContextReadOnlyMenuItem := EnableReadOnlyEditorMenuItemCheckBox.Checked;
  Config.IDE.HideFormDesignerViewSelector := HideViewSelectorCheckBox.Checked;
  Config.IDE.KillProjectProcess := KillProjectProcessCheckBox.Checked;
  Config.IDE.LoadProjectLastOpened := StartupLoadLastProjectCheckbox.Checked;
  Config.IDE.ShowErrorInsightMessages := ShowErrorInsightMessagesCheckBox.Checked;
  Config.IDE.ShowPlatformConfigCaption := ShowPlatformConfigPathCheckBox.Checked;
  Config.IDE.ShowProjectManagerOnProjectOpen := ShowProjectManagerCheckBox.Checked;
  Config.IDE.SuppressBuildEventsWarning := SuppressBuildEventsWarningCheckBox.Checked;
end;

function TIDEOptionsView.SectionID: string;
begin
  Result := 'IDE';
end;

function TIDEOptionsView.SectionTitle: string;
begin
  Result := 'IDE';
end;

procedure TIDEOptionsView.ShowSection;
begin
  RunRunInterceptCheckBox.Checked := Config.IDE.DisplayWarningOnRunForAppStoreBuild;
  SysJarsWarningCheckBox.Checked := Config.IDE.DisplayWarningWhenSysJarsNotFound;
  EnableReadOnlyEditorMenuItemCheckBox.Checked := Config.IDE.EnableEditorContextReadOnlyMenuItem;
  HideViewSelectorCheckBox.Checked := Config.IDE.HideFormDesignerViewSelector;
  KillProjectProcessCheckBox.Checked := Config.IDE.KillProjectProcess;
  StartupLoadLastProjectCheckbox.Checked := Config.IDE.LoadProjectLastOpened;
  ShowErrorInsightMessagesCheckBox.Checked := Config.IDE.ShowErrorInsightMessages;
  ShowPlatformConfigPathCheckBox.Checked := Config.IDE.ShowPlatformConfigCaption;
  ShowProjectManagerCheckBox.Checked := Config.IDE.ShowProjectManagerOnProjectOpen;
  SuppressBuildEventsWarningCheckBox.Checked := Config.IDE.SuppressBuildEventsWarning;
end;

initialization
  TConfigOptionsHelper.RegisterOptions(TIDEOptionsView);

end.
