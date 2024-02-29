unit Codex.Android.BuildRJarProcess;

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
  System.Classes,
  DW.RunProcess.Win;

type
  TBuildStage = (None, CompileResources, LinkResources, CompileJava, BuildJar);

  TBuildRJarCompleteEvent = procedure(Sender: TObject; const Success: Boolean) of object;

  TBuildRJarProcess = class(TRunProcess)
  private
    FAPILevelPath: string;
    FBuildStage: TBuildStage;
    FBuildToolsPath: string;
    FIsDebugConfig: Boolean;
    FJDKPath: string;
    FMergedResPath: string;
    FNeedsWorkingFiles: Boolean;
    FPackages: TArray<string>;
    FProjectName: string;
    FProjectOutputPath: string;
    FProjectPath: string;
    FRFolders: TArray<string>;
    FRIndex: Integer;
    FRJarPath: string;
    FWorkingPath: string;
    FOnComplete: TBuildRJarCompleteEvent;
    procedure BuildJar;
    procedure Cleanup;
    function CompileResources: Boolean;
    procedure CompileJavaSource;
    procedure DoComplete(const ASuccess: Boolean);
    procedure DoSyncOutput(const AOutput: string);
    procedure ExecuteBuild;
    procedure GenerateRJava;
    procedure GenerateSource;
    function GetRJarFileName: string;
    procedure LinkResources;
    procedure MergeResources;
    procedure OutputExecuting;
    procedure ProcessComplete(const AMsg: string; const ASuccess: Boolean);
  protected
    procedure DoTerminated(const AExitCode: Cardinal); override;
  public
    procedure Build;
    property APILevelPath: string read FAPILevelPath write FAPILevelPath;
    property BuildToolsPath: string read FBuildToolsPath write FBuildToolsPath;
    property IsDebugConfig: Boolean read FIsDebugConfig write FIsDebugConfig;
    property JDKPath: string read FJDKPath write FJDKPath;
    property MergedResPath: string read FMergedResPath write FMergedResPath;
    property NeedsWorkingFiles: Boolean read FNeedsWorkingFiles write FNeedsWorkingFiles;
    property Packages: TArray<string> read FPackages write FPackages;
    property ProjectName: string read FProjectName write FProjectName;
    property ProjectOutputPath: string read FProjectOutputPath write FProjectOutputPath;
    property ProjectPath: string read FProjectPath write FProjectPath;
    property RJarFileName: string read GetRJarFileName;
    property RJarPath: string read FRJarPath write FRJarPath;
    property OnComplete: TBuildRJarCompleteEvent read FOnComplete write FOnComplete;
  end;

implementation

uses
  System.IOUtils, System.SysUtils,
  Winapi.ActiveX,
  Xml.XMLIntf, Xml.XMLDoc,
  DW.OSLog, DW.ResourcesMerger, DW.IOUtils.Helpers, DW.ManifestMerger,
  Codex.Core, Codex.Consts.Text;

const
  cAAPTPackageCommand = '"%s" package -f -m -I "%s\android.jar" -M "%s\AndroidManifest.xml" -S "%s" -J "%s\src"';
  cAAPT2CompileCommand = '"%s" compile --dir "%s" -o "%s\compiled_res.flata"';
  cAAPT2LinkCommand = '"%s" link --proto-format -o "%s\linked_res.ap_" -I "%s\android.jar" --manifest "%s\AndroidManifest.xml" ' +
    '-R "%s\compiled_res.flata" --auto-add-overlay --java "%s\src';
  cCompileJavaCommand = '"%s\javac" -d "%s\obj" -classpath "%s;%s\obj" @"%s\javasources.txt"';
  cBuildJarCommand = '"%s\jar" cf "%s" -C "%s\obj" .';

  cManifestFilename = 'AndroidManifest.xml';
  cApplicationNodeName = 'application';
  cPackageAttributeName = 'package';

