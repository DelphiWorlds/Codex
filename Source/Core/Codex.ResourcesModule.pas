unit Codex.ResourcesModule;

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
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls, System.Actions, Vcl.ActnList, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.VirtualImageList,
  Codex.CustomResourcesModule;

type
  TCodexResourcesModule = class(TDataModule)
    ActionList: TActionList;
    GotoInterfaceUsesAction: TAction;
    GotoImplementationUsesAction: TAction;
    VirtualImageList: TVirtualImageList;
    ImageCollection: TImageCollection;
    EnvVarsAction: TAction;
    SDKManagerAction: TAction;
    KillLSPAction: TAction;
    PathSetsAction: TAction;
    AskAIAction: TAction;
    EditorActionList: TActionList;
    CodexEditorAction: TAction;
    AddToProjectAction: TAction;
    procedure CodexEditorActionExecute(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  ToolsAPI,
  DW.OTA.Helpers,
  DW.OSLog,
  Codex.Core, Codex.Consts.Text;

{ TCodexResourcesModule }

constructor TCodexResourcesModule.Create(AOwner: TComponent);
begin
  inherited;
  CodexResources := Self;
  AddToProjectAction.Caption := Babel.Tx(sAddToProjectMenuCaption);
end;

procedure TCodexResourcesModule.CodexEditorActionExecute(Sender: TObject);
begin
  // This handler needs to be here in order for the menu item to be enabled
end;

end.
