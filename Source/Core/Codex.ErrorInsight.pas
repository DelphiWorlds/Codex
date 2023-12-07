unit Codex.ErrorInsight;

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

// This code is based on a comment by Giel Bremmers, in this report:
//   https://quality.embarcadero.com/browse/RSP-35291

interface

uses
  System.Types, System.Rtti,
  Vcl.Graphics, Vcl.VirtualImageList,
  ToolsAPI, StructureViewAPI,
  DW.OTA.Notifiers;

type
  TSourceErrorKind = (Hint, Warning, Error);

  TSourceError = record
    LineNo: Integer;
    Kind: TSourceErrorKind;
    Message: string;
    constructor Create(const AError: string);
  end;

  TSourceErrors = TArray<TSourceError>;

  TCodexErrorInsightEditViewNotifier = class(TEditViewNotifier)
  private
    FHorzScrollPos: Integer;
    FImageList: TVirtualImageList;
    FRttiContext: TRttiContext;
    procedure FindImageList;
    function GetHorzScrollPos(const AView: IOTAEditView): Integer;
  public
    procedure BeginPaint(const View: IOTAEditView; var FullRepaint: Boolean); override;
    procedure PaintLine(const View: IOTAEditView; LineNumber: Integer; const LineText: PAnsiChar; const TextWidth: Word;
      const LineAttributes: TOTAAttributeArray; const Canvas: TCanvas; const TextRect: TRect; const LineRect: TRect; const CellSize: TSize); override;
  end;

  TSourceErrorImageIndexes = array[TSourceErrorKind] of Integer;

  TCodexStructureViewNotifier = class(TStructureViewNotifier)
  private
    class var FErrors: TSourceErrors;
    class var FImageIndexes: TSourceErrorImageIndexes;
  private
    FEditNotifierViews: TArray<IOTAEditView>;
    procedure FindStructureViewErrors;
    function ViewHasNotifier(const AView: IOTAEditView): Boolean;
  protected
    class function ErrorAtLine(const ALineNo: Integer; out AError: TSourceError): Boolean;
    class property Errors: TSourceErrors read FErrors;
    class property ImageIndexes: TSourceErrorImageIndexes read FImageIndexes;
  public
    procedure StructureChanged(const Context: IOTAStructureContext); override;
  end;

implementation

uses
  System.Classes, System.Math, System.SysUtils,
  Winapi.CommCtrl,
  Vcl.Forms,
  DW.OTA.Helpers,
  Codex.Config;

{ TCodexErrorInsightEditViewNotifier }

procedure TCodexErrorInsightEditViewNotifier.FindImageList;
var
  LForm, LImageList: TComponent;
begin
  if FImageList = nil then
  begin
    if TOTAHelper.FindForm('StructureViewForm', LForm) then
    begin
      LImageList := LForm.FindComponent('NodeImages');
      if LImageList is TVirtualImageList then
        FImageList := TVirtualImageList(LImageList);
    end;
  end;
end;

function TCodexErrorInsightEditViewNotifier.GetHorzScrollPos(const AView: IOTAEditView): Integer;
var
  LForm: TCustomForm;
  I: Integer;
  LRttiType: TRttiType;
  LRttiField: TRttiField;
begin
  Result := 0;
  if (AView <> nil) and (AView.GetEditWindow <> nil) then
  begin
    LForm := View.GetEditWindow.Form;
    if LForm <> nil then
    begin
      for i := 0 to LForm.ComponentCount - 1 do
      begin
        if LForm.Components[I].ClassName = 'TEditControl' then
        begin
          LRttiType := FRTTIContext.GetType(LForm.Components[I].ClassType);
          LRttiField := LRttiType.GetField('sHScrollPos');
          if LRttiField <> nil then
          begin
            Result := LRttiField.GetValue(LForm.Components[I]).AsInteger;
            Break;
          end;
        end;
      end;
    end;
  end;
end;

procedure TCodexErrorInsightEditViewNotifier.BeginPaint(const View: IOTAEditView; var FullRepaint: Boolean);
begin
  FindImageList;
  FHorzScrollPos := GetHorzScrollPos(View);
end;

procedure TCodexErrorInsightEditViewNotifier.PaintLine(const View: IOTAEditView; LineNumber: Integer; const LineText: PAnsiChar; const TextWidth: Word;
  const LineAttributes: TOTAAttributeArray; const Canvas: TCanvas; const TextRect, LineRect: TRect; const CellSize: TSize);
const
  cUnderlineColors: array[TSourceErrorKind] of TColor = ($dfb68c, $64b5e8, $5870e3);
