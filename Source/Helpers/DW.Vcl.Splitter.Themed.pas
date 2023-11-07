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
    TIDEThemeDrawers.DrawSplitter(Self, ThemeProperties.MainWindowBorderColor, ThemeProperties.MainWindowBorderColor)
  else
    inherited;
end;

end.