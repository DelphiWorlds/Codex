unit DW.Vcl.Splitter.Themed;

interface

uses
  Vcl.ExtCtrls;

type
  TSplitter = class(Vcl.ExtCtrls.TSplitter)
  protected
    procedure Paint; override;
  end;

implementation

uses
  BrandingAPI, IDETheme.Utils;

{ TSplitter }

procedure TSplitter.Paint;
begin
  if ThemeProperties <> nil then
  begin
    {$IF CompilerVersion > 36}
    TIDEThemeDrawers.DrawSplitter(Self, ThemeProperties.MainWindow.BorderColor, ThemeProperties.MainWindow.BorderColor);
    {$ELSE}
    TIDEThemeDrawers.DrawSplitter(Self, ThemeProperties.MainWindowBorderColor, ThemeProperties.MainWindowBorderColor);
    {$ENDIF}
  end
  else
    inherited;
end;

end.