unit Codex.Mosco.ProjectManagerMenu;

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
  System.Classes, ToolsAPI,
  DW.OTA.ProjectManagerMenu,
  Codex.Interfaces;

type
  TMoscoProjectManagerMenuNotifier = class(TProjectManagerMenuNotifier)
  private
    procedure AddProfileMenu(const AProjectManagerMenuList: IInterfaceList);
    procedure AddProfileMenuSubitems(const AProjectManagerMenuList: IInterfaceList; const AProfiles: TStrings);
    procedure AddSDKMenu(const AProjectManagerMenuList: IInterfaceList);
    procedure AddSDKMenuSubitems(const AProjectManagerMenuList: IInterfaceList; const ASDKs: TStrings);
    procedure AddSDKFramework;
    procedure ShowDeployedApp;
    procedure ShowOptions;
  public
    procedure DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings; const AProjectManagerMenuList: IInterfaceList;
      AIsMultiSelect: Boolean); override;
  end;

implementation

uses
  System.SysUtils,
  PlatformAPI,
  DW.OTA.Registry, DW.OTA.Helpers, DW.OTA.Consts,
  Codex.Consts, Codex.Core,
  Codex.Mosco.Helpers, Codex.Mosco.Consts, Codex.Types;

const
  cPMMPMoscoSection = cPMMPCodexSection + 10000;
  cPMMPMoscoProfilesSubsection = cPMMPMoscoSection + 200;
  cPMMPMoscoSDKsSubsection = cPMMPMoscoSection + 300;

type
  TCheckProvisioningProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

  TAddSDKFrameworkProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

  TAddLinkedFrameworkProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

  TBuildIPAProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

  TShowDeployedAppProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

  TSignLibrariesProjectManagerMenu = class(TProjectManagerMenu)
  public
    constructor Create(const APosition: Integer; const AExecuteProc: TProc);
    function GetEnabled: Boolean; override;
  end;

  TMacOSProjectManagerMenu = class(TProjectManagerMenu)
  public
    function GetEnabled: Boolean; override;
  end;

  TSelectProfileItemProjectManagerMenu = class(TProjectManagerMenu)
  private
    FPlatform: string;
    FProfileName: string;
    procedure SelectProfile;
  public
    constructor Create(const AProfileName, APlatform, ACaption, AParent: string; const APosition: Integer);
    function GetChecked: Boolean; override;
    function GetEnabled: Boolean; override;
  end;

  TSelectSDKItemProjectManagerMenu = class(TProjectManagerMenu)
  private
    FPlatform: string;
    FSDKName: string;
    procedure SelectSDK;
  public
    constructor Create(const ASDKName, APlatform, ACaption, AParent: string; const APosition: Integer);
    function GetChecked: Boolean; override;
    function GetEnabled: Boolean; override;
  end;

resourcestring
  sAddLinkedFrameworksCaption = 'Add Linked Frameworks';
  sAddSDKFrameworksCaption = 'Add SDK Frameworks';
  sBuildIPACaption = 'Build IPA';
  sCheckProvisioningCaption = 'Check Provisioning';
  sMoscoOptionsCaption = 'Mosco Options';
  sSelectSDKCaption = 'Select SDK';
  sSelectProfileCaption = 'Select Profile';
  sShowDeployedAppCaption = 'Show Deployed App';
  sSignLibrariesCaption = 'Sign Libraries';


{ TCheckProvisioningProjectManagerMenu }

constructor TCheckProvisioningProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sCheckProvisioningCaption), 'CheckProvisioning', APosition, AExecuteProc);
end;

function TCheckProvisioningProjectManagerMenu.GetEnabled: Boolean;
var
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  Result :=  (LProject <> nil) and (TOTAHelper.GetProjectCurrentPlatform(LProject) in cAppleProjectPlatforms);
end;

{ TAddSDKFrameworkProjectManagerMenu }

constructor TAddSDKFrameworkProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sAddSDKFrameworksCaption), 'AddSDKFrameworks', APosition, AExecuteProc);
end;

function TAddSDKFrameworkProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := True; // TODO: Need to check if there are actually any iOS/macOS SDKs
end;

{ TAddLinkedFrameworkProjectManagerMenu }

constructor TAddLinkedFrameworkProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sAddLinkedFrameworksCaption), 'AddLinkedFrameworks', APosition, AExecuteProc);
end;

function TAddLinkedFrameworkProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := True; // TODO: Need to check if there are actually any iOS/macOS SDKs
end;

{ TBuildIPAProjectManagerMenu }

constructor TBuildIPAProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sBuildIPACaption), 'BuildIPA', APosition, AExecuteProc);
end;

