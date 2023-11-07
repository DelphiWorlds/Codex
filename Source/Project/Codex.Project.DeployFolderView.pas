unit Codex.Project.DeployFolderView;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, Vcl.CheckLst, System.Actions,
  Vcl.ActnList, Vcl.ComCtrls,
  Codex.BaseView;

const
  WM_CHECKEDCHANGED = WM_USER + 1;

type
  TTreeViewCheckedChangeEvent = procedure(Sender: TObject; const Node: TTreeNode) of object;

  TTreeView = class(Vcl.ComCtrls.TTreeView)
  private
    FOnCheckedChange: TTreeViewCheckedChangeEvent;
    procedure DoCheckedChange(const ANode: TTreeNode);
    function InternalCheckedCount(const ARecurse: Boolean; const ANode: TTreeNode): Integer;
    procedure PostCheckedChange(const ANode: TTreeNode);
    procedure WMCheckedChanged(var Msg: TMessage); message WM_CHECKEDCHANGED;
  protected
    procedure CNNotify(var Msg: TWMNotify); message CN_NOTIFY;
    procedure CreateParams(var Params: TCreateParams); override;
  public
    function CheckedCount(const ARecurse: Boolean = True; const ANode: TTreeNode = nil): Integer;
    property OnCheckedChange: TTreeViewCheckedChangeEvent read FOnCheckedChange write FOnCheckedChange;
  end;

  TDeployFolderView = class(TForm)
    SourcePathPanel: TPanel;
    SelectSourcePathSpeedButton: TSpeedButton;
    SourcePathLabel: TLabel;
    SourcePathEdit: TEdit;
    RemotePathPanel: TPanel;
    RemotePathLabel: TLabel;
    RemotePathEdit: TEdit;
    ButtonsPanel: TPanel;
    CancelButton: TButton;
    OKButton: TButton;
    PlatformsPanel: TPanel;
    PlatformsLabel: TLabel;
    ActionList: TActionList;
    OKAction: TAction;
    SourceFolderOpenDialog: TFileOpenDialog;
    PlatformsTreeView: TTreeView;
    procedure OKActionExecute(Sender: TObject);
    procedure OKActionUpdate(Sender: TObject);
    procedure SelectSourcePathSpeedButtonClick(Sender: TObject);
    procedure SourcePathEditChange(Sender: TObject);
  private
    procedure CheckForFramework;
    procedure TreeViewCheckedChangeHandler(Sender: TObject; const ANode: TTreeNode);
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  DeployFolderView: TDeployFolderView;

implementation

{$R *.dfm}

uses
  DW.OSLog,
  System.IOUtils, System.Generics.Collections, System.StrUtils,
  Winapi.CommCtrl,
  ToolsAPI, PlatformAPI, DeploymentAPI,
  DW.OTA.Helpers, DW.IOUtils.Helpers,
  Codex.OTA.Helpers;

const
  TVIS_CHECKED = $2000;

type
  TTreeNodeHelper = class helper for TTreeNode
  private
    function GetIsChecked: Boolean;
    procedure SetIsChecked(const Value: Boolean);
  public
    procedure CheckChildren;
    property IsChecked: Boolean read GetIsChecked write SetIsChecked;
  end;

{ TTreeNodeHelper }

procedure TTreeNodeHelper.CheckChildren;
var
  LNode: TTreeNode;
begin
  LNode := getFirstChild;
  while LNode <> nil do
  begin
    LNode.IsChecked := IsChecked;
    LNode.CheckChildren;
    LNode := LNode.getNextSibling;
  end;
end;

function TTreeNodeHelper.GetIsChecked: Boolean;
var
  LItem: TTVItem;
begin
  LItem.mask := TVIF_STATE;
  LItem.hItem := ItemId;
  if TreeView_GetItem(Handle, LItem) then
    Result := ((LItem.state and TVIS_CHECKED) = TVIS_CHECKED)
  else
    Result := False;
