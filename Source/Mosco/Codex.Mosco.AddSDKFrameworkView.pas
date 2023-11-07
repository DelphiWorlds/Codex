unit Codex.Mosco.AddSDKFrameworkView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.ExtCtrls, System.Actions, Vcl.ActnList,
  Codex.BaseView;

type
  TAddSDKFrameworkView = class(TForm)
    SDKsListBox: TListBox;
    BottomPanel: TPanel;
    CloseButton: TButton;
    ActionList: TActionList;
    AddFrameworksAction: TAction;
    AddFrameworksButton: TButton;
    SDKsLabel: TLabel;
    FrameworksLabel: TLabel;
    FrameworksListBox: TCheckListBox;
    MatchingSDKLabel: TLabel;
    MatchingSDKEdit: TEdit;
    MatchingSDKPanel: TPanel;
    procedure SDKsListBoxClick(Sender: TObject);
    procedure AddFrameworksActionUpdate(Sender: TObject);
    procedure AddFrameworksActionExecute(Sender: TObject);
  private
    FCurrentSDK: string;
    FImportedSDKs: TArray<string>;
    FMatchingSDK: string;
    FOnAddFrameworks: TNotifyEvent;
    FOnSDKSelected: TNotifyEvent;
    procedure DoAddFrameworks;
    procedure DoSDKSelected;
    function GetSelectedSDK: string;
  public
    procedure AddFrameworks(const AFrameworks: TArray<string>);
    procedure AddSDKs(const ASDKs: TArray<string>);
    procedure CheckSelectedSDK(const AForce: Boolean);
    procedure ValidateFrameworks(const AFrameworks: TArray<string>);
    property CurrentSDK: string read FCurrentSDK write FCurrentSDK;
    property ImportedSDKs: TArray<string> read FImportedSDKs write FImportedSDKs;
    property MatchingSDK: string read FMatchingSDK;
    property SelectedSDK: string read GetSelectedSDK;
    property OnAddFrameworks: TNotifyEvent read FOnAddFrameworks write FOnAddFrameworks;
    property OnSDKSelected: TNotifyEvent read FOnSDKSelected write FOnSDKSelected;
  end;

implementation

{$R *.dfm}

uses
  System.StrUtils, System.IOUtils,
  DW.OSLog,
  DW.OTA.Helpers, DW.Vcl.ListBoxHelper, DW.Classes.Helpers, DW.OTA.Registry, DW.Types.Helpers,
  Codex.Core;

resourcestring
  sNoMatchingImportedSDKs = 'No matching imported SDKs found';

{ TAddSDKFrameworkView }

procedure TAddSDKFrameworkView.AddSDKs(const ASDKs: TArray<string>);
var
  LSDK: string;
  LIndex: Integer;
begin
  SDKsListBox.Items.Clear;
  for LSDK in ASDKs do
  begin
    SDKsListBox.Items.Add(LSDK);
  end;
  if SDKsListBox.Count > 0 then
  begin
    LIndex := SDKsListBox.Items.IndexOf(FCurrentSDK);
    if LIndex > -1  then
      SDKsListBox.ItemIndex := LIndex
    else
      SDKsListBox.ItemIndex := 0;
    CheckSelectedSDK(True);
  end;
end;

procedure TAddSDKFrameworkView.CheckSelectedSDK(const AForce: Boolean);
var
  I: Integer;
  LImportedSDK, LSelectedSDK: string;
  LSubLength, LSelectedVersion, LImportedVersion: Integer;
begin
  if (SDKsListBox.ItemIndex > -1) and (AForce or (SDKsListBox.Tag <> SDKsListBox.ItemIndex)) then
  begin
    SDKsListBox.Tag := SDKsListBox.ItemIndex;
    FrameworksListBox.Items.Clear;
    FMatchingSDK := '';
    for I := 0 to FImportedSDKs.Count - 1 do
    begin
      LSubLength := 0;
      LImportedSDK := FImportedSDKs[I];
      LSelectedSDK := SDKsListBox.Items[SDKsListBox.ItemIndex];
      if SameText(LSelectedSDK, LImportedSDK) then
      begin
        FMatchingSDK := LSelectedSDK;
        Break;
      end
      else
      begin
        LSelectedSDK := LSelectedSDK.Substring(0, LSelectedSDK.LastIndexOf('.'));
        LImportedSDK := LImportedSDK.Substring(0, LImportedSDK.LastIndexOf('.'));
        if LSelectedSDK.StartsWith('iPhoneOS') and LImportedSDK.StartsWith('iPhoneOS') then
          LSubLength := 8
        else if LSelectedSDK.StartsWith('MacOSX') and LImportedSDK.StartsWith('MacOSX') then
          LSubLength := 6;
        if (LSubLength > 0) and TryStrToInt(StringReplace(LSelectedSDK.Substring(LSubLength), '.', '', []), LSelectedVersion) and
          TryStrToInt(StringReplace(LImportedSDK.Substring(LSubLength), '.', '', []), LImportedVersion) and (LSelectedVersion >= LImportedVersion) then
        begin
          FMatchingSDK := FImportedSDKs[I];
        end;
      end;
    end;
    if FMatchingSDK.IsEmpty then
      MatchingSDKEdit.Text := Babel.Tx(sNoMatchingImportedSDKs)
    else
      MatchingSDKEdit.Text := FMatchingSDK;
    DoSDKSelected;
  end;
end;

procedure TAddSDKFrameworkView.AddFrameworks(const AFrameworks: TArray<string>);
var
  LFramework: string;
begin
  FrameworksListBox.Items.Clear;
  for LFramework in AFrameworks do
    FrameworksListBox.Items.Add(TPath.GetFileNameWithoutExtension(LFramework));
end;

procedure TAddSDKFrameworkView.AddFrameworksActionExecute(Sender: TObject);
begin
  DoAddFrameworks;
end;

procedure TAddSDKFrameworkView.AddFrameworksActionUpdate(Sender: TObject);
begin
  AddFrameworksAction.Enabled := not FMatchingSDK.IsEmpty and (FrameworksListBox.CheckedCount > 0);
end;

procedure TAddSDKFrameworkView.DoAddFrameworks;
begin
  if Assigned(FOnAddFrameworks) then
    FOnAddFrameworks(Self);
end;

procedure TAddSDKFrameworkView.DoSDKSelected;
begin
  if Assigned(FOnSDKSelected) then
    FOnSDKSelected(Self);
end;

function TAddSDKFrameworkView.GetSelectedSDK: string;
begin
  Result := SDKsListBox.SelectedItem;
end;

procedure TAddSDKFrameworkView.SDKsListBoxClick(Sender: TObject);
begin
  CheckSelectedSDK(False);
end;

procedure TAddSDKFrameworkView.ValidateFrameworks(const AFrameworks: TArray<string>);
var
  I: Integer;
begin
  for I := FrameworksListBox.Items.Count - 1 downto 0 do
  begin
    if not AnsiMatchStr(FrameworksListBox.Items[I], AFrameworks) then
      FrameworksListBox.Items.Delete(I);
  end;
  FrameworksListBox.CheckAll(TCheckBoxState.cbChecked);
end;

end.
