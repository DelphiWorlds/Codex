unit Codex.Modules.Types;

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
  System.JSON,
  DelphiAST.Classes;

type
  TTextChange = record
    ColNo: Integer;
    LineNo: Integer;
    NewText: string;
    OriginalText: string;
    constructor Create(const ALineNo, AColNo: Integer; const AOriginalText, ANewText: string);
  end;

  TTextChanges = TArray<TTextChange>;

  TFormTemplateProcessor = class(TObject)
  private
    FExistingObjectName: string;
    FNewObjectName: string;
    FSourceID: string;
    FTargetID: string;
    FTextChanges: TTextChanges;
    function ChangeText(const ALine: string; const AOffset: Integer; const AChange: TTextChange): string;
    procedure GetMethodPrefixChanges(const ANode: TSyntaxNode);
    procedure GetTypeNameChanges(const ANode: TSyntaxNode);
    procedure GetVarNameChanges(const ANode: TSyntaxNode);
    function RenameFormObject: Boolean;
    function RenameUnitObject: Boolean;
  public
    class function GetExistingName(const ASourceID: string): string;
  public
    function Execute(const ASourceID, ATargetID, ANewObjectName: string): Boolean;
  end;

implementation

uses
  System.SysUtils, System.Classes, System.IOUtils, System.Character,
  DelphiAST, DelphiAST.Consts,
  DW.OSLog,
  DW.JSON;

