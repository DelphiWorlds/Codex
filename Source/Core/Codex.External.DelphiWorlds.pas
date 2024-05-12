unit Codex.External.DelphiWorlds;

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
  ToolsAPI,
  Codex.Types;

type
  IDelphiWorlds = interface(IInterface)
    ['{1E5025D7-B015-4AC6-97D8-49A92C619154}']
    procedure ProjectModified(const AProject: IOTAProject);
    procedure ShowSpecialOptions;
    procedure SysJarsMismatch;
    procedure UseSymbolUnits(const ASourceSymbols: TSourceSymbols);
  end;

var
  DelphiWorlds: IDelphiWorlds;

implementation

// This define is used by Delphi Worlds only - there is no other reason to enable it
{.$DEFINE DelphiWorlds}

{$IF Defined(DelphiWorlds)}
uses
  Codex.Internal.Wizard;
{$ENDIF}

end.
