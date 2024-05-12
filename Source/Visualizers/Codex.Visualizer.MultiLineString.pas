unit Codex.Visualizer.MultiLineString;

{*******************************************************}
{                                                       }
{                      Codex                            }
{                                                       }
{         Add-in for Delphi from Delphi Worlds          }
{                                                       }
{  Copyright 2020-2024 Dave Nottage under MIT license   }
{  which is located in the root folder of this library  }
{                                                       }
{*******************************************************}

interface

implementation

uses
  System.SysUtils, System.IniFiles,
  Vcl.Forms, Vcl.ComCtrls, Vcl.ActnList, Vcl.ImgList, Vcl.Menus,
  DesignIntf, ToolsAPI,
  DW.OTA.Helpers, DW.OTA.Visualizers,
  Codex.Visualizer.MultiLineStringFrame;

type
  IMultilineStringVisualizerForm = interface
    ['{F2CBA50A-F279-40A4-A4A1-3F4EE5C992CF}']
    function GetFrame: TCustomFrame;
  end;

  TMultilineStringVisualizerForm = class(TInterfacedObject, INTACustomDockableForm, IMultilineStringVisualizerForm)
  private
    FExpression: string;
    FFrame: TCustomFrame;
  public
    { INTACustomDockableForm }
    procedure CustomizePopupMenu(PopupMenu: TPopupMenu);
    procedure CustomizeToolBar(ToolBar: TToolBar);
    function EditAction(Action: TEditAction): Boolean;
    procedure FrameCreated(AFrame: TCustomFrame);
    function GetCaption: string;
    function GetEditState: TEditState;
    function GetFrameClass: TCustomFrameClass;
    function GetIdentifier: string;
    function GetMenuActionList: TCustomActionList;
    function GetMenuImageList: TCustomImageList;
    function GetToolBarActionList: TCustomActionList;
    function GetToolBarImageList: TCustomImageList;
    procedure LoadWindowState(Desktop: TCustomIniFile; const Section: string);
    procedure SaveWindowState(Desktop: TCustomIniFile; const Section: string; IsProject: Boolean);
    { IMultilineStringVisualizerForm }
    function GetFrame: TCustomFrame;
  public
    constructor Create(const AExpression: string);
  end;

  TMultilineStringDebugVisualizer = class(TInterfacedObject, IOTADebuggerVisualizer, IOTADebuggerVisualizerExternalViewer)
  public
    { IOTADebuggerVisualizer }
    procedure GetSupportedType(Index: Integer; var TypeName: string; var AllDescendants: Boolean); virtual;
    function GetSupportedTypeCount: Integer; virtual;
    function GetVisualizerDescription: string; virtual;
    function GetVisualizerIdentifier: string; virtual;
    function GetVisualizerName: string; virtual;
    { IOTADebuggerVisualizerExternalViewer }
    function GetMenuText: string; virtual;
    function Show(const Expression, TypeName, EvalResult: string; SuggestedLeft,
      SuggestedTop: Integer): IOTADebuggerVisualizerExternalViewerUpdater; virtual;
  end;

{ TMultilineStringVisualizerForm }

constructor TMultilineStringVisualizerForm.Create(const AExpression: string);
begin
  inherited Create;
  FExpression := AExpression;
end;

procedure TMultilineStringVisualizerForm.CustomizePopupMenu(PopupMenu: TPopupMenu);
begin
  //
end;

procedure TMultilineStringVisualizerForm.CustomizeToolBar(ToolBar: TToolBar);
begin
  //
end;

function TMultilineStringVisualizerForm.EditAction(Action: TEditAction): Boolean;
begin
  Result := False;
end;

procedure TMultilineStringVisualizerForm.FrameCreated(AFrame: TCustomFrame);
begin
  FFrame := AFrame;
end;

function TMultilineStringVisualizerForm.GetCaption: string;
begin
  Result := FExpression + ': string';
end;

function TMultilineStringVisualizerForm.GetEditState: TEditState;
begin
  Result := [];
end;

function TMultilineStringVisualizerForm.GetFrame: TCustomFrame;
begin
  Result := FFrame;
end;

function TMultilineStringVisualizerForm.GetFrameClass: TCustomFrameClass;
begin
  Result := TMultiLineStringFrame;
end;

function TMultilineStringVisualizerForm.GetIdentifier: string;
begin
  Result := ClassName;
end;

function TMultilineStringVisualizerForm.GetMenuActionList: TCustomActionList;
begin
  Result := nil;
end;

function TMultilineStringVisualizerForm.GetMenuImageList: TCustomImageList;
begin
  Result := nil;
end;

function TMultilineStringVisualizerForm.GetToolBarActionList: TCustomActionList;
begin
  Result := nil;
end;

function TMultilineStringVisualizerForm.GetToolBarImageList: TCustomImageList;
begin
  Result := nil;
end;

procedure TMultilineStringVisualizerForm.LoadWindowState(Desktop: TCustomIniFile; const Section: string);
begin
  //
end;

procedure TMultilineStringVisualizerForm.SaveWindowState(Desktop: TCustomIniFile; const Section: string; IsProject: Boolean);
begin
  //
end;

{ TMultilineStringDebugVisualizer }

function TMultilineStringDebugVisualizer.GetMenuText: string;
begin
  Result := 'String (Multiline)';
end;

procedure TMultilineStringDebugVisualizer.GetSupportedType(Index: Integer; var TypeName: string; var AllDescendants: Boolean);
begin
  TypeName := 'string';
  AllDescendants := True;
end;

function TMultilineStringDebugVisualizer.GetSupportedTypeCount: Integer;
begin
  Result := 1;
end;

function TMultilineStringDebugVisualizer.GetVisualizerDescription: string;
begin
  Result := 'Displays multiline strings as plain text';
end;

function TMultilineStringDebugVisualizer.GetVisualizerIdentifier: string;
begin
  Result := 'com.delphiworlds.MultilineStringVisualizer';
end;

function TMultilineStringDebugVisualizer.GetVisualizerName: string;
begin
  Result := 'Multiline String Visualizer';
end;

function TMultilineStringDebugVisualizer.Show(const Expression, TypeName, EvalResult: string; SuggestedLeft,
  SuggestedTop: Integer): IOTADebuggerVisualizerExternalViewerUpdater;
var
  LForm: TCustomForm;
  LDockableForm: INTACustomDockableForm;
  LVisualizerForm: IMultilineStringVisualizerForm;
begin
  LDockableForm := TMultilineStringVisualizerForm.Create(Expression);
  LForm := (BorlandIDEServices as INTAServices).CreateDockableForm(LDockableForm);
  TOTAHelper.ApplyTheme(LForm);
  LForm.Left := Suggestedleft;
  LForm.Top := SuggestedTop;
  Supports(LDockableForm, IMultilineStringVisualizerForm, LVisualizerForm);
  if Supports(LVisualizerForm.GetFrame, IOTADebuggerVisualizerExternalViewerUpdater, Result) then
    Result.RefreshVisualizer(Expression, TypeName, EvalResult);
end;

initialization
  Visualizers.Add(TMultilineStringDebugVisualizer.Create);

end.