function TBuildIPAProjectManagerMenu.GetEnabled: Boolean;
var
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  Result :=  (LProject <> nil) and (TOTAHelper.GetProjectCurrentPlatform(LProject) in cIOSProjectPlatforms)
    and not TOTAHelper.GetProjectCurrentConnectionProfile(LProject).IsEmpty
    and (TProjectProperties.GetBuildTypeNumber(TOTAHelper.GetProjectCurrentBuildType(LProject)) in [0, 1]);
end;

{ TShowDeployedAppProjectManagerMenu }

constructor TShowDeployedAppProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sShowDeployedAppCaption), 'ShowDeployedApp', APosition, AExecuteProc);
end;

function TShowDeployedAppProjectManagerMenu.GetEnabled: Boolean;
var
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  Result :=  (LProject <> nil) and (TOTAHelper.GetProjectCurrentPlatform(LProject) in cAppleProjectPlatforms)
    and not TOTAHelper.GetProjectCurrentConnectionProfile(LProject).IsEmpty;
end;

{ TSignLibrariesProjectManagerMenu }

constructor TSignLibrariesProjectManagerMenu.Create(const APosition: Integer; const AExecuteProc: TProc);
begin
  inherited Create(Babel.Tx(sSignLibrariesCaption), 'SignLibraries', APosition, AExecuteProc);
end;

function TSignLibrariesProjectManagerMenu.GetEnabled: Boolean;
var
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  Result :=  (LProject <> nil) and (TOTAHelper.GetProjectCurrentPlatform(LProject) in cIOSProjectPlatforms);
end;

{ TMacOSProjectManagerMenu }

function TMacOSProjectManagerMenu.GetEnabled: Boolean;
var
  LProject: IOTAProject;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  Result := (LProject <> nil) and (TOTAHelper.GetProjectCurrentPlatform(LProject) in cMacOSProjectPlatforms)
    and not TOTAHelper.GetProjectCurrentConnectionProfile(LProject).IsEmpty;
end;

{ TSelectProfileItemProjectManagerMenu }

constructor TSelectProfileItemProjectManagerMenu.Create(const AProfileName, APlatform, ACaption, AParent: string; const APosition: Integer);
begin
  FProfileName := AProfileName;
  FPlatform := APlatform;
  // Do not localize the menu name
  inherited Create(ACaption, 'Select' + StringReplace(FProfileName, ' ', '', [rfReplaceAll]), APosition, SelectProfile, '', AParent);
end;

function TSelectProfileItemProjectManagerMenu.GetChecked: Boolean;
var
  LProject: IOTAProject;
  LPlatforms: IOTAProjectPlatforms;
  LProfile: IOTARemoteProfile;
begin
  Result := False;
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if (LProject <> nil) and Supports(LProject, IOTAProjectPlatforms, LPlatforms) then
  begin
    LProfile := (BorlandIDEServices as IOTARemoteProfileServices).GetDefaultForPlatform(FPlatform);
    Result := (LProfile <> nil) and LProfile.Name.Equals(FProfileName);
  end;
end;

function TSelectProfileItemProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := True;
end;

procedure TSelectProfileItemProjectManagerMenu.SelectProfile;
var
  LProject: IOTAProject;
  LPlatforms: IOTAProjectPlatforms;
  LProfileServices: IOTARemoteProfileServices;
  I: Integer;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if (LProject <> nil) and Supports(LProject, IOTAProjectPlatforms, LPlatforms) then
  begin
    LProfileServices := BorlandIDEServices as IOTARemoteProfileServices;
    for I := 0 to Length(LPlatforms.EnabledPlatforms) - 1 do
    begin
      if TOTAHelper.IsMatchingProfilePlatform(LPlatforms.EnabledPlatforms[I], FPlatform) then
      begin
        LProfileServices.SetAsDefaultForPlatform(LProfileServices.GetProfile(FProfileName));
        TBDSRegistry.Current.SetDefaultProfile(FPlatform, FProfileName);
        TOTAHelper.RefreshProjectTree;
        MoscoProvider.ProfileChanged;
        Break;
      end;
    end;
  end;
end;

{ TSelectSDKItemProjectManagerMenu }

constructor TSelectSDKItemProjectManagerMenu.Create(const ASDKName, APlatform, ACaption, AParent: string; const APosition: Integer);
var
  LCaption: string;
begin
  FSDKName := ASDKName;
  FPlatform := APlatform;
  LCaption := ACaption;
  if not FPlatform.StartsWith('Android') then
    LCaption := Format('%s (%s)', [ACaption, FPlatform]);
  // Do not localize the menu name
  inherited Create(LCaption, 'Select' + StringReplace(FSDKName, ' ', '', [rfReplaceAll]), APosition, SelectSDK, '', AParent);
end;

