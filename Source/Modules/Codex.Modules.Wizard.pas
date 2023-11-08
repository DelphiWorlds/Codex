unit Codex.Modules.Wizard;

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

implementation

uses
  System.Classes, System.SysUtils,
  ToolsAPI,
  Vcl.Controls, Vcl.Menus, Vcl.Dialogs,
  DW.OTA.Wizard, DW.OTA.ProjectManagerMenu, DW.OTA.Helpers, DW.Menus.Helpers,
  Codex.Consts, Codex.Modules.Types, Codex.Modules.DuplicateModuleView, Codex.Core;

type
  TModulesWizard = class(TWizard)
  private
    FProcessor: TFormTemplateProcessor;
    procedure DuplicateModuleActionHandler(Sender: TObject);
    procedure InsertMenu;
  protected
    procedure IDEStarted; override;
  public
    constructor Create; override;
    destructor Destroy; override;
  end;

resourcestring
  sDuplicateModuleCaption = 'Duplicate Module..';

{ TModulesWizard }

constructor TModulesWizard.Create;
begin
  inherited;
  FProcessor := TFormTemplateProcessor.Create;
end;

destructor TModulesWizard.Destroy;
begin
  FProcessor.Free;
  inherited;
end;

procedure TModulesWizard.IDEStarted;
begin
  inherited;
  InsertMenu;
end;

procedure TModulesWizard.InsertMenu;
var
  LComponent: TComponent;
  LCustomizeMenu, LParent, LMenuItem: TMenuItem;
begin
  if TOTAHelper.FindComponentGlobal('mnuCustomize', LComponent) then
  begin
    LCustomizeMenu := TMenuItem(LComponent);
    LParent := LCustomizeMenu.Parent;
    LMenuItem := TMenuItem.CreateWithAction(LParent, Babel.Tx(sDuplicateModuleCaption), DuplicateModuleActionHandler);
    LParent.Insert(LCustomizeMenu.MenuIndex, LMenuItem);
    LMenuItem := TMenuItem.Create(LParent);
    LMenuItem.Caption := '-';
    LParent.Insert(LCustomizeMenu.MenuIndex, LMenuItem);
  end;
end;

// DuplicateModule allows the user to select an existing module (i.e. form, frame or datamodule) and duplicate the code/UI with a different name
// The new module can optionally be added to the current project
procedure TModulesWizard.DuplicateModuleActionHandler(Sender: TObject);
var
  LForm: TDuplicateModuleView;
  LProject: IOTAProject;
  LFileName: string;
begin
  LForm := TDuplicateModuleView.Create(nil);
  try
    if LForm.ShowModal = mrOK then
    begin
      if FProcessor.Execute(LForm.ModuleInfo.SourceID, LForm.ModuleInfo.TargetID, LForm.ModuleInfo.NewName) then
      begin
        LProject := TOTAHelper.GetActiveProject;
        LFileName := LForm.ModuleInfo.TargetID + '.pas';
        if LForm.ModuleInfo.WantAddToProject and (LProject <> nil) then
          LProject.AddFile(LFileName, True)
        else
          TOTAHelper.OpenFile(LFileName);
      end;
    end;
  finally
    LForm.Free;
  end;
end;

initialization
  TOTAWizard.RegisterWizard(TModulesWizard);

end.