end;

procedure TTreeNodeHelper.SetIsChecked(const Value: Boolean);
var
  LItem: TTVItem;
begin
  if Value <> GetIsChecked then
  begin
    FillChar(LItem, SizeOf(LItem), 0);
    LItem.hItem := ItemId;
    LItem.mask := TVIF_STATE;
    LItem.stateMask := TVIS_STATEIMAGEMASK;
    if Value then
      LItem.state := TVIS_CHECKED
    else
      LItem.state := TVIS_CHECKED shr 1;
    TreeView_SetItem(Handle, LItem);
  end;
end;

{ TTreeView }

procedure TTreeView.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or TVS_CHECKBOXES;
end;

procedure TTreeView.DoCheckedChange(const ANode: TTreeNode);
begin
  if Assigned(FOnCheckedChange) then
    FOnCheckedChange(Self, ANode);
end;

procedure TTreeView.PostCheckedChange(const ANode: TTreeNode);
begin
  if ANode <> nil then
    PostMessage(Handle, WM_CHECKEDCHANGED, Ord(ANode.IsChecked), LParam(ANode.ItemId));
end;

procedure TTreeView.WMCheckedChanged(var Msg: TMessage);
var
  ANode: TTreeNode;
begin
  ANode := Items.GetNode(HTREEITEM(Msg.LParam));
  if (ANode <> nil) and (WPARAM(Ord(ANode.IsChecked)) <> Msg.WParam) then
    DoCheckedChange(ANode);
end;

function TTreeView.InternalCheckedCount(const ARecurse: Boolean; const ANode: TTreeNode): Integer;
var
  LChildNode: TTreeNode;
begin
  Result := 0;
  if ANode <> nil then
  begin
    if ANode.IsChecked then
      Inc(Result);
    if ARecurse then
    begin
      LChildNode := ANode.getFirstChild;
      while LChildNode <> nil do
      begin
        Inc(Result, InternalCheckedCount(True, LChildNode));
        LChildNode := LChildNode.getNextSibling;
      end;
    end;
  end;
end;

function TTreeView.CheckedCount(const ARecurse: Boolean = True; const ANode: TTreeNode = nil): Integer;
var
  LChildNode: TTreeNode;
begin
  if ANode = nil then
  begin
    Result := 0;
    LChildNode := Items.GetFirstNode;
    while LChildNode <> nil do
    begin
      Inc(Result, InternalCheckedCount(ARecurse, LChildNode));
      LChildNode := LChildNode.getNextSibling;
    end;
  end
  else
    Result := InternalCheckedCount(ARecurse, ANode);
end;

procedure TTreeView.CNNotify(var Msg: TWMNotify);
var
  LNode: TTreeNode;
  LPoint: TPoint;
begin
  inherited;
  if GetCursorPos(LPoint) then
  begin
    LPoint := ScreenToClient(LPoint);
    case Msg.NMHdr.code of
      NM_TVSTATEIMAGECHANGING:
      begin
        LNode := Items.GetNode(PNMTVStateImageChanging(Msg.NMHdr).hti);
        PostCheckedChange(LNode);
      end;
    end;
  end;
end;

{ TDeployFolderView }

constructor TDeployFolderView.Create(AOwner: TComponent);
begin
  inherited;
  PlatformsTreeView.OnCheckedChange := TreeViewCheckedChangeHandler;
end;

procedure TDeployFolderView.DoShow;
var
  LProject: IOTAProject;
  LProjectOptionsConfigs: IOTAProjectOptionsConfigurations;
  I: Integer;
  LConfig: IOTABuildConfiguration;
  LPlatform: string;
  LProjectPlatforms: IOTAProjectPlatforms;
  LPlatforms: TArray<string>;
  LPlatformNode: TTreeNode;