var
  LError: TSourceError;
  LFontColor: TColor;
  LBrushStyle: TBrushStyle;
  LPosition: Integer;
  LImageIndexes: TSourceErrorImageIndexes;
begin
  if TCodexStructureViewNotifier.ErrorAtLine(LineNumber, LError) then
  begin
    LImageIndexes := TCodexStructureViewNotifier.ImageIndexes;
    LPosition := Max(80, 8 * (2 + (TextWidth + 3) div 8));
    LPosition := (LPosition - FHorzScrollPos) * CellSize.cx;
    if (FImageList <> nil) and (LImageIndexes[LError.Kind] >= 0) then
    begin
      Inc(LPosition, CellSize.cx);
      FImageList.DoDraw(LImageIndexes[LError.Kind], Canvas, LPosition - FImageList.Width + 3,
        TextRect.Top + (TextRect.Height - FImageList.Height) div 2, ILD_NORMAL);
    end;
    LBrushStyle := Canvas.Brush.Style;
    LFontColor := Canvas.Font.Color;
    try
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := cUnderlineColors[LError.Kind];
      Canvas.TextOut(LPosition, TextRect.Top, LError.Message);
    finally
      Canvas.Brush.Style := LBrushStyle;
      Canvas.Font.Color := LFontColor;
    end;
  end;
end;

{ TSourceError }

constructor TSourceError.Create(const AError: string);
var
  LError: string;
begin
  LError := AError.Substring(AError.LastIndexOf('(') + 1);
  LError := LError.Substring(0, LError.IndexOf(':'));
  if not integer.TryParse(LError, LineNo) then
    LineNo := -1;
  case AError.Chars[0] of
    'H':
      Kind := TSourceErrorKind.Hint;
    'W':
      Kind := TSourceErrorKind.Warning;
    else
      Kind := TSourceErrorKind.Error;
  end;
  LError := AError.Substring(0, AError.LastIndexOf(' at line ')); // TODO: Might need to allow for localized text!
  Message := LError.Substring(LError.IndexOf(' '));
end;

{ TCodexStructureViewNotifier }

class function TCodexStructureViewNotifier.ErrorAtLine(const ALineNo: Integer; out AError: TSourceError): Boolean;
var
  LError: TSourceError;
begin
  Result := False;
  for LError in FErrors do
  begin
    if LError.LineNo = ALineNo then
    begin
      AError := LError;
      Result := True;
      Break;
    end;
  end;
end;

procedure TCodexStructureViewNotifier.FindStructureViewErrors;
var
  LStructureContext: IOTAStructureContext;
  LNode, LSubNode: IOTAStructureNode;
  I, J, K: Integer;
begin
  FErrors := [];
  LStructureContext := (BorlandIDEServices as IOTAStructureView).GetStructureContext;
  if LStructureContext <> nil then
  begin
    for I := 0 to LStructureContext.RootNodeCount - 1 do
    begin
      LNode := LStructureContext.GetRootStructureNode(I);
      if LNode.Name = ErrorsNodeType then
      begin
        for J := 0 to LNode.ChildCount - 1 do
        begin
          LSubNode := LNode.Child[J];
          if LSubNode.Name = ErrorsNodeType then
          begin
            SetLength(FErrors, LSubNode.ChildCount);
            for K := 0 to LSubNode.ChildCount - 1 do
            begin
              FErrors[K] := TSourceError.Create(LSubNode.Child[K].Caption);
              FImageIndexes[FErrors[K].Kind] := LSubNode.Child[K].ImageIndex;
            end;
          end;
        end;
      end;
    end;
  end;
end;

procedure TCodexStructureViewNotifier.StructureChanged(const Context: IOTAStructureContext);
var
  LEditView: IOTAEditView;
  LEditor: IOTASourceEditor;
begin
  if Config.IDE.ShowErrorInsightMessages then
  begin
    FindStructureViewErrors;
    if Length(FErrors) > 0 then
    begin
      LEditor := TOTAHelper.GetActiveSourceEditor;
      if LEditor <> nil then
      begin
        LEditView := LEditor.EditViews[0];
        if not ViewHasNotifier(LEditView) then
        begin
          TCodexErrorInsightEditViewNotifier.Create(LEditView);
          FEditNotifierViews := FEditNotifierViews + [LEditView];
        end;
      end;
    end;
  end;
end;

function TCodexStructureViewNotifier.ViewHasNotifier(const AView: IOTAEditView): Boolean;
var
  LView: IOTAEditView;
begin
  Result := False;
  for LView in FEditNotifierViews do
  begin
    if LView = AView then
    begin
      Result := True;
      Break;
    end;
  end;
end;

end.
