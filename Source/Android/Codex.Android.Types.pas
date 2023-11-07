unit Codex.Android.Types;

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

type
  TJarProjectConfig = record
    IncludedJars: TArray<string>;
    JavaFiles: TArray<string>;
    OutputFile: string;
    SourceVersion: string;
    TargetVersion: string;
    function Load(const AFileName: string): Boolean;
    procedure Save(const AFileName: string);
  end;

implementation

uses
  System.IOUtils, System.Rtti,
  DW.JSON,
  Neon.Core.Types, Neon.Core.Persistence, Neon.Core.Persistence.JSON;

type
  TJarProjectConfigHelper = record helper for TJarProjectConfig
    function DoLoad(const AFileName: string): Boolean;
    procedure DoSave(const AFileName: string);
  end;

{ TJarProjectConfig }

function TJarProjectConfig.Load(const AFileName: string): Boolean;
begin
  Result := DoLoad(AFileName);
end;

procedure TJarProjectConfig.Save(const AFileName: string);
begin
  DoSave(AFileName);
end;

{ TJarProjectConfigHelper }

function TJarProjectConfigHelper.DoLoad(const AFileName: string): Boolean;
var
  LConfig: INeonConfiguration;
begin
  Result := False;
  if TFile.Exists(AFileName) then
  begin
    // Original code used Delphi classes for JSON persistence, which writes as Camel Case
    LConfig := TNeonConfiguration.Default.SetMemberCase(TNeonCase.CamelCase);
    Self := TNeon.JSONToValue<TJarProjectConfig>(TFile.ReadAllText(AFileName), LConfig);
    Result := True;
  end;
end;

procedure TJarProjectConfigHelper.DoSave(const AFileName: string);
var
  LConfig: INeonConfiguration;
begin
  // Original code used Delphi classes for JSON persistence, which writes as Camel Case
  LConfig := TNeonConfiguration.Default.SetMemberCase(TNeonCase.CamelCase);
  TFile.WriteAllText(AFileName, TJsonHelper.Tidy(TNeon.ValueToJSONString(TValue.From(Self), LConfig)));
end;

end.
