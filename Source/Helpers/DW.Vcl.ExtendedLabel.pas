unit DW.Vcl.ExtendedLabel;

interface

uses
  Winapi.Messages,
  Vcl.Controls, Vcl.StdCtrls;

type
  TLabel = class(Vcl.StdCtrls.TLabel)
  private
    function IsLink: Boolean;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  end;

implementation

uses
  Winapi.UxTheme,
  BrandingAPI,
  Vcl.Graphics, Vcl.Themes;

{ TLabel }

procedure TLabel.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if IsLink then
    Font.Style := Font.Style + [TFontStyle.fsUnderline];
end;

procedure TLabel.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if IsLink then
    Font.Style := Font.Style - [TFontStyle.fsUnderline];
end;

function TLabel.IsLink: Boolean;
begin
  {$IF CompilerVersion > 36}
  Result := Font.Color = ThemeProperties.MainWindow.LinkColor;
  {$ELSE}
  Result := Font.Color = ThemeProperties.LinkColor;
  {$ENDIF}
end;

end.
