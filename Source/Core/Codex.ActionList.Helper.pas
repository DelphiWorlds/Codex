unit Codex.ActionList.Helper;

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
  Vcl.ActnList;

type
  TActionListHelper = class helper for TActionList
  public
    procedure AssignActions(const ASource: TActionList);
  end;

implementation

uses
  System.Actions;

{ TActionListHelper }

procedure TActionListHelper.AssignActions(const ASource: TActionList);
var
  I: Integer;
begin
  for I := 0 to ASource.ActionCount - 1 do
    AddAction(ASource.Actions[I]);
  for I := ASource.ActionCount - 1 downto 0 do
    ASource.RemoveAction(ASource.Actions[I]);
end;

end.
