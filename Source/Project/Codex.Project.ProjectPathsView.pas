unit Codex.Project.ProjectPathsView;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Types, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.CheckLst, System.Actions, Vcl.ActnList,
  DW.Vcl.Splitter.Themed,
  Codex.BaseView, Codex.CustomPathsView;

type
  TProjectPathsView = class(TForm)
    ButtonsPanel: TPanel;
    ActionList: TActionList;
    AddPathAction: TAction;
    RemovePathAction: TAction;
    SelectPathAction: TAction;
    ReplacePathAction: TAction;
    PathOpenDialog: TFileOpenDialog;
    MovePathUpAction: TAction;
    MovePathDownAction: TAction;
    OKAction: TAction;
    ToggleCheckedPathsAction: TAction;
    EffectivePathsPanel: TPanel;
    EffectivePathsListBox: TListBox;
    MainSplitter: TSplitter;
    CancelButton: TButton;
    OKButton: TButton;
    EffectivePathsLabel: TLabel;
    CustomPaths: TCustomPathsView;
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure OKActionExecute(Sender: TObject);
  private
    function GetExistingPaths: TStrings;
    function GetSelectedPaths: TStringDynArray;
    procedure SetExistingPaths(const Value: TStrings);
  public
    constructor Create(AOwner: TComponent); override;
    property ExistingPaths: TStrings read GetExistingPaths write SetExistingPaths;
    property SelectedPaths: TStringDynArray read GetSelectedPaths;
  end;

var
  ProjectPathsView: TProjectPathsView;

implementation

{$R *.dfm}

uses
  BrandingAPI, IDETheme.Utils,
  DW.Vcl.ListBoxHelper,
  Codex.Core;

resourcestring
  sPathsToInsert = 'Paths To Insert';

{ TfrmProjectPaths }

constructor TProjectPathsView.Create(AOwner: TComponent);
begin
  inherited;
  CustomPaths.PathsLabel.Caption := Babel.Tx(sPathsToInsert);
end;

function TProjectPathsView.GetExistingPaths: TStrings;
begin
  Result := CustomPaths.ExistingPaths;
end;

function TProjectPathsView.GetSelectedPaths: TStringDynArray;
begin
  Result := CustomPaths.SelectedPaths;
end;

procedure TProjectPathsView.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  OKAction.Enabled := CustomPaths.PathsCheckListBox.HasChecked;
  Handled := True;
end;

procedure TProjectPathsView.OKActionExecute(Sender: TObject);
begin
  ModalResult := mrOk;
end;

procedure TProjectPathsView.SetExistingPaths(const Value: TStrings);
begin
  CustomPaths.ExistingPaths := Value;
end;

end.
