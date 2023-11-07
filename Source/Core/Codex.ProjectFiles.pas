unit Codex.ProjectFiles;

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
  System.JSON;

type
  TProjectFiles = record
  private
    procedure Load;
    procedure ReadProjectFileNames(const AValues: TJSONArray);
    function GetProjectFileNamesJSON: TJSONArray;
  public
    FileName: string;
    ProjectFileNames: TArray<string>;
    constructor Create(const AFileName: string);
    procedure AddFile(const AFileName: string);
    procedure RemoveFile(const AIndex: Integer);
    procedure Save;
  end;

implementation

uses
  System.IOUtils,
  DW.JSON;

{ TProjectFiles }

constructor TProjectFiles.Create(const AFileName: string);
begin
  FileName := AFileName;
  if TFile.Exists(FileName) then
    Load;
end;

function TProjectFiles.GetProjectFileNamesJSON: TJSONArray;
var
  LProjectFileName: string;
begin
  Result := TJSONArray.Create;
  for LProjectFileName in ProjectFileNames do
    Result.Add(LProjectFileName);
end;

procedure TProjectFiles.Load;
var
  LJSON: TJSONValue;
begin
  LJSON := TJSONObject.ParseJSONValue(TFile.ReadAllText(FileName));
  if LJSON <> nil then
  try
    if LJSON is TJSONArray then
      ReadProjectFileNames(TJSONArray(LJSON));
  finally
    LJSON.Free;
  end;
end;

procedure TProjectFiles.ReadProjectFileNames(const AValues: TJSONArray);
var
  LProjectFileName: TJSONValue;
begin
  for LProjectFileName in AValues do
    ProjectFileNames := ProjectFileNames + [LProjectFileName.Value];
end;

procedure TProjectFiles.AddFile(const AFileName: string);
begin
  ProjectFileNames := ProjectFileNames + [AFileName];
  Save;
end;

procedure TProjectFiles.RemoveFile(const AIndex: Integer);
begin
  if (AIndex >= Low(ProjectFileNames)) and (AIndex <= High(ProjectFileNames)) then
  begin
    Delete(ProjectFileNames, AIndex, 1);
    Save;
  end;
end;

procedure TProjectFiles.Save;
var
  LJSON: TJSONValue;
begin
  LJSON := GetProjectFileNamesJSON;
  try
    TFile.WriteAllText(FileName, TJSONHelper.Tidy(LJSON.ToJSON));
  finally
    LJSON.Free;
  end;
end;

end.
