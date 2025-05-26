unit Codex.Core;

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
  Babel.Types,
  Codex.Types, Codex.Interfaces;

var
  ActiveProjectProperties: TProjectProperties;
  CodexProvider: ICodexProvider;
  CodexResources: IResourcesModule;
  ModuleNotifier: IModuleNotifier;
  MoscoProvider: IMoscoProvider;
  ProjectResources: IResourcesModule;
  ProjectToolsProvider: IProjectToolsProvider;
  Babel: TBabel;

implementation

uses
  System.IOUtils,
  DW.OSLog,
  DW.IOUtils.Helpers,
  Babel.Persistence;

procedure LoadBabel;
var
  LFakeCodeFileName: string;
begin
  Babel.LoadFromResource;
  LFakeCodeFileName := TPathHelper.GetAppDocumentsFile('fakecode.txt');
  if TFile.Exists(LFakeCodeFileName) then
  begin
    Babel.DefaultCode := TFile.ReadAllText(LFakeCodeFileName);
    TOSLog.d('Using fake code: ' + Babel.DefaultCode);
  end;
end;

initialization
  LoadBabel;

end.
