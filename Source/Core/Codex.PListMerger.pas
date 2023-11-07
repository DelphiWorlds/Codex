unit Codex.PListMerger;

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

type
  TPListMerger = record
  public
    class function MergePList(const AMergeFileName, APListFileName: string; const ADebug: Boolean = False): Integer; static;
  end;

implementation

uses
  System.IOUtils, System.SysUtils,
  Xml.XmlDoc, Xml.XmlIntf, Xml.Win.msxmldom;

type
  TNodes = TArray<IXMLNode>;
  TArrayKind = (Unknown, StringArray, DictArray);

  TKeyValuePair = record
    Key: IXMLNode;
    Value: IXMLNode;
    constructor Create(const AKey: IXMLNode);
  end;

  TKeyValuePairs = TArray<TKeyValuePair>;

{ TKeyValuePair }

constructor TKeyValuePair.Create(const AKey: IXMLNode);
begin
  Key := AKey.CloneNode(True);
  Value := AKey.NextSibling.CloneNode(True);
end;

function GetKeys(const ADict: IXMLNode): TNodes;
var
  I: Integer;
begin
  Result := [];
  for I := 0 to ADict.ChildNodes.Count - 1 do
  begin
    if ADict.ChildNodes[I].NodeName.Equals('key') then
      Result := Result + [ADict.ChildNodes[I]];
  end;
end;

function IndexOfKey(const AKeyName: string; const AKeys: TNodes): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to Length(AKeys) - 1 do
  begin
    if AKeys[I].Text.Equals(AKeyName) then
    begin
      Result := I;
      Break;
    end;
  end;
end;

function KeysMatch(const AKeysA, AKeysB: TNodes): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Length(AKeysA) - 1 do
  begin
    if IndexOfKey(AKeysA[I].Text, AKeysB) > -1 then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function FindKey(const ADict: IXMLNode; const AKeyName: string; out AKey: IXMLNode): Boolean;
var
  I: Integer;
  LNodeName, LNodeText: string;
begin
  Result := False;
  for I := 0 to ADict.ChildNodes.Count - 1 do
  begin
    LNodeName := ADict.ChildNodes[I].NodeName;
    if LNodeName.Equals('key') then
    begin
      LNodeText := ADict.ChildNodes[I].Text;
      if LNodeText.Equals(AKeyName) then
      begin
        AKey := ADict.ChildNodes[I];
        Result := True;
        Break;
      end;
    end;
  end;
end;

function FindNode(const AParent: IXMLNode; const ANodeName: string; out ANode: IXMLNode): Boolean;
begin
  Result := False;
  if AParent <> nil then
  begin
    ANode := AParent.ChildNodes.FindNode(ANodeName);
    Result := ANode <> nil;
  end;
end;

function IsBooleanValue(const AValue: IXMLNode): Boolean;
begin
  Result := AValue.NodeName.ToLower.Equals('true') or AValue.NodeName.ToLower.Equals('false');
end;

function ArrayValueExists(const AValue: string; const AArray: IXMLNode): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to AArray.ChildNodes.Count - 1 do
  begin
    if AArray.ChildNodes[I].Text.Equals(AValue) then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function FindDict(const ADictArray, AMergeDict: IXMLNode; out ADict: IXMLNode): Boolean;
var
  I: Integer;
  LMergeKeys: TNodes;
  LArrayDict: IXMLNode;
begin
  Result := False;
  LMergeKeys := GetKeys(AMergeDict);
  for I := 0 to ADictArray.ChildNodes.Count - 1 do
  begin
    LArrayDict := ADictArray.ChildNodes[I];
    if KeysMatch(GetKeys(LArrayDict), LMergeKeys) then
    begin
      ADict := LArrayDict;
      Result := True;
    end;
  end;
end;

procedure MergeKeyValue(const APListNodes: IXMLNodeList; const APListKey, AMergeKey: IXMLNode); forward;

procedure MergeDict(const AParentNodes: IXMLNodeList; const APListDict, AMergeDict: IXMLNode);
var
  LPListKeys: TNodes;
  LMergeKey, LPListKey: IXMLNode;
  LPair: TKeyValuePair;
  LPairsToAdd: TKeyValuePairs;
