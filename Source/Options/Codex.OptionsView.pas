unit Codex.OptionsView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls,
  DW.Vcl.Splitter.Themed,
  Codex.BaseView;

type
  TOptionsView = class(TForm)
    CommandButtonsPanel: TPanel;
    CancelButton: TButton;
    OKButton: TButton;
    SectionsTreeView: TTreeView;
    SectionPanel: TPanel;
    SectionSplitter: TSplitter;
    procedure SectionsTreeViewChange(Sender: TObject; Node: TTreeNode);
    procedure OKButtonClick(Sender: TObject);
  private
    FSectionID: string;
    procedure CreateOptions;
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    function ShowOptions(const ASectionID: string): Boolean;
  end;

var
  OptionsView: TOptionsView;

implementation

{$R *.dfm}

uses
  DW.OTA.Helpers,
  Codex.Options, Codex.Config;

{ TOptionsView }

constructor TOptionsView.Create(AOwner: TComponent);
begin
  inherited;
  CreateOptions;
end;

procedure TOptionsView.CreateOptions;
var
  LClass: TFormClass;
  LForm: Vcl.Forms.TForm;
  LSection: IConfigOptionsSection;
begin
  for LClass in TConfigOptionsHelper.Options do
  begin
    LForm := LClass.Create(Self);
    if Supports(LForm, IConfigOptionsSection, LSection) then
    begin
      LSection.ShowSection;
      SectionsTreeView.Items.AddChild(nil, LSection.SectionTitle).Data := LSection;
    end;
  end;
end;

procedure TOptionsView.DoShow;
var
  LSection: IConfigOptionsSection;
  I: Integer;
begin
  inherited;
  for I := 0 to SectionsTreeView.Items.Count - 1 do
  begin
    LSection := IConfigOptionsSection(SectionsTreeView.Items[I].Data);
    if LSection.SectionID.Equals(FSectionID) then
      SectionsTreeView.Selected := SectionsTreeView.Items[I];
  end;
  if SectionsTreeView.Selected  = nil then
    SectionsTreeView.Selected := SectionsTreeView.TopItem;
end;

procedure TOptionsView.OKButtonClick(Sender: TObject);
var
  I: Integer;
begin
  for I := 0 to SectionsTreeView.Items.Count - 1 do
    IConfigOptionsSection(SectionsTreeView.Items[I].Data).Save;
  Config.Save;
  ModalResult := mrOk; // This is here in case I change my mind later about not being able to save
end;

procedure TOptionsView.SectionsTreeViewChange(Sender: TObject; Node: TTreeNode);
var
  LSection: IConfigOptionsSection;
  LRoot: TControl;
begin
  LSection := IConfigOptionsSection(Node.Data);
  LRoot := LSection.GetRootControl;
  if LRoot.Parent <> SectionPanel then
  begin
    LRoot.Parent := SectionPanel;
    LSection.ShowSection;
  end;
  LRoot.Visible := True;
  LRoot.BringToFront;
end;

function TOptionsView.ShowOptions(const ASectionID: string): Boolean;
begin
  if not ASectionID.IsEmpty then
    FSectionID := ASectionID;
  Result := ShowModal = mrOK;
end;

end.
