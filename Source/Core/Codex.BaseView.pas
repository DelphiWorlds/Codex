unit Codex.BaseView;

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
  System.Classes,
  Vcl.TitleBarCtrls, Vcl.Forms,
  Codex.Interfaces;

type
  TForm = class(Vcl.Forms.TForm, ICodexView)
  private
    FIsShown: Boolean;
    FNeedsProps: Boolean;
    procedure ReadProps;
    procedure WriteProps;
  protected
    procedure DoHide; override;
    procedure DoShow; override;
    property IsShown: Boolean read FIsShown;
    property NeedsProps: Boolean read FNeedsProps write FNeedsProps;
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  Vcl.Controls,
  {$IF Defined(EXPERT)}
  ToolsAPI,
  {$IF CompilerVersion > 35}
  ToolsAPI.UI,
  {$ENDIF}
  BrandingAPI, IDETheme.Utils,
  DW.OTA.Helpers,
  {$ENDIF}
  Codex.Config, Codex.Core;

type
  TOpenControl = class(TControl);

{ TForm }

constructor TForm.Create(AOwner: TComponent);
begin
  inherited;
  FNeedsProps := True;
  {$IF Defined(EXPERT)}
  TOTAHelper.ApplyTheme(Self);
  {$IF CompilerVersion > 35}
  TIDETitleBarService.AddTitleBar(Self, nil);
  {$ELSE}
  SetupIDEDialogTitleBar(Self, nil);
  {$ENDIF}
  {$ENDIF}
  Babel.Translate(Self);
end;

procedure TForm.DoHide;
begin
  WriteProps;
  inherited;
end;

procedure TForm.DoShow;
begin
  inherited;
  ReadProps;
  FIsShown := True;
end;

procedure TForm.ReadProps;
var
  LProps: TFormProps;
begin
  if FNeedsProps and not FIsShown and Config.GetFormProps(Name, LProps) then
  begin
    Left := LProps.Left;
    Top := LProps.Top;
    Width := LProps.Width;
    Height := LProps.Height;
  end;
end;

procedure TForm.WriteProps;
begin
  if FNeedsProps then
    Config.SetFormProps(Name, Left, Top, Width, Height);
end;

end.
