unit Codex.Project.AddFoldersView;

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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Buttons, System.Actions, Vcl.ActnList, Vcl.CheckLst,
  DW.OTA.Types, DW.OTA.ProjectConfigComboBox,
  Codex.BaseView;

type
  TMacro = record
    Name: string;
    Value: string;
    constructor Create(const AName, AValue: string);
    function DisplayValue: string;
    function IsEqual(const AMacro: TMacro): Boolean;
    function MacroName: string;
  end;

  TMacros = TArray<TMacro>;

  TAddFoldersView = class(TForm)
    CommandButtonsPanel: TPanel;
    OKButton: TButton;
    CancelButton: TButton;
    ActionList: TActionList;
    PathsPanel: TPanel;
    PathsLabel: TLabel;
    ConfigPanel: TPanel;
    OKAction: TAction;
    FolderOpenDialog: TFileOpenDialog;
    FoldersMemo: TMemo;
    MacrosPanel: TPanel;
    PathsButtonsPanel: TPanel;
    SelectFromFolderButton: TButton;
    MacrosLabel: TLabel;
    MacrosButtonsPanel: TPanel;
    ApplyMacroButton: TButton;
    UseMacroAction: TAction;
    MacrosCheckListBox: TCheckListBox;
    ClearFoldersButton: TButton;
    ClearFoldersAction: TAction;
    ConfigLabel: TLabel;
    procedure OKActionExecute(Sender: TObject);
    procedure OKActionUpdate(Sender: TObject);
    procedure SelectFromFolderButtonClick(Sender: TObject);
    procedure UseMacroActionExecute(Sender: TObject);
    procedure UseMacroActionUpdate(Sender: TObject);
    procedure ClearFoldersActionExecute(Sender: TObject);
    procedure ClearFoldersActionUpdate(Sender: TObject);
  private
    ConfigComboBox: TOTAProjectConfigComboBox;
    FMacros: TMacros;
    procedure UpdateMacros;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  AddFoldersView: TAddFoldersView;

implementation

{$R *.dfm}

uses
  {$IF Defined(EXPERT)}
  DCCStrs,
  ToolsAPI,
  DW.OTA.Consts, DW.OTA.Helpers,
  {$ENDIF}
  DW.Environment.RADStudio, DW.OS.Win, DW.Vcl.ListBoxHelper,
  System.IOUtils;

type
  TMacrosHelper = record helper for TMacros
    procedure Add(const AMacro: TMacro);
    function Exists(const AMacro: TMacro): Boolean;
    function FindMatching(const AValue: string; out AMacro: TMacro): Boolean;
    function IndexOfValue(const AValue: string): Integer;
  end;

{ TMacro }

constructor TMacro.Create(const AName, AValue: string);
begin
  Name := AName;
  Value := AValue;
end;

function TMacro.DisplayValue: string;
begin
  Result := Format('%s: %s', [Name, Value]);
end;

function TMacro.IsEqual(const AMacro: TMacro): Boolean;
begin
  Result := SameText(AMacro.Name, Name) and SameText(AMacro.Value, Value);
end;

function TMacro.MacroName: string;
begin
  Result := Format('$(%s)', [Name]);
end;

{ TMacrosHelper }

procedure TMacrosHelper.Add(const AMacro: TMacro);
begin
  if not Exists(AMacro) then
    Self := Self + [AMacro];
end;

function TMacrosHelper.Exists(const AMacro: TMacro): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Self) - 1 do
  begin
    if AMacro.IsEqual(Self[I]) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function TMacrosHelper.FindMatching(const AValue: string; out AMacro: TMacro): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(Self) - 1 do
  begin
    if AValue.StartsWith(Self[I].Value, True) then
    begin
      AMacro := Self[I];
      Result := True;
      Break;
    end;
  end;
end;

