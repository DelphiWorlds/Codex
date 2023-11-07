unit Codex.OutputView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TOutputView = class(TForm)
    Memo: TMemo;
  private
    { Private declarations }
  public
    constructor Create(AOwner: TComponent); override;
    procedure Clear;
  end;

var
  OutputView: TOutputView;

implementation

{$R *.dfm}

{$IF Defined(EXPERT)}
uses
  DW.OTA.Helpers;
{$ENDIF}

{ TOutputView }

constructor TOutputView.Create(AOwner: TComponent);
begin
  inherited;
  // TODO: Determine why this form was excluded from using the interposer in Codex.BaseView
  {$IF Defined(EXPERT)}
  TOTAHelper.ApplyTheme(Self);
  {$ENDIF}
end;

procedure TOutputView.Clear;
begin
  Memo.Clear;
end;

end.
