unit Codex.Mosco.ImportXcodeFilesView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons,
  {$IF Defined(EXPERT)}
  Codex.BaseView;
  {$ENDIF}

type
  TImportXcodeFilesView = class(TForm)
    BottomPanel: TPanel;
    CloseButton: TButton;
    AddFrameworksButton: TButton;
    TargetPathPanel: TPanel;
    SelectTargetPathButton: TSpeedButton;
    TargetPathLabel: TLabel;
    TargetPathEdit: TEdit;
    SDKLabel: TLabel;
    XcodePathLabel: TLabel;
    XcodePathComboBox: TComboBox;
    XcodeSubfolderLabel: TLabel;
    XcodeSubfolderEdit: TEdit;
    SDKComboBox: TComboBox;
    FileTypesLabel: TLabel;
    FileTypesEdit: TEdit;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ImportXcodeFilesView: TImportXcodeFilesView;

implementation

{$R *.dfm}

end.