function FindMatchingNode(const ATargetParentNode, ASourceNode: IXMLNode; out AMatchingNode: IXMLNode): Boolean;
var
  I: Integer;
  LChildNode: IXMLNode;
  LSourceName, LTargetName: string;
begin
  Result := False;
  if ASourceNode.HasAttribute('android:name') then
  begin
    LSourceName := ASourceNode.Attributes['android:name'];
    for I := 0 to ATargetParentNode.ChildNodes.Count - 1 do
    begin
      LChildNode := ATargetParentNode.ChildNodes[I];
      if LChildNode.NodeName.Equals(ASourceNode.NodeName) and LChildNode.HasAttribute('android:name') then
      begin
        LTargetName := LChildNode.Attributes['android:name'];
        if LTargetName.Equals(LSourceName) then
        begin
          AMatchingNode := LChildNode;
          Result := True;
          Break;
        end;
      end;
    end;
  end;
end;

procedure ModifyAttributes(const ANode: IXMLNode);
var
  I: Integer;
  LValue: string;
  LAttributeNode: IXMLNode;
begin
  for I := ANode.AttributeNodes.Count - 1 downto 0 do
  begin
    LAttributeNode := ANode.AttributeNodes[I];
    if LAttributeNode.NodeName.StartsWith('tools:', True) then
      ANode.AttributeNodes.Delete(I)
    else
    begin
      LValue := ANode.Attributes[LAttributeNode.NodeName];
      if LValue.Contains('${applicationId}') then
        ANode.Attributes[LAttributeNode.NodeName] := LValue.Replace('${applicationId}', '%package%');
    end;
  end;
end;

procedure FormatManifest(const AFileName: string);
var
  LLine, LTextLine, LLineTrimmed: string;
  LParts, LFormatted: TArray<string>;
  I, LIndent, LIndex: Integer;