function TSelectSDKItemProjectManagerMenu.GetChecked: Boolean;
var
  LProject: IOTAProject;
  LPlatforms: IOTAProjectPlatforms;
  LSDK: IOTAPlatformSDK;
begin
  Result := False;
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if (LProject <> nil) and Supports(LProject, IOTAProjectPlatforms, LPlatforms) then
  begin
    LSDK := (BorlandIDEServices as IOTAPlatformSDKServices).GetDefaultForPlatform(FPlatform);
    Result := (LSDK <> nil) and LSDK.Name.Equals(FSDKName);
  end;
end;

function TSelectSDKItemProjectManagerMenu.GetEnabled: Boolean;
begin
  Result := True;
end;

procedure TSelectSDKItemProjectManagerMenu.SelectSDK;
var
  LProject: IOTAProject;
  LPlatforms: IOTAProjectPlatforms;
  LSDKServices: IOTAPlatformSDKServices;
  I: Integer;
begin
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if (LProject <> nil) and Supports(LProject, IOTAProjectPlatforms, LPlatforms) then
  begin
    LSDKServices := BorlandIDEServices as IOTAPlatformSDKServices;
    for I := 0 to Length(LPlatforms.EnabledPlatforms) - 1 do
    begin
      if LPlatforms.EnabledPlatforms[I].Equals(FPlatform) then
      begin
        TOTAHelper.SetProjectSDKVersion(LProject, FPlatform, FSDKName);
        LSDKServices.SetAsDefaultForPlatform(LSDKServices.GetPlatformSDK(FSDKName), FPlatform);
        TBDSRegistry.Current.SetDefaultSDK(FPlatform, FSDKName);
        TOTAHelper.RefreshProjectTree;
        Break;
      end;
    end;
  end;
end;

{ TMoscoProjectManagerMenuNotifier }

procedure TMoscoProjectManagerMenuNotifier.DoAddMenu(const AProject: IOTAProject; const AIdentList: TStrings;
  const AProjectManagerMenuList: IInterfaceList; AIsMultiSelect: Boolean);
begin
  AProjectManagerMenuList.Add(TProjectManagerMenuSeparator.Create(cPMMPMoscoSection));
  AProjectManagerMenuList.Add(TProjectManagerMenu.Create(Babel.Tx(sMoscoOptionsCaption), 'MoscoOptions', cPMMPMoscoSection + 100, ShowOptions));
  AProjectManagerMenuList.Add(TAddSDKFrameworkProjectManagerMenu.Create(cPMMPMoscoSection + 110, AddSDKFramework));
  // Deferred
  // AProjectManagerMenuList.Add(TAddLinkedFrameworkProjectManagerMenu.Create(cPMMPMoscoSection + 115, FWizard.AddLinkedFramework));
  AddProfileMenu(AProjectManagerMenuList);
  AddSDKMenu(AProjectManagerMenuList);
  AProjectManagerMenuList.Add(TShowDeployedAppProjectManagerMenu.Create(cPMMPMoscoSection + 710, ShowDeployedApp));
end;

procedure TMoscoProjectManagerMenuNotifier.ShowDeployedApp;
begin
  MoscoProvider.ShowDeployedApp;
end;

procedure TMoscoProjectManagerMenuNotifier.ShowOptions;
begin
  MoscoProvider.ShowOptions;
end;

procedure TMoscoProjectManagerMenuNotifier.AddProfileMenu(const AProjectManagerMenuList: IInterfaceList);
var
  LProfiles: TStrings;
begin
  LProfiles := TStringList.Create;
  try
    TBDSRegistry.Current.GetRemoteProfileNames(LProfiles);
    AddProfileMenuSubitems(AProjectManagerMenuList, LProfiles);
  finally
    LProfiles.Free;
  end;
end;

procedure TMoscoProjectManagerMenuNotifier.AddSDKFramework;
begin
  MoscoProvider.AddSDKFramework;
end;

procedure TMoscoProjectManagerMenuNotifier.AddSDKMenu(const AProjectManagerMenuList: IInterfaceList);
var
  LSDKs: TStrings;
begin
  LSDKs := TStringList.Create;
  try
    TBDSRegistry.Current.GetPlatformSDKs(LSDKs);
    AddSDKMenuSubitems(AProjectManagerMenuList, LSDKs);
  finally
    LSDKs.Free;
  end;
end;

procedure TMoscoProjectManagerMenuNotifier.AddSDKMenuSubitems(const AProjectManagerMenuList: IInterfaceList; const ASDKs: TStrings);
var
  I: Integer;
  LPlatform, LCurrentPlatform, LSinglePlatform, LDisplayName: string;
  LSDKPlatforms: TStringList;
  LSDKItems: Integer;
  LParts: TArray<string>;
  LProject: IOTAProject;
  LPlatforms: IOTAProjectPlatforms;
  LRegistry: TBDSRegistry;