function TMacrosHelper.IndexOfValue(const AValue: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(Self) - 1 do
  begin
    if SameText(Self[I].Value, AValue) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

{ TCommonPathsView }

procedure TAddFoldersView.ClearFoldersActionExecute(Sender: TObject);
begin
  FoldersMemo.Text := '';
end;

procedure TAddFoldersView.ClearFoldersActionUpdate(Sender: TObject);
begin
  ClearFoldersAction.Enabled := not string(FoldersMemo.Text).IsEmpty;
end;

constructor TAddFoldersView.Create(AOwner: TComponent);
begin
  inherited;
  ConfigComboBox := TOTAProjectConfigComboBox.Create(Self);
  ConfigComboBox.Align := TAlign.alClient;
  ConfigComboBox.AlignWithMargins := True;
  ConfigComboBox.Parent := ConfigPanel;
  ConfigComboBox.LoadTargets;
  UpdateMacros;
end;

procedure TAddFoldersView.OKActionExecute(Sender: TObject);
var
  LConfig: IOTABuildConfiguration;
  LFolders: string;
begin
  LConfig := ConfigComboBox.SelectedConfig;
  if LConfig <> nil then
  begin
    LFolders := string.Join(';', FoldersMemo.Lines.ToStringArray);
    LConfig.SetValue(sUnitSearchPath, LConfig.GetValue(sUnitSearchPath) + ';' + LFolders);
    TOTAHelper.MarkCurrentModuleModified;
    ModalResult := mrOK;
  end;
end;

procedure TAddFoldersView.OKActionUpdate(Sender: TObject);
begin
  OKAction.Enabled := (FoldersMemo.Lines.Count > 0) and (ConfigComboBox.SelectedConfig <> nil);
end;

procedure TAddFoldersView.UseMacroActionExecute(Sender: TObject);
var
  LMacro: TMacro;
  I: Integer;
  LFolder: string;

  function CanAddFolder(const AFolder: string): Boolean;
  begin
    Result := not AFolder.Contains('\__') and not AFolder.Contains('\.git');
  end;

begin
  FoldersMemo.Lines.BeginUpdate;
  try
    for I := 0 to MacrosCheckListBox.Items.Count - 1 do
    begin
      if MacrosCheckListBox.Selected[I] then
      begin
        LMacro := FMacros[I];
        FoldersMemo.Lines.Add(LMacro.MacroName);
        for LFolder in TDirectory.GetDirectories(LMacro.Value, '*.*', TSearchOption.soAllDirectories) do
        begin
          if CanAddFolder(LFolder) then
            FoldersMemo.Lines.Add(LMacro.MacroName + LFolder.Substring(Length(LMacro.Value)));
        end;
      end;
    end;
  finally
    FoldersMemo.Lines.EndUpdate;
  end;
  MacrosCheckListBox.UncheckAll;
end;

procedure TAddFoldersView.UseMacroActionUpdate(Sender: TObject);
begin
  UseMacroAction.Enabled := MacrosCheckListBox.HasChecked;
end;

procedure TAddFoldersView.SelectFromFolderButtonClick(Sender: TObject);
var
  LSelectedFolders: TArray<string>;
  LFolders: TStringList;
  LSelectedFolder: string;
begin
  if FolderOpenDialog.Execute then
  begin
    LSelectedFolders := TDirectory.GetDirectories(FolderOpenDialog.FileName, '*.*', TSearchOption.soAllDirectories);
    LFolders := TStringList.Create;
    try
      LFolders.Duplicates := TDuplicates.dupIgnore;
      FoldersMemo.Lines.BeginUpdate;
      try
        LFolders.Assign(FoldersMemo.Lines);
        for LSelectedFolder in LSelectedFolders do
          LFolders.Add(LSelectedFolder);
        LFolders.Sorted := True;
        FoldersMemo.Lines.Assign(LFolders);
      finally
        FoldersMemo.Lines.EndUpdate;
      end;
    finally
      LFolders.Free;
    end;
  end;
end;

procedure TAddFoldersView.UpdateMacros;
var
  LRS: TRSEnvironment;
  LValues: TStringList;
  I: Integer;
  LValue: string;
  LMacro: TMacro;
begin
  FMacros := [];
  MacrosCheckListBox.Items.Clear;
  LRS := TRSEnvironment.Create;
  try
    LValues := TStringList.Create;
    try
      LRS.GetVariables(TPlatformOS.GetEnvironmentVariable('ProductVersion'), LValues);
      LValues.Sorted := True;
      for I := 0 to LValues.Count - 1 do
      begin
        LValue := LValues.ValueFromIndex[I];
        if (LValue.Length > 1) and (LValue.Chars[1] = ':') then
        begin
          LMacro := TMacro.Create(LValues.Names[I], LValue);
          FMacros.Add(LMacro);
          MacrosCheckListBox.Items.Add(LMacro.DisplayValue);
        end;
      end;
    finally
      LValues.Free;
    end;
  finally
    LRS.Free;
  end;
end;

end.