begin
  LPairsToAdd := [];
  LPListKeys := GetKeys(APListDict);
  for LMergeKey in GetKeys(AMergeDict) do
  begin
    if FindKey(APListDict, LMergeKey.Text, LPListKey) then
      MergeKeyValue(APListDict.ChildNodes, LPListKey, LMergeKey)
    else
      LPairsToAdd := LPairsToAdd + [TKeyValuePair.Create(LMergeKey)];
  end;
  for LPair in LPairsToAdd do
  begin
    AParentNodes.Add(LPair.Key);
    AParentNodes.Add(LPair.Value);
  end;
end;

procedure MergeArray(const AParentNodes: IXMLNodeList; const APListArray, AMergeArray: IXMLNode);
var
  I: Integer;
  LArrayKind: TArrayKind;
  LFirstName: string;
  LValue, LPListDict: IXMLNode;
begin
  if APListArray.ChildNodes.Count > 0 then
  begin
    LFirstName := APListArray.ChildNodes[0].NodeName.ToLower;
    if LFirstName.Equals('string') then
      LArrayKind := TArrayKind.StringArray
    else if LFirstName.Equals('array') then
      LArrayKind := TArrayKind.DictArray
    else
      LArrayKind := TArrayKind.Unknown;
    for I := 0 to AMergeArray.ChildNodes.Count - 1 do
    begin
      LValue := AMergeArray.ChildNodes[I];
      case LArrayKind of
        TArrayKind.StringArray:
        begin
          // If the value does not exist, add it
          if not ArrayValueExists(LValue.Text, APListArray) then
            APListArray.ChildNodes.Add(LValue.CloneNode(True));
        end;
        TArrayKind.DictArray:
        begin
          // Find dict in the PList array matching ALL keys
          if FindDict(APListArray, LValue, LPListDict) then
            MergeDict(APListArray.ChildNodes, LPListDict, LValue);
        end;
      end;
    end;
  end;
end;

procedure MergeKeyValue(const APListNodes: IXMLNodeList; const APListKey, AMergeKey: IXMLNode);
var
  LPListValue, LMergeValue: IXMLNode;
begin
  LPListValue := APListKey.NextSibling;
  LMergeValue := AMergeKey.NextSibling;
  if (LPListValue <> nil) and (LMergeValue <> nil) then
  begin
    if IsBooleanValue(LPListValue) and IsBooleanValue(LMergeValue) then
      APListNodes.ReplaceNode(LPListValue, LMergeValue.CloneNode(True))
    else if LPListValue.NodeName.ToLower.Equals('string') and LMergeValue.NodeName.ToLower.Equals('string') then
      APListNodes.ReplaceNode(LPListValue, LMergeValue.CloneNode(True))
    else if LPListValue.NodeName.ToLower.Equals('dict') and LMergeValue.NodeName.ToLower.Equals('dict') then
      MergeDict(LPListValue.ChildNodes, LPListValue, LMergeValue)
    else if LPListValue.NodeName.ToLower.Equals('array') and LMergeValue.NodeName.ToLower.Equals('array') then
      MergeArray(APListNodes, LPListValue, LMergeValue);
  end;
end;

class function TPListMerger.MergePList(const AMergeFileName, APListFileName: string; const ADebug: Boolean = False): Integer;
var
  LPList, LMerge: IXMLDocument;
  LPListDict, LMergeDict: IXMLNode;
begin
  // TODO: The exit statements here look messy - to be refactored
  if not TFile.Exists(APListFileName) or not TFile.Exists(AMergeFileName) then
    Exit(1);
  MSXMLDOMDocumentFactory.AddDOMProperty('ProhibitDTD', False);
  LPList := LoadXMLDocument(APListFileName);
  if FindNode(LPList.DocumentElement, 'dict', LPListDict) then
  begin
    LMerge := LoadXMLDocument(AMergeFileName);
    if FindNode(LMerge.DocumentElement, 'dict', LMergeDict) then
      MergeDict(LPListDict.ChildNodes, LPListDict, LMergeDict)
    else
      Exit(3);
  end
  else
    Exit(2);
  if ADebug then
    LPList.SaveToFile(TPath.ChangeExtension(APListFileName, '.debug.plist'))
  else
    LPList.SaveToFile(APListFileName);
  Result := 0;
end;

end.
