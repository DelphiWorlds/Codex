unit Codex.SourcePatch.ResourcesModule;

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
  System.SysUtils, System.Classes, System.Actions, Vcl.ActnList,
  Codex.CustomResourcesModule;

resourcestring
  sPatchMenuCaption = 'Source Patch';
  sCopySourcesMenuCaption = 'Copy source files';
  sCopySourceMenuCaption = 'Copy source file';
  sCopySourceToProjectMenuCaption = 'Copy file to project folder';
  sCreatePatchMenuCaption = 'Create patch file';
  sPatchSourceMenuCaption = 'Apply patch';
  sPatchSourceToProjectMenuCaption = 'Apply patch to project folder';

type
  TSourcePatchResourcesModule = class(TDataModule)
    ActionList: TActionList;
    CopySourceFromEditorAction: TAction;
    CopySourceFromEditorToProjectAction: TAction;
    CreatePatchFromEditorAction: TAction;
    PatchSourceFromEditorAction: TAction;
    SourcePatchSep1Action: TAction;
    procedure SourcePatchSep1ActionExecute(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  SourcePatchResourcesModule: TSourcePatchResourcesModule;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

uses
  Codex.Core;

{ TSourcePatchResourcesModule }

constructor TSourcePatchResourcesModule.Create(AOwner: TComponent);
begin
  inherited;
  CopySourceFromEditorAction.Caption := Babel.Tx(sCopySourceMenuCaption);
  CopySourceFromEditorToProjectAction.Caption := Babel.Tx(sCopySourceToProjectMenuCaption);
  CreatePatchFromEditorAction.Caption := Babel.Tx(sCreatePatchMenuCaption);
  PatchSourceFromEditorAction.Caption := Babel.Tx(sPatchSourceToProjectMenuCaption);
  SourcePatchSep1Action.Visible := CodexProvider.GetEditorActionList.ActionCount > 0;
end;

procedure TSourcePatchResourcesModule.SourcePatchSep1ActionExecute(Sender: TObject);
begin
  //
end;

end.
