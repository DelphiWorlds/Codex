unit Codex.Visualizer.MultiLineStringFrame;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  ToolsAPI;

type
  TMultiLineStringFrame = class(TFrame, IOTADebuggerVisualizerExternalViewerUpdater)
    TextMemo: TMemo;
  private
    FClosedProc: TOTAVisualizerClosedProcedure;
  protected
    procedure SetParent(AParent: TWinControl); override;
  public
    { IOTADebuggerVisualizerExternalViewerUpdater }
    procedure CloseVisualizer;
    procedure MarkUnavailable(Reason: TOTAVisualizerUnavailableReason);
    procedure RefreshVisualizer(const Expression, TypeName, EvalResult: string);
    procedure SetClosedCallback(ClosedProc: TOTAVisualizerClosedProcedure);
  end;

implementation

{$R *.dfm}

{ TMultiLineStringFrame }

procedure TMultiLineStringFrame.CloseVisualizer;
begin
  if Owner is TForm then
    TForm(Owner).Close;
end;

procedure TMultiLineStringFrame.MarkUnavailable(Reason: TOTAVisualizerUnavailableReason);
begin
  case Reason of
    ovurProcessRunning:
      TextMemo.Text := 'Process running';
    ovurOutOfScope:
      TextMemo.Text := 'Out of scope';
  end;
end;

procedure TMultiLineStringFrame.RefreshVisualizer(const Expression, TypeName, EvalResult: string);
var
  I: Integer;
  LText: TArray<string>;
begin
  LText := EvalResult.Split(['#$D#$A']);
  for I := 0 to Length(LText) - 1 do
    LText[I] := AnsiDequotedStr(LText[I], '''');
  TextMemo.Lines.BeginUpdate;
  try
    TextMemo.Lines.Clear;
    TextMemo.Lines.AddStrings(LText);
  finally
    TextMemo.Lines.EndUpdate;
  end;
end;

procedure TMultiLineStringFrame.SetClosedCallback(ClosedProc: TOTAVisualizerClosedProcedure);
begin
  FClosedProc := ClosedProc;
end;

procedure TMultiLineStringFrame.SetParent(AParent: TWinControl);
begin
  if AParent = nil then
  begin
    if Assigned(FClosedProc) then
      FClosedProc;
  end;
  inherited;
end;

end.
