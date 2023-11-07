unit Codex.CustomPathsView;

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
  System.Types,
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Actions,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.Buttons, Vcl.ExtCtrls, Vcl.ActnList;

type
  TCustomPathsView = class(TFrame)
    PathsPanel: TPanel;
    PathsLabel: TLabel;
    PathPanel: TPanel;
    SelectPathButton: TSpeedButton;
    PathEdit: TEdit;
    PathsCheckListBox: TCheckListBox;
    PathsButtonsPanel: TPanel;
    AddPathButton: TButton;
    RemovePathButton: TButton;
    ReplacePathButton: TButton;
    ToggleCheckedPathsButton: TButton;
    UpDownButtonsPanel: TPanel;
    MovePathUpSpeedButton: TSpeedButton;
    MovePathDownSpeedButton: TSpeedButton;
    ActionList: TActionList;
    AddPathAction: TAction;
    RemovePathAction: TAction;
    SelectPathAction: TAction;
    ReplacePathAction: TAction;
    MovePathUpAction: TAction;
    MovePathDownAction: TAction;
    ToggleCheckedPathsAction: TAction;
    PathOpenDialog: TFileOpenDialog;
    procedure AddPathActionExecute(Sender: TObject);
    procedure RemovePathActionExecute(Sender: TObject);
    procedure ReplacePathActionExecute(Sender: TObject);
    procedure MovePathUpActionExecute(Sender: TObject);
    procedure MovePathDownActionExecute(Sender: TObject);
    procedure ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure PathsCheckListBoxClick(Sender: TObject);
  private
    FExistingPaths: TStrings;
    function GetSelectedPaths: TStringDynArray;
    procedure UpdatePathsCheckListBox;
    procedure SaveConfig;
    procedure SetExistingPaths(const Value: TStrings);
    procedure SwapPaths(const ADirection: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    property ExistingPaths: TStrings read FExistingPaths write SetExistingPaths;
    property SelectedPaths: TStringDynArray read GetSelectedPaths;
  end;

implementation

{$R *.dfm}

uses
  DW.Types.Helpers, DW.Vcl.ListBoxHelper,
  Codex.Config;

type
  TStringsHelper = class helper for TStrings
  public
    function IndexOfEx(const AValue: string): Integer;
  end;

{ TStringsHelper }

function TStringsHelper.IndexOfEx(const AValue: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    if SameText(AValue, Strings[I]) then
      Exit(I);
  end;
end;

{ TCustomPathsView }

constructor TCustomPathsView.Create(AOwner: TComponent);
begin
  inherited;
  Config.ProjectPaths.AssignToStrings(PathsCheckListBox.Items);
end;

function TCustomPathsView.GetSelectedPaths: TStringDynArray;
var
  I: Integer;
begin
  for I := 0 to PathsCheckListBox.Count - 1 do
  begin
    if PathsCheckListBox.Checked[I] then
      Result.Add(PathsCheckListBox.Items[I]);
  end;
end;

procedure TCustomPathsView.SaveConfig;
begin
  Config.ProjectPaths := TStringDynArray(PathsCheckListBox.Items.ToStringArray);
  Config.Save;
end;

procedure TCustomPathsView.SetExistingPaths(const Value: TStrings);
begin
  FExistingPaths := Value;
  UpdatePathsCheckListBox;
end;

procedure TCustomPathsView.SwapPaths(const ADirection: Integer);
var
  LPath: string;
begin
  LPath := PathsCheckListBox.Items[PathsCheckListBox.ItemIndex + ADirection];
  PathsCheckListBox.Items[PathsCheckListBox.ItemIndex + ADirection] := PathsCheckListBox.Items[PathsCheckListBox.ItemIndex];
  PathsCheckListBox.Items[PathsCheckListBox.ItemIndex] := LPath;
  PathsCheckListBox.ItemIndex := PathsCheckListBox.ItemIndex + ADirection;
  UpdatePathsCheckListBox;
end;

procedure TCustomPathsView.UpdatePathsCheckListBox;
var
  I: Integer;
begin
  for I := 0 to PathsCheckListBox.Count - 1 do
    PathsCheckListBox.ItemEnabled[I] := FExistingPaths.IndexOfEx(PathsCheckListBox.Items[I]) = -1;
end;

procedure TCustomPathsView.ActionListUpdate(Action: TBasicAction; var Handled: Boolean);
begin
  AddPathAction.Enabled := not string(PathEdit.Text).Trim.IsEmpty and (PathsCheckListBox.Items.IndexOfEx(PathEdit.Text) = -1);
  RemovePathAction.Enabled := PathsCheckListBox.ItemIndex > -1;
  ReplacePathAction.Enabled := PathsCheckListBox.ItemIndex > -1;
  MovePathUpAction.Enabled := PathsCheckListBox.ItemIndex > 0;
  MovePathDownAction.Enabled := (PathsCheckListBox.ItemIndex > -1) and (PathsCheckListBox.ItemIndex < PathsCheckListBox.Items.Count - 1);
  ToggleCheckedPathsAction.Enabled := PathsCheckListBox.Items.Count > 0;
  Handled := True;
end;

procedure TCustomPathsView.AddPathActionExecute(Sender: TObject);
begin
  PathsCheckListBox.Items.Add(PathEdit.Text);
  UpdatePathsCheckListBox;
  SaveConfig;
end;

procedure TCustomPathsView.MovePathDownActionExecute(Sender: TObject);
begin
  SwapPaths(1);
  SaveConfig;
end;

procedure TCustomPathsView.MovePathUpActionExecute(Sender: TObject);
begin
  SwapPaths(-1);
  SaveConfig;
end;

procedure TCustomPathsView.PathsCheckListBoxClick(Sender: TObject);
begin
  if PathsCheckListBox.ItemIndex > -1 then
    PathEdit.Text := PathsCheckListBox.Items[PathsCheckListBox.ItemIndex];
end;

procedure TCustomPathsView.RemovePathActionExecute(Sender: TObject);
begin
  PathsCheckListBox.Items.Delete(PathsCheckListBox.ItemIndex);
  UpdatePathsCheckListBox;
  SaveConfig;
end;

procedure TCustomPathsView.ReplacePathActionExecute(Sender: TObject);
begin
  PathsCheckListBox.Items[PathsCheckListBox.ItemIndex] := PathEdit.Text;
  UpdatePathsCheckListBox;
  SaveConfig;
end;

end.