begin
  LSDKItems := 0;
  LCurrentPlatform := '';
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if (LProject <> nil) and Supports(LProject, IOTAProjectPlatforms, LPlatforms) then
  begin
    LRegistry := TBDSRegistry.Current;
    LSDKPlatforms := TStringList.Create;
    try
      for I := 0 to ASDKs.Count - 1 do
      begin
        if LRegistry.OpenSubKey(cRegistryPathPlatformSDKs + '\' + ASDKs[I], False) then
        try
          LPlatform := LRegistry.ReadString('PlatformName');
          LDisplayName := LRegistry.ReadString('SDKDisplayName');
        finally
          LRegistry.CloseKey;
        end;
        for LSinglePlatform in LPlatform.Split([';']) do
          LSDKPlatforms.Add(Format('%s;%s;%s', [LDisplayName, ASDKs[I], LSinglePlatform]));
      end;
      LSDKPlatforms.Sort;
      for I := 0 to LSDKPlatforms.Count - 1 do
      begin
        LParts := LSDKPlatforms[I].Split([';']);
        LPlatform := LParts[2];
        if not LCurrentPlatform.IsEmpty and not LCurrentPlatform.Equals(LPlatform) and LPlatforms.Supported[LPlatform] then
        begin
          Inc(LSDKItems);
          AProjectManagerMenuList.Add(TProjectManagerMenuSeparator.Create(cPMMPMoscoSDKsSubsection + (LSDKItems * 5), 'SelectSDK'));
          LCurrentPlatform := LPlatform;
        end;
        if LCurrentPlatform.IsEmpty then
          LCurrentPlatform := LPlatform;
        Inc(LSDKItems);
        AProjectManagerMenuList.Add(TSelectSDKItemProjectManagerMenu.Create(LParts[1], LPlatform, LParts[0], 'SelectSDK',
          cPMMPMoscoSDKsSubsection + (LSDKItems * 5)));
      end;
    finally
      LSDKPlatforms.Free;
    end;
    if LSDKItems > 0 then
      AProjectManagerMenuList.Add(TProjectManagerMenu.Create(Babel.Tx(sSelectSDKCaption), 'SelectSDK', cPMMPMoscoSDKsSubsection, nil));
  end;
end;

procedure TMoscoProjectManagerMenuNotifier.AddProfileMenuSubitems(const AProjectManagerMenuList: IInterfaceList; const AProfiles: TStrings);
var
  I: Integer;
  LPlatform, LCurrentPlatform, LCaption: string;
  LProfileItems: Integer;
  LProject: IOTAProject;
  LPlatforms: IOTAProjectPlatforms;
  LRegistry: TBDSRegistry;
begin
  LProfileItems := 0;
  LCurrentPlatform := '';
  LProject := TOTAHelper.GetCurrentSelectedProject;
  if (LProject <> nil) and Supports(LProject, IOTAProjectPlatforms, LPlatforms) then
  begin
    LRegistry := TBDSRegistry.Current;
    for I := 0 to AProfiles.Count - 1 do
    begin
      if LRegistry.OpenSubKey(cRegistryPathRemoteProfiles + '\' + AProfiles[I], False) then
      try
        LPlatform := LRegistry.ReadString('Platform');
        if not LPlatform.IsEmpty and LPlatforms.Supported[LPlatform] then
        begin
          if not LCurrentPlatform.IsEmpty and not LCurrentPlatform.Equals(LPlatform) then
          begin
            Inc(LProfileItems);
            AProjectManagerMenuList.Add(TProjectManagerMenuSeparator.Create(cPMMPMoscoProfilesSubsection + (LProfileItems * 5), 'SelectProfile'));
            LCurrentPlatform := LPlatform;
          end;
          if LCurrentPlatform.IsEmpty then
            LCurrentPlatform := LPlatform;
          Inc(LProfileItems);
          LCaption := Format('%s (%s:%d)', [AProfiles[I], LRegistry.ReadString('HostName'), LRegistry.ReadInteger('PortNumber')]);
          AProjectManagerMenuList.Add(TSelectProfileItemProjectManagerMenu.Create(AProfiles[I], LPlatform, LCaption, 'SelectProfile',
            cPMMPMoscoProfilesSubsection + (LProfileItems * 5)));
        end;
      finally
        LRegistry.CloseKey;
      end;
    end;
    if LProfileItems > 0 then
      AProjectManagerMenuList.Add(TProjectManagerMenu.Create(Babel.Tx(sSelectProfileCaption), 'SelectProfile', cPMMPMoscoProfilesSubsection, nil));
  end;
end;

end.