begin
  inherited;
  PlatformsTreeView.Items.Clear;
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if (LProject <> nil) and Supports(LProject, IOTAProjectPlatforms, LProjectPlatforms) then
  begin
    LPlatforms := LProjectPlatforms.SupportedPlatforms;
    TArray.Sort<string>(LPlatforms, TStringComparer.Ordinal);
    LProjectOptionsConfigs := TOTAHelper.GetProjectOptionsConfigurations(LProject);
    for LPlatform in LPlatforms do
    begin
      LPlatformNode := PlatformsTreeView.Items.AddChild(nil, LPlatform);
      for I := 0 to LProjectOptionsConfigs.ConfigurationCount - 1 do
      begin
        LConfig := LProjectOptionsConfigs.Configurations[I];
        if not LConfig.Name.Equals('Base') and (IndexStr(LPlatform, LConfig.Platforms) > -1) then
          PlatformsTreeView.Items.AddChild(LPlatformNode, LConfig.Name);
      end;
    end;
  end;
end;

// filename:       Lib\iOS\Instabug.framework\InstabugResources.bundle\InstabugDataModel.momd
// remote path:    Frameworks\Instabug.framework
// LRemoteFolder:  Instabug.framework
// Resulting remote path for the above:
//                 Frameworks\Instabug.framework\InstabugResources.bundle\InstabugDataModel.momd
// i.e. everything that comes after Instabug.framework\ is added to remote path, otherwise remote path stays the same, and add file?

procedure TDeployFolderView.OKActionExecute(Sender: TObject);
var
  I: Integer;
  LPlatformNode, LConfigNode: TTreeNode;
  LDeployConfigs: TDeployConfigs;
  LDeployConfig: TDeployConfig;
begin
  LPlatformNode := PlatformsTreeView.Items.GetFirstNode;
  while LPlatformNode <> nil do
  begin
    if LPlatformNode.IsChecked then
    begin
      LDeployConfig.PlatformName := LPlatformNode.Text;
      LDeployConfig.Configs := [];
      for I := 0 to LPlatformNode.Count - 1 do
      begin
        LConfigNode := LPlatformNode.Item[I];
        if LConfigNode.IsChecked then
          LDeployConfig.Configs := LDeployConfig.Configs + [LConfigNode.Text];
      end;
      if Length(LDeployConfig.Configs) > 0 then
        LDeployConfigs := LDeployConfigs + [LDeployConfig];
    end;
    LPlatformNode := LPlatformNode.getNextSibling;
  end;
  if Length(LDeployConfigs) > 0 then
    TCodexOTAHelper.DeployFolder(SourcePathEdit.Text, RemotePathEdit.Text, LDeployConfigs);
  ModalResult := mrOK;
end;

procedure TDeployFolderView.OKActionUpdate(Sender: TObject);
begin
  OKAction.Enabled := TDirectoryHelper.Exists(SourcePathEdit.Text) and not string(RemotePathEdit.Text).Trim.IsEmpty and
    (PlatformsTreeView.CheckedCount(False) > 0);
end;

procedure TDeployFolderView.CheckForFramework;
var
  LFolder: string;
begin
  for LFolder in string(SourcePathEdit.Text).Split(['\']) do
  begin
    if LFolder.EndsWith('.framework') then
    begin
      RemotePathEdit.Text := TPath.Combine('Frameworks', LFolder);
      Break;
    end;
  end;
end;

procedure TDeployFolderView.SelectSourcePathSpeedButtonClick(Sender: TObject);
begin
  if SourceFolderOpenDialog.Execute then
  begin
    SourcePathEdit.Text := SourceFolderOpenDialog.FileName;
    CheckForFramework;
  end;
end;

procedure TDeployFolderView.SourcePathEditChange(Sender: TObject);
begin
  if TDirectoryHelper.Exists(SourcePathEdit.Text) then
    CheckForFramework;
end;

procedure TDeployFolderView.TreeViewCheckedChangeHandler(Sender: TObject; const ANode: TTreeNode);
begin
  ANode.CheckChildren;
end;

end.
