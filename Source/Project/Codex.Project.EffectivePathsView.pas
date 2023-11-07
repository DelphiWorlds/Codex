unit Codex.Project.EffectivePathsView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ComCtrls, System.Actions, Vcl.ActnList,
  DW.Vcl.ExtendedListBox,
  Codex.BaseView;

type
  TEffectivePathsView = class(TForm)
    EffectivePathsListBox: TListBox;
    CommandButtonsPanel: TPanel;
    PageControl: TPageControl;
    EffectivePathsTab: TTabSheet;
    FindUnitTab: TTabSheet;
    UnitNameLabel: TLabel;
    UnitNameEdit: TEdit;
    FindResultsLabel: TLabel;
    FindResultsListBox: TListBox;
    FindUnitButton: TBitBtn;
    ActionList: TActionList;
    FindUnitAction: TAction;
    InvalidPathsLabel: TLabel;
    CopyListLabel: TLabel;
    CloseButton: TButton;
    procedure EffectivePathsListBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
    procedure FindUnitActionUpdate(Sender: TObject);
    procedure FindUnitActionExecute(Sender: TObject);
    procedure FindResultsListBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
  private
    FFindMode: Boolean;
    function HasDuplicateResult(const AIndex: Integer): Boolean;
    procedure SetFindMode(const Value: Boolean);
  protected
    procedure DoShow; override;
  public
    property FindMode: Boolean read FFindMode write SetFindMode;
  end;

var
  EffectivePathsView: TEffectivePathsView;

implementation

{$R *.dfm}

uses
  System.IOUtils,
  BrandingAPI,
  Vcl.Themes, Vcl.GraphUtil,
  Codex.Core;

resourcestring
  sFindUnitCaption = 'Find Unit';

type
  TOpenListBox = class(TListBox);

function GetGrayBlendColor(const AStyle: TCustomStyleServices; const ASelected: Boolean = False): TColor;
begin
  if ASelected then
    Result := ColorBlendRGB(AStyle.GetSystemColor(clHighlightText), AStyle.GetSystemColor(clHighlight), 0.5)
  else
    Result := ColorBlendRGB(AStyle.GetSystemColor(clWindowText), AStyle.GetSystemColor(clWindow), 0.5);
end;

{ TEffectivePathsView }

procedure TEffectivePathsView.DoShow;
begin
  inherited;
  if FFindMode then
    UnitNameEdit.SetFocus
  else
    EffectivePathsListBox.SetFocus;
end;

procedure TEffectivePathsView.EffectivePathsListBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
var
  LListBox: TListBox;
  LStyle: TCustomStyleServices;
  LRect: TRect;
  LDir: string;
begin
  if ThemeProperties <> nil then
    LStyle := ThemeProperties.StyleServices
  else
    LStyle := StyleServices;
  LListBox := TListBox(Control);
  LDir := LListBox.Items[Index];
  LListBox.Canvas.FillRect(Rect);
  if TDirectory.Exists(LDir) then
  begin
    if odSelected in State then
      LListBox.Canvas.Font.Color := LStyle.GetSystemColor(clHighlightText)
    else
      LListBox.Canvas.Font.Color := LStyle.GetSystemColor(clWindowText)
  end
  else
    LListBox.Canvas.Font.Color := clWebOrange;
  LRect := Rect;
  LListBox.Canvas.TextRect(LRect, LDir, [tfLeft, tfPathEllipsis, tfVerticalCenter, tfSingleLine, tfNoPrefix]);
end;

procedure TEffectivePathsView.FindResultsListBoxDrawItem(Control: TWinControl; Index: Integer; Rect: TRect; State: TOwnerDrawState);
const
  cDuplicateColor: array[Boolean] of TColor = (clRed, clWhite);
  cValidColor: array[Boolean] of TColor = (clBlack, clWhite);
var
  LListBox: TListBox;
  LSelected: Boolean;
begin
  LListBox := TListBox(Control);
  LSelected := odSelected in State;
  LListBox.Canvas.FillRect(Rect);
  if HasDuplicateResult(Index) then
    LListBox.Canvas.Font.Color := cDuplicateColor[LSelected]
  else
    LListBox.Canvas.Font.Color := cValidColor[LSelected];
  LListBox.Canvas.TextOut(Rect.Left, Rect.Top + 1, LListBox.Items[Index]);
  if odFocused in State then
    LListBox.Canvas.DrawFocusRect(Rect);
end;

procedure TEffectivePathsView.FindUnitActionExecute(Sender: TObject);
var
  I: Integer;
  LPath, LFileName: string;
begin
  FindResultsListBox.Items.Clear;
  for I := 0 to EffectivePathsListBox.Items.Count - 1 do
  begin
    LPath := EffectivePathsListBox.Items[I];
    if TDirectory.Exists(LPath) then
    begin
      LFileName := TPath.Combine(LPath, UnitNameEdit.Text + '.pas');
      if TFile.Exists(LFileName) then
        FindResultsListBox.Items.Add(LFileName);
      LFileName := TPath.Combine(LPath, UnitNameEdit.Text + '.dcu');
      if TFile.Exists(LFileName) then
        FindResultsListBox.Items.Add(LFileName);
    end;
  end;
  if FindResultsListBox.Count > 0 then
    FindResultsListBox.SetFocus;
end;

procedure TEffectivePathsView.FindUnitActionUpdate(Sender: TObject);
begin
  FindUnitAction.Enabled := Trim(UnitNameEdit.Text) <> '';
end;

function TEffectivePathsView.HasDuplicateResult(const AIndex: Integer): Boolean;
var
  I: Integer;
  LSource: string;
begin
  Result := False;
  LSource := TPath.GetFileNameWithoutExtension(FindResultsListBox.Items[AIndex]);
  for I := 0 to FindResultsListBox.Items.Count - 1 do
  begin
    if (I <> AIndex) and LSource.Equals(TPath.GetFileNameWithoutExtension(FindResultsListBox.Items[I])) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

procedure TEffectivePathsView.SetFindMode(const Value: Boolean);
begin
  FFindMode := Value;
  if FFindMode then
  begin
    Caption := Babel.Tx(sFindUnitCaption);
    PageControl.ActivePage := FindUnitTab
  end
  else
    PageControl.ActivePage := EffectivePathsTab;
  FindUnitButton.Visible := FFindMode;
end;

end.
