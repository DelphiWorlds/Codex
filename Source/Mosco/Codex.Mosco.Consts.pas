unit Codex.Mosco.Consts;

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

const
  cMoscoShowDeployedAppMenuItemName = 'ShowDeployedAppMenuItem';

  cRegistryPathPlatformSDKs = '\PlatformSDKs';
  cRegistryPathRemoteProfiles = '\RemoteProfiles';
  cRegistryValuePathFrameworks = '$(SDKROOT)/System/Library/Frameworks';
  cRegistryValueKeySDKDisplayName = 'SDKDisplayName';
  cRegistryValueKeyIncludeSubDir = 'IncludeSubDir';
  cRegistryValueKeyMask = 'Mask';
  cRegistryValueKeyPath = 'Path';
  cRegistryValueKeyType = 'Type';
  cRegistryValueTypeFramework = 2;

  cRegistryValueIncludeSubDirValues: array[Boolean] of string = ('0', '1');

  cMoscoOptionsSectionID = 'Mosco';
  cMoscoOptionsSectionTitle = 'Mosco'; // Do not localize

resourcestring
  cMoscoShowDeployedAppMenuItemCaption = 'Show Deployed App';

implementation

end.