type
  TFileParser = class(TStreamReader)
  private
    const cDefaultWhitespaceChars: TCharArray = [#0, #9, #10, #13, #32, #160];
  private
    FLine: string;
    FStream: TMemoryStream;
    FToken: string;
    FWhitespace: string;
    FWhitespaceChars: TCharArray;
    procedure GetNextLine;
    function GetNextToken: Boolean;
    function IsWhitespace(const AChar: Char): Boolean;
  public
    constructor Create(const AFileName: string);
    destructor Destroy; override;
    function NextToken: Boolean;
    property Token: string read FToken;
    property Whitespace: string read FWhitespace;
    property WhitespaceChars: TCharArray read FWhitespaceChars;
  end;

  TMemoryStreamWriter = class(TStreamWriter)
  private
    FStream: TMemoryStream;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SaveToFile(const AFileName: string);
  end;

{ TTextChange }

constructor TTextChange.Create(const ALineNo, AColNo: Integer; const AOriginalText, ANewText: string);
begin
  ColNo := AColNo;
  LineNo := ALineNo;
  NewText := ANewText;
  OriginalText := AOriginalText;
end;

{ TFileParser }

constructor TFileParser.Create(const AFileName: string);
begin
  FWhitespaceChars := cDefaultWhitespaceChars;
  FStream := TMemoryStream.Create;
  FStream.LoadFromFile(AFileName);
  inherited
end;

destructor TFileParser.Destroy;
begin
  FStream.Free;
  inherited;
end;

function TFileParser.IsWhitespace(const AChar: Char): Boolean;
begin
  Result := AChar.IsInArray(FWhitespaceChars);
end;

procedure TFileParser.GetNextLine;
begin
  FLine := ReadLine;
  if not EndOfStream then
    FLine := FLine + #13#10;
end;

function TFileParser.GetNextToken: Boolean;
var
  I: Integer;
begin
  Result := False;
  if not FLine.IsEmpty then
  begin
    I := 0;
    while (I < Length(FLine)) and not IsWhitespace(FLine.Chars[I]) do
    begin
      FToken := FToken + FLine.Chars[I];
      Inc(I);
    end;
    repeat
      if I = Length(FLine) then
      begin
        GetNextLine;
        I := 0;
      end;
      while (I < Length(FLine)) and IsWhitespace(FLine.Chars[I]) do
      begin
        FWhitespace := FWhitespace + FLine.Chars[I];
        Inc(I);
      end;
    until FLine.IsEmpty or (I < Length(FLine));
    if I < Length(FLine) then
      FLine := FLine.Substring(I)
    else
      FLine := '';
    Result := not FToken.IsEmpty;
  end;
end;

function TFileParser.NextToken: Boolean;
begin
  FToken := '';
  FWhitespace := '';
  if FLine.IsEmpty and not EndOfStream then
  begin
    FLine := ReadLine;
    if not EndOfStream then
      FLine := FLine + #13#10;
  end;
  Result := GetNextToken;
end;

{ TMemoryStreamWriter }

constructor TMemoryStreamWriter.Create;
begin
  FStream := TMemoryStream.Create;
  inherited Create(FStream);
end;

destructor TMemoryStreamWriter.Destroy;
begin
  FStream.Free;
  inherited;
end;

procedure TMemoryStreamWriter.SaveToFile(const AFileName: string);
begin
  FStream.SaveToFile(AFileName);
end;

{ TFormTemplateProcessor }

function TFormTemplateProcessor.Execute(const ASourceID, ATargetID, ANewObjectName: string): Boolean;
begin
  FSourceID := ASourceID;
  FTargetID := ATargetID;
  FNewObjectName := ANewObjectName;
  Result := RenameFormObject and RenameUnitObject;
end;

function TFormTemplateProcessor.ChangeText(const ALine: string; const AOffset: Integer; const AChange: TTextChange): string;
var
  LIndex, LColNo: Integer;
begin
  Result := ALine;
  if AChange.ColNo > 0 then
  begin
    LColNo := AChange.ColNo + AOffset;
    LIndex := Result.ToLower.IndexOf(AChange.OriginalText.ToLower, LColNo - 1);
    if LIndex = LColNo - 1 then
    begin
      Delete(Result, LIndex + 1, Length(AChange.OriginalText));
      Insert(AChange.NewText, Result, LIndex + 1);
    end;
  end
  else
    Result := Result.Replace(AChange.OriginalText, AChange.NewText, [rfIgnoreCase]);
end;

class function TFormTemplateProcessor.GetExistingName(const ASourceID: string): string;
var
  LParser: TFileParser;
  LFormFileName: string;
begin
  Result := '';
  LFormFileName := ASourceID + '.fmx';
  if not TFile.Exists(LFormFileName) then
    LFormFileName := ASourceID + '.dfm';
  if TFile.Exists(LFormFileName) then
  begin
    LParser := TFileParser.Create(LFormFileName);
    try
      while LParser.NextToken and not SameText(LParser.Token, 'object') do ;
        // i.e. Do nothing
      if LParser.NextToken then
        Result := LParser.Token.TrimRight([':']);
    finally
      LParser.Free;
    end;
  end;
end;

procedure TFormTemplateProcessor.GetMethodPrefixChanges(const ANode: TSyntaxNode);
var
  I: Integer;
  LNode: TSyntaxNode;
  LNodeName, LExistingMethodPrefix, LMethodPrefix: string;
begin
  LExistingMethodPrefix := 'T' + FExistingObjectName + '.';
  LMethodPrefix := 'T' + FNewObjectName + '.';
  for I := 0 to High(ANode.ChildNodes) do
  begin
    LNode := ANode.ChildNodes[I];
    if LNode.Typ = ntMethod then
    begin
      LNodeName := LNode.GetAttribute(TAttributeName.anName);
      if LNodeName.StartsWith(LExistingMethodPrefix, True) then
        FTextChanges := FTextChanges + [TTextChange.Create(LNode.Line, 0, LExistingMethodPrefix, LMethodPrefix)];
    end;
  end;
end;

procedure TFormTemplateProcessor.GetTypeNameChanges(const ANode: TSyntaxNode);
var
  I: Integer;
  LNode: TSyntaxNode;
begin
  for I := 0 to High(ANode.ChildNodes) do
  begin
    LNode := ANode.ChildNodes[I];
    if LNode.Typ = ntTypeDecl then
    begin
      if SameText(LNode.GetAttribute(TAttributeName.anName), 'T' + FExistingObjectName) then
      begin
        FTextChanges := FTextChanges + [TTextChange.Create(LNode.Line, LNode.Col, 'T' + FExistingObjectName, 'T' + FNewObjectName)];
        Break;
      end;
    end;
  end;
end;

procedure TFormTemplateProcessor.GetVarNameChanges(const ANode: TSyntaxNode);
var
  I, J: Integer;
  LNode, LVarsNodeChild: TSyntaxNode;
begin
  for I := 0 to High(ANode.ChildNodes) do
  begin
    LNode := ANode.ChildNodes[I];
    for J := 0 to High(LNode.ChildNodes) do
    begin
      LVarsNodeChild := LNode.ChildNodes[J];
      if LVarsNodeChild.Typ = ntName then
      begin
        if SameText(TValuedSyntaxNode(LVarsNodeChild).Value, FExistingObjectName) then
          FTextChanges := FTextChanges + [TTextChange.Create(LVarsNodeChild.Line, LVarsNodeChild.Col, FExistingObjectName, FNewObjectName)];
      end;
      if SameText(LVarsNodeChild.GetAttribute(TAttributeName.anName), 'T' + FExistingObjectName) then
        FTextChanges := FTextChanges + [TTextChange.Create(LVarsNodeChild.Line, LVarsNodeChild.Col, 'T' + FExistingObjectName, 'T' + FNewObjectName)];
    end;
  end;
end;

function TFormTemplateProcessor.RenameFormObject: Boolean;
var
  LParser: TFileParser;
  LWriter: TMemoryStreamWriter;
  LFormFileName, LTargetFileName: string;
begin
  Result := False;
  LFormFileName := FSourceID + '.fmx';
  if not TFile.Exists(LFormFileName) then
    LFormFileName := FSourceID + '.dfm';
  if TFile.Exists(LFormFileName) then
  begin
    LTargetFileName := FTargetID + TPath.GetExtension(LFormFileName);
    LWriter := TMemoryStreamWriter.Create;
    try
      LParser := TFileParser.Create(LFormFileName);
      try
        while LParser.NextToken and not SameText(LParser.Token, 'object') do
        begin
          LWriter.Write(LParser.Token);
          LWriter.Write(LParser.Whitespace);
        end;
        LWriter.Write(LParser.Token);
        LWriter.Write(LParser.Whitespace);
        LParser.NextToken;
        FExistingObjectName := LParser.Token.TrimRight([':']);
        LWriter.Write(FNewObjectName + ':');
        LWriter.Write(LParser.Whitespace);
        LParser.NextToken;
        LWriter.Write('T' + FNewObjectName);
        LWriter.Write(LParser.Whitespace);
        while LParser.NextToken do
        begin
          LWriter.Write(LParser.Token);
          LWriter.Write(LParser.Whitespace);
        end;
      finally
        LParser.Free;
      end;
      LWriter.SaveToFile(LTargetFileName);
      Result := True;
    finally
      LWriter.Free;
    end;
  end;
  TOSLog.d('Existing object name: ' + FExistingObjectName);
end;

function TFormTemplateProcessor.RenameUnitObject: Boolean;
var
  LUnitNode, LPartNode, LChild: TSyntaxNode;
  I, LLineNo, LLength: Integer;
  LLine, LUnitName, LUnitFileName, LTargetFileName: string;
  LChange: TTextChange;
  LWriter: TMemoryStreamWriter;
  LReader: TStreamReader;
begin
  LTargetFileName := FTargetID + '.pas';
  LUnitFileName := FSourceID + '.pas';
  LUnitName := TPath.GetFileNameWithoutExtension(TPath.GetFileName(LTargetFileName));
  Result := False;
  if TFile.Exists(LUnitFileName) then
  begin
    FTextChanges := [];
    LUnitNode := TPasSyntaxTreeBuilder.Run(LUnitFileName);
    try
      FTextChanges := FTextChanges + [TTextChange.Create(LUnitNode.Line, 0, LUnitNode.GetAttribute(TAttributeName.anName), LUnitName)];
      LPartNode := LUnitNode.FindNode(ntInterface);
      if LPartNode <> nil then
      begin
        for I := 0 to High(LPartNode.ChildNodes) do
        begin
          LChild := LPartNode.ChildNodes[I];
          if LChild.Typ = ntTypeSection then
            GetTypeNameChanges(LChild);
          if LChild.Typ = ntVariables then
            GetVarNameChanges(LChild);
        end;
      end
      else
        TOSLog.d('Did not find interface!?');
      if Length(FTextChanges) = 1 then
        TOSLog.d('Did not find any changes to make!?');
      LPartNode := LUnitNode.FindNode(ntImplementation);
      if LPartNode <> nil then
        GetMethodPrefixChanges(LPartNode)
      else
        TOSLog.d('Did not find implementation!?');
    finally
      LUnitNode.Free;
    end;
    if Length(FTextChanges) > 0 then
    begin
      LWriter := TMemoryStreamWriter.Create;
      try
        LReader := TStreamReader.Create(LUnitFileName);
        try
          LLineNo := 0;
          if not LReader.EndOfStream then
          repeat
            LLine := LReader.ReadLine;
            Inc(LLineNo);
            LLength := Length(LLine);
            for LChange in FTextChanges do
            begin
              if LChange.LineNo = LLineNo then
                LLine := ChangeText(LLine, Length(LLine) - LLength, LChange);
            end;
            LWriter.WriteLine(LLine);
          until LReader.EndOfStream;
        finally
          LReader.Free;
        end;
        LWriter.SaveToFile(LTargetFileName);
        Result := True;
      finally
        LWriter.Free;
      end;
    end;
  end;
end;

end.