begin
  for LTextLine in TFile.ReadAllLines(AFileName) do
  begin
    LLine := LTextLine.Replace(#9, '  ', [rfReplaceAll]);
    LLineTrimmed := LLine.Trim;
    LIndent := Length(LLine) - Length(LLineTrimmed);
    // Fix an apparent bug with saving XML
    LIndex := LLine.IndexOf('><');
    if LLineTrimmed.StartsWith('<manifest') and (LIndex > -1) then
    begin
      LFormatted := LFormatted + [LLine.Substring(0, LIndex + 1)];
      LLine := StringOfChar(' ', LIndent + 2) + LLine.Substring(LIndex + 1);
    end;
    if LLineTrimmed.StartsWith('<service ') or LLineTrimmed.StartsWith('<provider ') or LLineTrimmed.StartsWith('<receiver ') then
    begin
      LParts := LLineTrimmed.Split([' '], '"');
      LFormatted := LFormatted + [LLine.Substring(0, LIndent) + LParts[0]];
      for I := 1 to High(LParts) do
        LFormatted := LFormatted + [StringOfChar(' ', LIndent + 2) + LParts[I]];
    end
    else
      LFormatted := LFormatted + [LLine];
  end;
  TFile.WriteAllLines(AFileName, LFormatted);
end;

function IsMerge(const ANode: IXMLNode): Boolean;
var
  LValue: string;
begin
  Result := False;
  if ANode.HasAttribute('tools:node') then
  begin
    LValue := ANode.Attributes['tools:node'];
    Result := LValue.Equals('merge');
  end;
end;

procedure MergeNodes(const ATargetNode, ASourceNode: IXMLNode);
var
  I: Integer;
  LAttributeNode, LCloneNode, LChildNode, LMatchingNode: IXMLNode;
begin
  for I := 0 to ASourceNode.AttributeNodes.Count - 1 do
  begin
    LAttributeNode := ASourceNode.AttributeNodes[I];
    if not ATargetNode.HasAttribute(LAttributeNode.NodeName, LAttributeNode.NamespaceURI) then
    begin
      LCloneNode := LAttributeNode.CloneNode(True);
      ATargetNode.AttributeNodes.Add(LCloneNode);
    end;
  end;
  for I := 0 to ASourceNode.ChildNodes.Count - 1 do
  begin
    LChildNode := ASourceNode.ChildNodes[I];
    if not FindMatchingNode(ATargetNode, LChildNode, LMatchingNode) then
    begin
      LCloneNode := LChildNode.CloneNode(True);
      ATargetNode.ChildNodes.Add(LCloneNode);
    end;
  end;
end;

procedure AddNode(const ATargetParentNode, ASourceNode: IXMLNode; const AInsert: Boolean);
var
  LCloneNode, LTargetNode: IXMLNode;
begin
  LTargetNode := nil;
  LCloneNode := ASourceNode.CloneNode(True);
  ModifyAttributes(LCloneNode);
  FindMatchingNode(ATargetParentNode, ASourceNode, LTargetNode);
  if IsMerge(ASourceNode) and (LTargetNode <> nil) then
    MergeNodes(LTargetNode, LCloneNode)
  else if LTargetNode = nil then
  begin
    if AInsert then
      ATargetParentNode.ChildNodes.Insert(0, LCloneNode)
    else
      ATargetParentNode.ChildNodes.Add(LCloneNode);
  end;
end;

procedure MergeManifest(const ATargetManifest, ASourceManifest: IXMLNode; const AInsert: Boolean);
var
  I: Integer;
  LSourceNode, LApplicationNode: IXMLNode;
begin
  for I := 0 to ASourceManifest.ChildNodes.Count - 1 do
  begin
    LSourceNode := ASourceManifest.ChildNodes[I];
    if LSourceNode.NodeName.Equals(cApplicationNodeName) then
    begin
      LApplicationNode := ATargetManifest.ChildNodes.FindNode(cApplicationNodeName);
      if LApplicationNode = nil then
        LApplicationNode := ATargetManifest.AddChild(cApplicationNodeName);
      MergeManifest(LApplicationNode, LSourceNode, False);
    end
    else if not LSourceNode.NodeName.Equals('uses-sdk') and (LSourceNode.NodeType <> TNodeType.ntComment) then
      AddNode(ATargetManifest, LSourceNode, AInsert);
  end;
end;

procedure MergeManifests(const APackagePaths: TArray<string>; const AMergedFileName: string);
var
  LMergedXmlDoc: IXMLDocument;
  LDocNode, LNode: IXMLNode;
  LPackagePath, LManifestFileName: string;
begin
  if not TFile.Exists(AMergedFileName) then
  begin
    LMergedXmlDoc := NewXMLDocument;
    LMergedXmlDoc.AddChild('manifest');
  end
  else
    LMergedXmlDoc := LoadXMLDocument(AMergedFileName);
  LMergedXmlDoc.Options := LMergedXmlDoc.Options + [doNodeAutoIndent];
  LDocNode := LMergedXmlDoc.DocumentElement;
  LDocNode.DeclareNamespace('android', 'http://schemas.android.com/apk/res/android');
  for LPackagePath in APackagePaths do
  begin
    LManifestFileName := TPath.Combine(LPackagePath, cManifestFilename);
    if TFile.Exists(LManifestFileName) then
      MergeManifest(LMergedXmlDoc.DocumentElement, LoadXMLDocument(LManifestFileName).DocumentElement, True);
  end;
  if LMergedXmlDoc.Modified then
  begin
    // Remove the application node, if empty - really more for aesthetics
    LNode := LDocNode.ChildNodes.FindNode('application');
    if (LNode <> nil) and (LNode.ChildNodes.Count = 0) then
      LDocNode.ChildNodes.Remove(LNode);
    LMergedXmlDoc.SaveToFile(AMergedFileName);
    FormatManifest(AMergedFileName);
  end;
end;

{ TBuildRJarProcess }

procedure TBuildRJarProcess.Cleanup;
begin
  if not FNeedsWorkingFiles then
    TDirectoryHelper.Delete(FWorkingPath);
end;

procedure TBuildRJarProcess.DoComplete(const ASuccess: Boolean);
begin
  if Assigned(FOnComplete) then
    FOnComplete(Self, ASuccess);
end;

procedure TBuildRJarProcess.DoSyncOutput(const AOutput: string);
begin
  TThread.Synchronize(nil, procedure begin DoOutput(AOutput); end);
end;

procedure TBuildRJarProcess.DoTerminated(const AExitCode: Cardinal);
begin
  if AExitCode = 0 then
  begin
    case FBuildStage of
      TBuildStage.BuildJar:
        ProcessComplete(Format(Babel.Tx(sCompletedBuildingJar), [GetRJarFileName]), True);
      TBuildStage.CompileJava:
        BuildJar;
      TBuildStage.CompileResources:
        LinkResources;
      TBuildStage.LinkResources:
      begin
        Inc(FRIndex);
        if FRIndex = Length(FRFolders) then
          CompileJavaSource
        else
          GenerateRJava;
      end;
    end;
  end
  else
    ProcessComplete(Format(Babel.Tx(sExitCode), [AExitCode]), False);
end;

procedure TBuildRJarProcess.Build;
begin
  FWorkingPath := TPath.Combine(TPath.GetTempPath, TGUID.NewGuid.ToString.Trim(['{', '}']));
  ForceDirectories(FWorkingPath);
  TThread.CreateAnonymousThread(ExecuteBuild).Start;
end;

procedure TBuildRJarProcess.ExecuteBuild;
var
  LIsInitialized: Boolean;
begin
  LIsInitialized := Succeeded(CoInitialize(nil));
  try
    try
      MergeResources;
    except
      on E: Exception do
        TOSLog.d('> %s: %s', [E.ClassName, E.Message]);
    end;
  finally
    if LIsInitialized then
      CoUninitialize;
  end;
  TThread.Synchronize(nil, GenerateSource);
end;

procedure TBuildRJarProcess.MergeResources;
var
  LPackage, LResPath, LDependency, LDependencyName, LPath, LManifestFileName, LMergeFileName: string;
  LDependencies: TArray<string>;
begin
  if TDirectory.Exists(FMergedResPath) then
    TDirectoryHelper.Delete(FMergedResPath);
  ForceDirectories(FMergedResPath);
  for LPackage in FPackages do
  begin
    // e.g. Package of:  Z:\Lib\Android\androidx-biometric-1.1.0
    LDependencies := TDirectory.GetDirectories(LPackage, '*.*', TSearchOption.soTopDirectoryOnly);
    for LDependency in LDependencies do
    begin
      // Call MergeResources only for folders that have a res subfolder
      LResPath := TPath.Combine(LDependency, 'res');
      LDependencyName := TPath.GetFileName(LDependency);
      LManifestFileName := TPath.Combine(LDependency, 'AndroidManifest.xml');
      if TDirectory.Exists(LResPath) then
      begin
        DoSyncOutput(Format(Babel.Tx(sMergingResources), [LDependencyName]));
        TResourcesMerger.MergeResources(LResPath, FMergedResPath, FMergedResPath); // This returns a result, so perhaps check for failure
        LPath := TPath.Combine(FWorkingPath, LDependencyName);
        // e.g. appcompat-1.2.0\src
        ForceDirectories(TPath.Combine(LPath, 'src'));
        // Copy the manifest to make it easier to generate R.java
        TFile.Copy(LManifestFileName, TPath.Combine(LPath, 'AndroidManifest.xml'));
      end;
    end;
    LMergeFileName := TPath.Combine(FProjectPath, TPath.GetFileName(LPackage) + '-Manifest.merge.xml');
    MergeManifests(LDependencies, LMergeFileName);
  end;
end;

procedure TBuildRJarProcess.OutputExecuting;
begin
  DoOutput(Format(Babel.Tx(sExecutingCommand), [CommandLine]));
end;

procedure TBuildRJarProcess.GenerateSource;
begin
  FRFolders := TDirectory.GetDirectories(FWorkingPath, '*.*', TSearchOption.soTopDirectoryOnly);
  if Length(FRFolders) > 0 then
  begin
    FRIndex := 0;
    GenerateRJava;
  end;
  // else no R's to generate
end;

function TBuildRJarProcess.GetRJarFileName: string;
begin
  Result := TPath.Combine(FRJarPath, Format('%s.R.jar', [FProjectName]));
end;

procedure TBuildRJarProcess.GenerateRJava;
begin
  if not CompileResources then
    ProcessComplete('Failed to generate R.java for', False); // TODO: Indicate which
end;

function TBuildRJarProcess.CompileResources: Boolean;
var
  LEXEPath, LRPath: string;
begin
  LRPath := FRFolders[FRIndex];
  if FIsDebugConfig then
  begin
    FBuildStage := TBuildStage.LinkResources; // because it is all done in one step
    LEXEPath := TPath.Combine(FBuildToolsPath, 'aapt.exe');
    CommandLine := Format(cAAPTPackageCommand, [LEXEPath, FAPILevelPath, LRPath, FMergedResPath, LRPath]);
  end
  else
  begin
    FBuildStage := TBuildStage.CompileResources;
    LEXEPath := TPath.Combine(FBuildToolsPath, 'aapt2.exe');
    CommandLine := Format(cAAPT2CompileCommand, [LEXEPath, FMergedResPath, FWorkingPath]);
  end;
  OutputExecuting;
  Result := Run;
end;

procedure TBuildRJarProcess.LinkResources;
var
  LEXEPath, LRPath: string;
begin
  LRPath := FRFolders[FRIndex];
  FBuildStage := TBuildStage.LinkResources;
  LEXEPath := TPath.Combine(FBuildToolsPath, 'aapt2.exe');
  CommandLine := Format(cAAPT2LinkCommand, [LEXEPath, FWorkingPath, FAPILevelPath, LRPath, FWorkingPath, LRPath]);
  OutputExecuting;
  Run;
end;

procedure TBuildRJarProcess.CompileJavaSource;
var
  LSourceFiles: TArray<string>;
  LJavaSourcesFileName: string;
begin
  LSourceFiles := TDirectory.GetFiles(FWorkingPath, 'R.java', TSearchOption.soAllDirectories);
  if Length(LSourceFiles) > 0 then
  begin
    LJavaSourcesFileName := TPath.Combine(FWorkingPath, 'javasources.txt');
    TFile.WriteAllLines(LJavaSourcesFileName, LSourceFiles);
    FBuildStage := TBuildStage.CompileJava;
    CommandLine := Format(cCompileJavaCommand, [FJDKPath, FWorkingPath, FAPILevelPath, FWorkingPath, FWorkingPath]);
    OutputExecuting;
    Run;
  end
  else
    ProcessComplete(Babel.Tx(sNoJavaSources), False);
end;

procedure TBuildRJarProcess.BuildJar;
begin
  FBuildStage := TBuildStage.BuildJar;
  ForceDirectories(FRJarPath);
  CommandLine := Format(cBuildJarCommand, [FJDKPath, GetRJarFileName, FWorkingPath]);
  OutputExecuting;
  Run;
end;

procedure TBuildRJarProcess.ProcessComplete(const AMsg: string; const ASuccess: Boolean);
begin
  DoOutput(AMsg);
  Cleanup;
  if FNeedsWorkingFiles then
    DoOutput(Format(Babel.Tx(sWorkingFilesRetained), [FWorkingPath]));
  DoComplete(ASuccess);
end;

end.
