unit Codex.Project.DeployExtensionsView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  Codex.BaseView, System.Actions, Vcl.ActnList, Vcl.WinXCtrls;

type
  TDeployExtensionsView = class(TForm)
    CommandButtonsPanel: TPanel;
    CancelButton: TButton;
    OKButton: TButton;
    ExtensionsListView: TListView;
    ActionList: TActionList;
    OKAction: TAction;
    procedure OKActionExecute(Sender: TObject);
    procedure OKActionUpdate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FActivityIndicator: TActivityIndicator;
    FAppExtensions: TArray<string>;
    procedure GetAppExtensions;
    procedure LoadAppExtensions(const AExtensions: TArray<string>);
    procedure RepositionActivityIndicator;
    procedure ShowWaiting(const AShow: Boolean);
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  DeployExtensionsView: TDeployExtensionsView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  ToolsAPI, BrandingAPI,
  Vcl.GraphUtil,
  Codex.Core, Codex.Consts.Text, Codex.OTA.Helpers;

{ TDeployExtensionsView }

constructor TDeployExtensionsView.Create(AOwner: TComponent);
begin
  inherited;
  FActivityIndicator := TActivityIndicator.Create(Self);
  FActivityIndicator.IndicatorSize := aisLarge;
  FActivityIndicator.Visible := False;
  FActivityIndicator.Parent := Self;
  if ThemeProperties <> nil then
  begin
    if not ColorIsBright(ThemeProperties.MainToolBarColor) then
      FActivityIndicator.IndicatorColor := aicWhite;
  end;
end;

procedure TDeployExtensionsView.DoShow;
begin
  if not IsShown then
  begin
    RepositionActivityIndicator;
    ShowWaiting(True);
    TThread.CreateAnonymousThread(GetAppExtensions).Start;
  end;
  inherited;
end;

procedure TDeployExtensionsView.RepositionActivityIndicator;
begin
  if (FActivityIndicator <> nil) and FActivityIndicator.Visible then
  begin
    FActivityIndicator.Top := (ClientHeight div 2) - (FActivityIndicator.Height div 2);
    FActivityIndicator.Left := (ClientWidth div 2) - (FActivityIndicator.Width div 2);
  end;
end;

procedure TDeployExtensionsView.FormResize(Sender: TObject);
begin
  RepositionActivityIndicator;
end;

procedure TDeployExtensionsView.GetAppExtensions;
var
  LExtensions: TArray<string>;
begin
  LExtensions := MoscoProvider.GetAppExtensionNames;
  TThread.Synchronize(nil, procedure begin LoadAppExtensions(LExtensions) end);
end;

procedure TDeployExtensionsView.LoadAppExtensions(const AExtensions: TArray<string>);
var
  LExtension: string;
  LItem: TListItem;
  LParts: TArray<string>;
begin
  FAppExtensions := AExtensions;
  ExtensionsListView.Items.Clear;
  for LExtension in FAppExtensions do
  begin
    LParts := LExtension.Split(['|']);
    LItem := ExtensionsListView.Items.Add;
    LItem.Caption := TPath.GetFileName(LParts[0]);
    LItem.SubItems.Add(TPath.GetFileName(LParts[1]));
  end;
  ShowWaiting(False);
end;

procedure TDeployExtensionsView.OKActionExecute(Sender: TObject);
var
  I: Integer;
  LExtensions, LParts: TArray<string>;
begin
  for I := 0 to ExtensionsListView.Items.Count - 1 do
  begin
    if ExtensionsListView.Items[I].Selected then
    begin
      LParts := FAppExtensions[I].Split(['|']);
      LExtensions := LExtensions + [LParts[1]];
    end;
  end;
  MoscoProvider.GetAppExtensionFiles(LExtensions);
  // If it fails, the focus might want to remain on the view?
  ModalResult := mrOk;
end;

procedure TDeployExtensionsView.OKActionUpdate(Sender: TObject);
begin
  OKAction.Enabled := ExtensionsListView.SelCount > 0;
end;

procedure TDeployExtensionsView.ShowWaiting(const AShow: Boolean);
begin
  {$IF CompilerVersion > 35}
  if AShow then
    TCodexOTAHelper.ShowWait(Babel.Tx(sFetchingAppExtensions))
  else
    TCodexOTAHelper.HideWait;
  {$ELSE}
  FActivityIndicator.Animate := AShow;
  FActivityIndicator.Visible := AShow;
  RepositionActivityIndicator;
  {$ENDIF}
end;

end.
