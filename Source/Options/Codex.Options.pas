unit Codex.Options;

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
  Vcl.Controls, Vcl.Forms;

type
  IConfigOptionsSection = interface(IInterface)
    ['{6BC3FBEB-5150-419A-900C-B5E2D59C5E0D}']
    function GetRootControl: TControl;
    function SectionID: string;
    function SectionTitle: string;
    procedure Save;
    procedure ShowSection;
  end;

  IConfigOptionsHost = interface(IInterface)
    ['{C9FB3E6C-ADE3-478D-9CFC-C334CF90F23A}']
    procedure ShowOptions(const ASectionID: string);
  end;

  TConfigOptionsHelper = record
  private
    class var FHost: IConfigOptionsHost;
  public
    class var Options: TArray<TFormClass>;
    class procedure RegisterHost(const AHost: IConfigOptionsHost); static;
    class procedure RegisterOptions(const AOptionsClass: TFormClass); static;
    class procedure ShowOptions(const ASectionID: string); static;
  end;

implementation

uses
  System.SysUtils;

{ TConfigOptionsHelper }

class procedure TConfigOptionsHelper.RegisterHost(const AHost: IConfigOptionsHost);
begin
  FHost := AHost;
end;

class procedure TConfigOptionsHelper.RegisterOptions(const AOptionsClass: TFormClass);
begin
  Options := Options + [AOptionsClass];
end;

class procedure TConfigOptionsHelper.ShowOptions(const ASectionID: string);
begin
  if FHost <> nil then
    FHost.ShowOptions(ASectionID);
end;

end.
