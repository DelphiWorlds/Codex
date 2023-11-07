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
  MoscoProvider: IMoscoProvider;
  ProjectResources: IResourcesModule;
  ProjectToolsProvider: IProjectToolsProvider;
  ModuleNotifier: IModuleNotifier;
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
    Babel.FakeCode := TFile.ReadAllText(LFakeCodeFileName);
    TOSLog.d('Using fake code: ' + Babel.FakeCode);
  end;
end;

initialization
  LoadBabel;

end.
