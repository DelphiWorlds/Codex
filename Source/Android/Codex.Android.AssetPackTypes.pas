unit Codex.Android.AssetPackTypes;

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
  TAssetPackKind = (Unknown, InstallTime, FastFollow, OnDemand);

const
  // Do not localize these values
  cAssetPackKindDisplayValues: array[TAssetPackKind] of string = ('Unknown', 'Install Time', 'Fast Follow', 'On Demand');

type
  TAssetPack = class(TObject)
  private
    FFolder: string;
    FPackage: string;
    FPackName: string;
  protected
    FPackKind: TAssetPackKind;
    function GetPackKindFromName(const AName: string): TAssetPackKind;
    procedure SetPackKind(const Value: TAssetPackKind); virtual;
  public
    procedure Assign(const AAssetPack: TAssetPack);
    procedure Reset;
    property Folder: string read FFolder write FFolder;
    property Package: string read FPackage write FPackage;
    property PackKind: TAssetPackKind read FPackKind write SetPackKind;
    property PackName: string read FPackName write FPackName;
  end;

  TAssetPackManifest = class(TAssetPack)
  private
    FFileName: string;
    function IsValid: Boolean;
  protected
    procedure SetPackKind(const Value: TAssetPackKind); override;
  public
    constructor Create;
    function LoadFromFile(const AFileName: string): Boolean;
    function SaveToFile(const AFileName: string = ''): Boolean;
    property FileName: string read FFileName;
  end;

implementation

uses
  System.IOUtils, System.SysUtils, System.Variants,
  Xml.XMLDoc, Xml.XmlIntf;

// Typical manifest:
//
//  <manifest xmlns:android="http://schemas.android.com/apk/res/android" xmlns:dist="http://schemas.android.com/apk/distribution"
//    package="com.embarcadero.AssetDeliveryDemo" split="fastfollow_assetpack">
//    <dist:module dist:type="asset-pack">
//      <dist:fusing dist:include="true" />
//      <dist:delivery>
//        <dist:fast-follow/>
//      </dist:delivery>
//    </dist:module>
//  </manifest>

const
  cXMLNamespaceAndroid = 'http://schemas.android.com/apk/res/android';
  cXMLNamespaceAPKDist = 'http://schemas.android.com/apk/distribution';
  cXMLNamespacePrefixAndroid = 'android';
  cXMLNamespacePrefixDist = 'dist';
  cNodeNameManifest = 'manifest';
  cNodeNameModule = 'module';
  cNodeNameFusing = 'fusing';
  cNodeNameDelivery = 'delivery';
  cAssetPackAttributePackage = 'package';
  cAssetPackAttributeSplit = 'split';
  cAssetPackAttributeModuleType = 'type';
  cAssetPackAttributeFusingInclude = 'include';
  cAssetPackAttributeModuleTypeAssetPack = 'asset-pack';
  cAssetPackKindNames: array[TAssetPackKind] of string = ('', 'install-time', 'fast-follow', 'on-demand');

function FindNode(const AParentNode: IXMLNode; const ANodeName: string): IXMLNode;
var
  I: Integer;
begin
  Result := nil;
  if not AParentNode.LocalName.Equals(ANodeName) then
  begin
    for I := 0 to AParentNode.ChildNodes.Count - 1 do
    begin
      Result := FindNode(AParentNode.ChildNodes[I], ANodeName);
      if Result <> nil then
        Break;
    end;
  end
  else
    Result := AParentNode;
end;

{ TAssetPack }

procedure TAssetPack.Assign(const AAssetPack: TAssetPack);
begin
  FFolder := AAssetPack.Folder;
  FPackage := AAssetPack.Package;
  FPackName := AAssetPack.PackName;
  FPackKind := AAssetPack.PackKind;
end;

function TAssetPack.GetPackKindFromName(const AName: string): TAssetPackKind;
var
  LKind: TAssetPackKind;
begin
  Result := TAssetPackKind.Unknown;
  for LKind := Succ(Low(TAssetPackKind)) to High(TAssetPackKind) do
  begin
    if SameText(cAssetPackKindNames[LKind], AName) then
    begin
      Result := LKind;
      Break;
    end;
  end;
end;

procedure TAssetPack.Reset;
begin
  FFolder := string.Empty;
  FPackage := string.Empty;
  FPackName := string.Empty;
  FPackKind := TAssetPackKind.Unknown;
end;

procedure TAssetPack.SetPackKind(const Value: TAssetPackKind);
begin
  FPackKind := Value;
end;

{ TAssetPackManifest }

constructor TAssetPackManifest.Create;
begin
  inherited;
  //
end;

function TAssetPackManifest.IsValid: Boolean;
begin
  Result := not FPackage.IsEmpty and not FPackName.IsEmpty and (FPackKind <> TAssetPackKind.Unknown);
end;

function TAssetPackManifest.LoadFromFile(const AFileName: string): Boolean;
var
  LXML: IXMLDocument;
  LNode: IXMLNode;
begin
  Result := False;
  Reset;
  LXML := nil;
  try
    LXML := LoadXMLDocument(AFileName);
  except
    // Eat it, Harvey
  end;
  if LXML <> nil then
  begin
    LNode := LXML.DocumentElement;
    Package := VarToStr(LNode.Attributes[cAssetPackAttributePackage]).Trim;
    PackName := VarToStr(LNode.Attributes[cAssetPackAttributeSplit]).Trim;
    LNode := FindNode(LNode, cNodeNameDelivery);
    if (LNode <> nil) and (LNode.ChildNodes.Count > 0) then
      FPackKind := GetPackKindFromName(LNode.ChildNodes[0].LocalName);
    Result := IsValid;
  end;
end;

function TAssetPackManifest.SaveToFile(const AFileName: string): Boolean;
var
  LXML: IXMLDocument;
  LRootNode, LModuleNode, LNode: IXmlNode;
  LXMLString: string;
begin
  Result := False;
  if IsValid then
  begin
    LXML := NewXMLDocument;
    LRootNode := LXML.AddChild(cNodeNameManifest);
    LRootNode.DeclareNamespace(cXMLNamespacePrefixAndroid, cXMLNamespaceAndroid);
    LRootNode.DeclareNamespace(cXMLNamespacePrefixDist, cXMLNamespaceAPKDist);
    LRootNode.Attributes[cAssetPackAttributePackage] := FPackage;
    LRootNode.Attributes[cAssetPackAttributeSplit] := FPackName;
    LModuleNode := LRootNode.AddChild(cXMLNamespacePrefixDist + ':' + cNodeNameModule);
    LModuleNode.Attributes[cXMLNamespacePrefixDist + ':' + cAssetPackAttributeModuleType] := cAssetPackAttributeModuleTypeAssetPack;
    LNode := LModuleNode.AddChild(cXMLNamespacePrefixDist + ':' + cNodeNameFusing);
    LNode.Attributes[cXMLNamespacePrefixDist + ':' + cAssetPackAttributeFusingInclude] := 'true';
    LNode := LModuleNode.AddChild(cXMLNamespacePrefixDist + ':' + cNodeNameDelivery);
    LNode.AddChild(cXMLNamespacePrefixDist + ':' + cAssetPackKindNames[FPackKind]);
    LXMLString := LXML.XML.Text;
    TFile.WriteAllText(AFileName, FormatXMLData(LXMLString.Substring(LXMLString.IndexOf('>') + 1)));
    Result := True;
  end;
end;

procedure TAssetPackManifest.SetPackKind(const Value: TAssetPackKind);
begin
  if (FPackKind <> Value) and (Value <> TAssetPackKind.Unknown) then
    inherited;
end;

end.
