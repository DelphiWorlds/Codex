unit Codex.CustomResourcesModule;

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
  System.Classes,
  Vcl.ActnList, Vcl.ImgList,
  Codex.Interfaces;

type
  TDataModule = class(System.Classes.TDataModule, IResourcesModule)
  protected
    function GetToolbarName: string; virtual;
  public
    { IResourcesModule }
    procedure AddToolbarActions;
    function GetActionList(const AName: string): TActionList;
    function GetImageList: TCustomImageList;
    procedure LinkAction(const ALinkedAction: TAction); overload;
    procedure LinkAction(const AName: string; const AOnExecute: TNotifyEvent; const AOnUpdate: TNotifyEvent = nil); overload;
    procedure PerformAction(const AAction: TAction);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  System.SysUtils,
  ToolsAPI,
  DW.OSLog,
  DW.OTA.Helpers,
  Codex.Consts;

{ TDataModule }

constructor TDataModule.Create(AOwner: TComponent);
var
  LServices: INTAServices;
  LImageList: TCustomImageList;
  I: Integer;
  LAction: TAction;
begin
  inherited;
  LImageList := GetImageList;
  if LImageList <> nil then
  begin
    LServices := BorlandIDEServices as INTAServices;
    LServices.AddImages(LImageList);
    for I := 0 to ComponentCount - 1 do
    begin
      if Components[I] is TAction then
      begin
        LAction := TAction(Components[I]);
        if LAction.Category.IsEmpty then
          LServices.AddActionMenu('', LAction, nil);
      end;
    end;
  end;
end;

procedure TDataModule.PerformAction(const AAction: TAction);
var
  LAction: TAction;
begin
  LAction := TAction(FindComponent(AAction.Name));
  if LAction <> nil then
    LAction.Execute;
end;

procedure TDataModule.AddToolbarActions;
var
  LServices: INTAServices;
  I: Integer;
  LAction: TCustomAction;
begin
  LServices := BorlandIDEServices as INTAServices;
  for I := 0 to ComponentCount - 1 do
  begin
    if Components[I] is TCustomAction then
    begin
      LAction := TCustomAction(Components[I]);
      if LAction.Category.IsEmpty then
      begin
        LAction.Visible := LAction.Visible and Assigned(LAction.OnExecute);
        if LAction.Visible then
          TOTAHelper.AddToolbarButton(GetToolbarName, string(LAction.Name).Replace('Action', 'Button'), LAction)
      end;
    end;
  end;
end;

function TDataModule.GetActionList(const AName: string): TActionList;
begin
  Result := TActionList(FindComponent(AName));
  if Result = nil then
    TOSLog.d('Could not find actionlist: %s', [AName]);
end;

function TDataModule.GetImageList: TCustomImageList;
begin
  Result := TCustomImageList(FindComponent('VirtualImageList'));
end;

function TDataModule.GetToolbarName: string;
begin
  Result := cCodexToolbarName;
end;

procedure TDataModule.LinkAction(const AName: string; const AOnExecute: TNotifyEvent; const AOnUpdate: TNotifyEvent = nil);
var
  LAction: TAction;
begin
  LAction := TAction(FindComponent(AName));
  if LAction <> nil then
  begin
    LAction.OnExecute := AOnExecute;
    if Assigned(AOnUpdate) then
      LAction.OnUpdate := AOnUpdate;
  end
  else
    TOSLog.d('Could not find action: %s', [AName]);
end;

procedure TDataModule.LinkAction(const ALinkedAction: TAction);
var
  LAction: TAction;
begin
  LAction := TAction(FindComponent(ALinkedAction.Name));
  if LAction <> nil then
  begin
    LAction.OnExecute := ALinkedAction.OnExecute;
    LAction.OnUpdate := ALinkedAction.OnUpdate;
  end;
end;

end.
