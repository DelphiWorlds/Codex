unit Codex.ProjectNotifier;

interface

uses
  ToolsAPI,
  DW.OTA.Notifiers;

type
  TCodexProjectNotifier = class(TInterfacedObject, IOTANotifier, IOTAModuleNotifier)
  private
    FFileName: string;
    function ModuleServices: IOTAModuleServices;
  public
    { IOTANotifier }
    procedure AfterSave;
    procedure BeforeSave;
    procedure Destroyed;
    procedure Modified;
    { IOTAModuleNotifier }
    function CheckOverwrite: Boolean;
    procedure ModuleRenamed(const NewName: string);
  public
    constructor Create(const AFileName: string);
  end;

implementation

uses
  System.SysUtils,
  Codex.Core;

{ TCodexProjectNotifier }

constructor TCodexProjectNotifier.Create(const AFileName: string);
begin
  inherited Create;
  FFileName := AFileName;
end;

function TCodexProjectNotifier.ModuleServices: IOTAModuleServices;
begin
  Result := BorlandIDEServices as IOTAModuleServices;
end;

procedure TCodexProjectNotifier.AfterSave;
begin
  //
end;

procedure TCodexProjectNotifier.BeforeSave;
begin
  //
end;

procedure TCodexProjectNotifier.Destroyed;
begin
  //
end;

procedure TCodexProjectNotifier.Modified;
var
  LModule: IOTAModule;
  LProject: IOTAProject;
begin
  LModule := ModuleServices.FindModule(FFileName);
  if Supports(LModule, IOTAProject, LProject) then
    CodexProvider.ProjectModified(LProject);
end;

function TCodexProjectNotifier.CheckOverwrite: Boolean;
begin
  Result := True;
end;

procedure TCodexProjectNotifier.ModuleRenamed(const NewName: string);
begin
  //
end;

end.
