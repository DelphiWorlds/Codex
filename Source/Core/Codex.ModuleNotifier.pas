unit Codex.ModuleNotifier;

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
  DW.OTA.Notifiers,
  Codex.Interfaces;

type
  TModuleItem = record
    NotifierIndex: Integer;
    FileName: string;
  end;

  TModuleItems = TArray<TModuleItem>;

  TProjectItem = record
    Notifier: IOTAModuleNotifier;
    NotifierIndex: Integer;
    FileName: string;
  end;

  TProjectItems = TArray<TProjectItem>;

  TModuleListeners = TArray<IModuleListener>;

  TCodexModuleNotifier = class(TNonRefInterfacedObject, IOTANotifier, IOTAModuleNotifier, IOTAModuleNotifier80, IOTAModuleNotifier90, IModuleNotifier)
  private
    FModuleItems: TModuleItems;
    FListeners: TModuleListeners;
    FProjectItems: TProjectItems;
    function IndexOfModuleItem(const AFileName: string): Integer;
    function ModuleServices: IOTAModuleServices;
    procedure NotifyProjectSaved(const AFileName: string);
    procedure NotifySourceSaved(const AFileName: string);
    procedure RemoveProjectItem(const AModule: IOTAModule; const AFileName: string);
  public
    { IOTANotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    { IOTAModuleNotifier }
    function CheckOverwrite: Boolean;
    procedure ModuleRenamed(const ANewName: string);
    { IOTAModuleNotifier80 }
    function AllowSave: Boolean;
    function GetOverwriteFileName(Index: Integer): string;
    function GetOverwriteFileNameCount: Integer;
    procedure SetSaveFileName(const FileName: string);
    { IOTAModuleNotifier90 }
    procedure AfterRename(const OldFileName, NewFileName: string);
    procedure BeforeRename(const OldFileName, NewFileName: string);
    { IModuleNotifier }
    procedure AddListener(const AListener: IModuleListener);
  public
    procedure FileClosing(const AFileName: string);
    procedure FileOpened(const AFileName: string);
  public
    constructor Create;
  end;

implementation

uses
  DW.OSLog,
  System.SysUtils, System.DateUtils, System.IOUtils, System.StrUtils,
  Codex.Core, Codex.ProjectNotifier;

{ TCodexModuleNotifier }

constructor TCodexModuleNotifier.Create;
begin
  inherited Create;
  ModuleNotifier := Self;
end;

function TCodexModuleNotifier.ModuleServices: IOTAModuleServices;
begin
  Result := BorlandIDEServices as IOTAModuleServices;
end;

function TCodexModuleNotifier.IndexOfModuleItem(const AFileName: string): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to High(FModuleItems) do
  begin
    if SameText(FModuleItems[I].FileName, AFileName) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

procedure TCodexModuleNotifier.RemoveProjectItem(const AModule: IOTAModule; const AFileName: string);
var
  I: Integer;
begin
  for I := 0 to High(FProjectItems) do
  begin
    if SameText(FProjectItems[I].FileName, AFileName)  then
    begin
      AModule.RemoveNotifier(FProjectItems[I].NotifierIndex);
      Delete(FProjectItems, I, 1);
      Break;
    end;
  end;
end;

procedure TCodexModuleNotifier.FileClosing(const AFileName: string);
var
  LModule: IOTAModule;
  LIndex: Integer;
begin
  LModule := ModuleServices.FindModule(AFileName);
  if LModule <> nil then
  begin
    LIndex := IndexOfModuleItem(AFileName);
    if LIndex > -1 then
    begin
      LModule.RemoveNotifier(FModuleItems[LIndex].NotifierIndex);
      Delete(FModuleItems, LIndex, 1);
    end;
    RemoveProjectItem(LModule, AFileName);
  end;
end;

procedure TCodexModuleNotifier.FileOpened(const AFileName: string);
var
  LModule: IOTAModule;
  LModuleItem: TModuleItem;
  LProjectItem: TProjectItem;
  LProject: IOTAProject;
begin
  LModule := ModuleServices.FindModule(AFileName);
  if LModule <> nil then
  begin
    LModuleItem.NotifierIndex := LModule.AddNotifier(Self);
    LModuleItem.FileName := AFileName;
    FModuleItems := FModuleItems + [LModuleItem];
    if Supports(LModule, IOTAProject, LProject) then
    begin
      LProjectItem.FileName := AFileName;
      LProjectItem.Notifier := TCodexProjectNotifier.Create(AFileName);
      LProjectItem.NotifierIndex := LModule.AddNotifier(LProjectItem.Notifier);
      FProjectItems := FProjectItems + [LProjectItem];
    end;
  end;
end;

procedure TCodexModuleNotifier.AddListener(const AListener: IModuleListener);
begin
  FListeners := FListeners + [AListener];
end;

procedure TCodexModuleNotifier.AfterRename(const OldFileName, NewFileName: string);
var
  LIndex: Integer;
begin
  LIndex := IndexOfModuleItem(OldFileName);
  if LIndex > -1 then
    FModuleItems[LIndex].FileName := NewFileName;
  // In theory, if a project file is being renamed where it has not been saved before, it is being saved now :-)
  if not TFile.Exists(OldFileName) and NewFileName.EndsWith('.dproj') then
    NotifyProjectSaved(NewFileName);
end;

procedure TCodexModuleNotifier.AfterSave;
var
  LModuleServices: IOTAModuleServices;
  LModule: IOTAModule;
  LProject: IOTAProject;
  LFileName: string;
  I: Integer;
begin
  LModuleServices := BorlandIDEServices as IOTAModuleServices;
  for I := 0 to LModuleServices.ModuleCount - 1 do
  begin
    LModule := LModuleServices.Modules[I];
    LFileName := LModule.FileName;
    if TFile.Exists(LFileName) and (IndexStr(TPath.GetExtension(LFileName).ToLower, ['.pas', '.dfm', '.fmx']) > -1) then
      NotifySourceSaved(LFileName)
    else if Supports(LModule, IOTAProject, LProject) and TFile.Exists(LProject.FileName) then
    begin
      if MilliSecondsBetween(TFile.GetLastWriteTime(LProject.FileName), Now) < 250 then
      begin
        // Assume it was this project that was saved
        NotifyProjectSaved(LProject.FileName);
      end;
    end;
  end;
end;

procedure TCodexModuleNotifier.NotifyProjectSaved(const AFileName: string);
var
  LListener: IModuleListener;
begin
  for LListener in FListeners do
  try
    LListener.ProjectSaved(AFileName);
  except
    // Suppress exceptions from listeners that fail
  end;
end;

procedure TCodexModuleNotifier.NotifySourceSaved(const AFileName: string);
var
  LListener: IModuleListener;
begin
  for LListener in FListeners do
  try
    LListener.SourceSaved(AFileName);
  except
    // Suppress exceptions from listeners that fail
  end;
end;

procedure TCodexModuleNotifier.BeforeSave;
begin
  //
end;

function TCodexModuleNotifier.AllowSave: Boolean;
begin
  Result := True;
end;

procedure TCodexModuleNotifier.BeforeRename(const OldFileName, NewFileName: string);
begin
  //
end;

function TCodexModuleNotifier.CheckOverwrite: Boolean;
begin
  Result := True;
end;

procedure TCodexModuleNotifier.Destroyed;
begin
  //
end;

function TCodexModuleNotifier.GetOverwriteFileName(Index: Integer): string;
begin
  Result := '';
end;

function TCodexModuleNotifier.GetOverwriteFileNameCount: Integer;
begin
  Result := 0;
end;

procedure TCodexModuleNotifier.Modified;
begin
  //
end;

procedure TCodexModuleNotifier.ModuleRenamed(const ANewName: string);
begin
  //
end;

procedure TCodexModuleNotifier.SetSaveFileName(const FileName: string);
begin
  //
end;

end.
