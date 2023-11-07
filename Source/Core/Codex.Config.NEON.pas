unit Codex.Config.NEON;

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
  Codex.Config;

type
  TCodexConfigHelper = record helper for TCodexConfig
    function GetConfigFileName: string;
    procedure DoLoad;
    procedure DoSave;
  end;

implementation

uses
  System.IOUtils, System.Rtti, System.SysUtils,
  Neon.Core.Persistence.JSON,
  DW.IOUtils.Helpers, DW.JSON;

{ TCodexConfigHelper }

function TCodexConfigHelper.GetConfigFileName: string;
begin
  Result := TPathHelper.GetAppDocumentsFile('config.json');
end;

procedure TCodexConfigHelper.DoLoad;
begin
  if TFile.Exists(GetConfigFileName) then
    Self := TNeon.JSONToValue<TCodexConfig>(TFile.ReadAllText(GetConfigFileName));
end;

procedure TCodexConfigHelper.DoSave;
begin
  TFile.WriteAllText(GetConfigFileName, TJsonHelper.Tidy(TNeon.ValueToJSONString(TValue.From(Self))));
end;

end.
