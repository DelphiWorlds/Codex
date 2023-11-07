unit Codex.ProgressView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons, Vcl.ComCtrls,
  Codex.BaseView;

type
  TProgressView = class(TForm)
    BottomPanel: TPanel;
    ProgressBar: TProgressBar;
    StatusLabel: TLabel;
    CancelButton: TButton;
    procedure FormResize(Sender: TObject);
    procedure CancelButtonClick(Sender: TObject);
  private
    FActiveForm: Vcl.Forms.TForm;
    FCancelProc: TProc;
    FShouldActModal: Boolean;
    FStoredHeight: Integer;
    FWasActiveFormEnabled: Boolean;
    procedure HideProgressBar;
    procedure InternalDismiss;
    procedure UpdateCancelPanel;
    procedure UpdateCancelProc(const ACancelProc: TProc; const AIsClose: Boolean);
    procedure UpdateFormSize;
    procedure UpdateProgressBar(const AProgress: Integer);
  public
    procedure Dismiss;
    function GetShouldActModal: Boolean;
    procedure SetShouldActModal(const Value: Boolean);
    procedure ShowStatic(const AStatus: string; const ACloseProc: TProc = nil); overload;
    procedure ShowStatic(const ATitle, AStatus: string; const ACloseProc: TProc = nil); overload;
    procedure ShowProgress(const AStatus: string); overload;
    procedure ShowProgress(const AStatus: string; const ACancelProc: TProc); overload;
    procedure ShowProgress(const AStatus: string; const AProgress: Integer); overload;
    procedure ShowProgress(const ATitle, AStatus: string); overload;
    procedure ShowProgress(const ATitle, AStatus: string; const AProgress: Integer); overload;
    procedure ShowProgress(const ATitle, AStatus: string; const ACancelProc: TProc); overload;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  ProgressView: TProgressView;

implementation

{$R *.dfm}

uses
  DW.OTA.Helpers,
  DW.OSLog,
  Codex.Core, Codex.Consts.Text;

{ TProgressView }

constructor TProgressView.Create(AOwner: TComponent);
begin
  inherited;
  TOTAHelper.ApplyTheme(Self);
  Caption := '';
  FStoredHeight := ClientHeight;
  HideProgressBar;
end;

procedure TProgressView.FormResize(Sender: TObject);
begin
  CancelButton.Margins.Left := (ClientWidth - CancelButton.Width) div 2;
end;

function TProgressView.GetShouldActModal: Boolean;
begin
  Result := FShouldActModal;
end;

procedure TProgressView.HideProgressBar;
begin
  ProgressBar.Visible := False;
  ProgressBar.Align := TAlign.alNone;
end;

procedure TProgressView.UpdateCancelPanel;
begin
  if CancelButton.Tag = 0 then
    CancelButton.Caption := Babel.Tx(sCancel)
  else
    CancelButton.Caption := Babel.Tx(sClose);
  BottomPanel.Visible := Assigned(FCancelProc) or (CancelButton.Tag = 1);
  UpdateFormSize;
end;

procedure TProgressView.UpdateCancelProc(const ACancelProc: TProc; const AIsClose: Boolean);
begin
  FCancelProc := ACancelProc;
  CancelButton.Tag := Ord(AIsClose);
  UpdateCancelPanel;
end;

procedure TProgressView.UpdateFormSize;
begin
  ClientHeight := FStoredHeight - (Ord(not ProgressBar.Visible) * ProgressBar.Height) - (Ord(not BottomPanel.Visible) * BottomPanel.Height);
  StatusLabel.Height := 24;
  Update;
end;

procedure TProgressView.UpdateProgressBar(const AProgress: Integer);
begin
  if AProgress > -1 then
  begin
    ProgressBar.Align := TAlign.alBottom;
    ProgressBar.Visible := True;
    ProgressBar.Position := AProgress;
    UpdateFormSize;
  end
  else
    Dismiss;
end;

procedure TProgressView.Dismiss;
begin
  if Visible and (CancelButton.Tag = 0) then
    InternalDismiss;
end;

procedure TProgressView.InternalDismiss;
begin
  Caption := '';
  HideProgressBar;
  FCancelProc := nil;
  if (FActiveForm <> nil) and FShouldActModal then
    FActiveForm.Enabled := FWasActiveFormEnabled;
  Close;
end;

procedure TProgressView.ShowProgress(const AStatus: string);
begin
  if Caption = '' then
    Caption := Babel.Tx(sPleaseWait);
  StatusLabel.Caption := AStatus;
  UpdateCancelPanel;
  if not Visible then
  begin
    FActiveForm := Screen.ActiveForm;
    if (FActiveForm <> nil) and FShouldActModal then
    begin
      FWasActiveFormEnabled := FActiveForm.Enabled;
      FActiveForm.Enabled := False;
    end;
    Show;
  end;
end;

procedure TProgressView.ShowProgress(const AStatus: string; const ACancelProc: TProc);
begin
  ShowProgress(AStatus);
  UpdateCancelProc(ACancelProc, False);
end;

procedure TProgressView.ShowProgress(const AStatus: string; const AProgress: Integer);
begin
  ShowProgress(AStatus);
  UpdateProgressBar(AProgress);
end;

procedure TProgressView.ShowProgress(const ATitle, AStatus: string);
begin
  Caption := ATitle;
  ShowProgress(AStatus);
end;

procedure TProgressView.ShowProgress(const ATitle, AStatus: string; const AProgress: Integer);
begin
  ShowProgress(ATitle, AStatus);
  UpdateProgressBar(AProgress);
end;

procedure TProgressView.SetShouldActModal(const Value: Boolean);
begin
  // Cannot change this flag if the form is already showing
  if not Visible then
    FShouldActModal := Value;
end;

procedure TProgressView.ShowStatic(const ATitle, AStatus: string; const ACloseProc: TProc = nil);
begin
  ShowProgress(ATitle, AStatus);
  UpdateCancelProc(ACloseProc, True);
end;

procedure TProgressView.ShowStatic(const AStatus: string; const ACloseProc: TProc = nil);
begin
  ShowProgress(AStatus);
  UpdateCancelProc(ACloseProc, True);
end;

procedure TProgressView.ShowProgress(const ATitle, AStatus: string; const ACancelProc: TProc);
begin
  ShowProgress(ATitle, AStatus);
  UpdateCancelProc(ACancelProc, False);
end;

procedure TProgressView.CancelButtonClick(Sender: TObject);
begin
  if Assigned(FCancelProc) then
    FCancelProc;
  InternalDismiss;
end;

end.
