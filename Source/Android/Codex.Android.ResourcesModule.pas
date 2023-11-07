unit Codex.Android.ResourcesModule;

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
  System.SysUtils, System.Classes, System.ImageList, Vcl.ImgList, Vcl.Controls, System.Actions, Vcl.ActnList, Vcl.BaseImageCollection,
  Vcl.ImageCollection, Vcl.VirtualImageList, Vcl.Dialogs,
  Codex.CustomResourcesModule;

type
  TAndroidResources = class(TDataModule)
    ActionList: TActionList;
    ADBConnectAction: TAction;
    VirtualImageList: TVirtualImageList;
    ImageCollection: TImageCollection;
    APKFolderOpenDialog: TFileOpenDialog;
  end;

var
  AndroidResources: TAndroidResources;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

end.
