unit Codex.Android.SDKToolsView;

{*******************************************************}
{                                                       }
{                      Codex                            }
{                                                       }
{         Add-in for Delphi from Delphi Worlds          }
{                                                       }
{  Copyright 2020-2024 Dave Nottage under MIT license   }
{  which is located in the root folder of this library  }
{                                                       }
{*******************************************************}

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Actions,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.ExtCtrls, Vcl.WinXCtrls, Vcl.ActnList, Vcl.ComCtrls,
  Codex.BaseView, Codex.Android.SDKToolsProcess;

type
  TSDKToolsView = class(TForm)
    CommandButtonsPanel: TPanel;
    CloseButton: TButton;
    ActionList: TActionList;
    InstallAction: TAction;
    AddAVDAction: TAction;
    DeleteAVDAction: TAction;
    StartAVDAction: TAction;
    InstallButton: TButton;
    APILevelsLabel: TLabel;
    APILevelsCheckListBox: TCheckListBox;
    ProgressBar: TProgressBar;
    procedure FormResize(Sender: TObject);
    procedure InstallActionExecute(Sender: TObject);
    procedure InstallActionUpdate(Sender: TObject);
    procedure CloseButtonClick(Sender: TObject);
  private
    FActivityIndicator: TActivityIndicator;
    FProcess: TSDKToolsProcess;
    procedure ProcessInstallProgressHandler(Sender: TObject; const APercent: Integer);
    procedure ProcessStepCompleteHandler(Sender: TObject);
    procedure RepositionActivityIndicator;
    procedure ShowWaiting(const AShow: Boolean; const AText: string = '');
    procedure UpdateCheckListBox;
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  SDKToolsView: TSDKToolsView;

implementation

uses
  DW.OSLog,
  System.IOUtils, System.StrUtils,
  BrandingAPI,
  Vcl.GraphUtil,
  DW.Vcl.ListBoxHelper,
  Codex.OTA.Helpers, Codex.Core, Codex.Consts.Text, Codex.SDKRegistry;

{$R *.dfm}

{ TSDKToolsView }

constructor TSDKToolsView.Create(AOwner: TComponent);
begin
  inherited;
  FProcess := TSDKToolsProcess.Create;
  FProcess.OnInstallProgress := ProcessInstallProgressHandler;
  FProcess.OnStepComplete := ProcessStepCompleteHandler;
  FActivityIndicator := TActivityIndicator.Create(Self);
  FActivityIndicator.Visible := False;
  FActivityIndicator.Parent := Self;
  FActivityIndicator.IndicatorSize := aisLarge;
end;

destructor TSDKToolsView.Destroy;
begin
  FProcess.Free;
  inherited;
end;

procedure TSDKToolsView.CloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TSDKToolsView.DoShow;
begin
  if ThemeProperties <> nil then
  begin
    {$IF CompilerVersion > 36}
    if not ColorIsBright(ThemeProperties.MainWindow.Color) then
      FActivityIndicator.IndicatorColor := aicWhite;
    {$ELSE}
    if not ColorIsBright(ThemeProperties.MainToolBarColor) then
      FActivityIndicator.IndicatorColor := aicWhite;
    {$ENDIF}
  end;
  FProcess.SDKFolder := TSDKRegistry.Current.GetSDKPath;
  if not IsShown then
  begin
    RepositionActivityIndicator;
    ShowWaiting(True, Babel.Tx(sFetchingAPILevels));
    FProcess.FetchPackages;
  end;
  inherited;
end;

procedure TSDKToolsView.FormResize(Sender: TObject);
begin
  RepositionActivityIndicator;
end;

procedure TSDKToolsView.InstallActionExecute(Sender: TObject);
begin
  ProgressBar.Position := 0;
  ShowWaiting(True, Babel.Tx(sInstallingAPILevels));
  FProcess.InstallAPILevels(APILevelsCheckListBox.CheckedItems);
end;

procedure TSDKToolsView.InstallActionUpdate(Sender: TObject);
begin
  InstallAction.Enabled := APILevelsCheckListBox.CheckedCount > 0;
end;

procedure TSDKToolsView.ProcessInstallProgressHandler(Sender: TObject; const APercent: Integer);
begin
  ProgressBar.Position := APercent;
end;

procedure TSDKToolsView.ProcessStepCompleteHandler(Sender: TObject);
begin
  ShowWaiting(False);
  ProgressBar.Position := 0;
  case FProcess.SDKToolsStep of
    TSDKToolsStep.Fetch:
      UpdateCheckListBox;
    TSDKToolsStep.Install:
      UpdateCheckListBox;
  end;
end;

procedure TSDKToolsView.RepositionActivityIndicator;
begin
  if (FActivityIndicator <> nil) and FActivityIndicator.Visible then
  begin
    FActivityIndicator.Top := (ClientHeight div 2) - (FActivityIndicator.Height div 2);
    FActivityIndicator.Left := (ClientWidth div 2) - (FActivityIndicator.Width div 2);
  end;
end;

procedure TSDKToolsView.ShowWaiting(const AShow: Boolean; const AText: string = '');
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

procedure TSDKToolsView.UpdateCheckListBox;
var
  LItem: TSDKPackageItem;
  LAPILevel: string;
begin
  APILevelsCheckListBox.Items.BeginUpdate;
  try
    APILevelsCheckListBox.Items.Clear;
    for LItem in FProcess.Packages do
    begin
      if LItem.Kind = TSDKPackageKind.APILevel then
      begin
        LAPILevel := LItem.Package.Split([';'])[1];
        APILevelsCheckListBox.Items.Add(LAPILevel);
        APILevelsCheckListBox.ItemEnabled[APILevelsCheckListBox.Items.Count - 1] := not LItem.IsInstalled;
      end;
    end;
  finally
    APILevelsCheckListBox.Items.EndUpdate;
  end;
end;

end.
