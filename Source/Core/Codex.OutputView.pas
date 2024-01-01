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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Codex.BaseView;

type
  TOutputView = class(TForm)
    Memo: TMemo;
  public
    procedure Clear;
  end;

var
  OutputView: TOutputView;

implementation

{$R *.dfm}

{ TOutputView }

procedure TOutputView.Clear;
begin
  Memo.Clear;
end;

end.
