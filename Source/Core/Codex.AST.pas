unit Codex.AST;

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
  ToolsAPI,
  DelphiAST, DelphiAST.Classes;

type
  TCodexAST = class(TPasSyntaxTreeBuilder)
  private
    function RunNoMessages(const ASource: TStream): TSyntaxNode;
  public
    class function RunSourceEditor(const AEditor: IOTASourceEditor): TSyntaxNode;
  end;

implementation

uses
  DelphiAST.Consts;

{ TCodexAST }

class function TCodexAST.RunSourceEditor(const AEditor: IOTASourceEditor): TSyntaxNode;
const
  cBufferSize = 1024;
var
  LBuilder: TCodexAST;
  LReader: IOTAEditReader;
  LBuffer: AnsiString;
  LPosition, LCharsRead: Integer;
  LWriter: TStringStream;
begin
  LReader := AEditor.CreateReader;
  LWriter := TStringStream.Create;
  try
    LPosition := 0;
    repeat
      SetLength(LBuffer, cBufferSize);
      LCharsRead := LReader.GetText(LPosition, PAnsiChar(LBuffer), cBufferSize);
      SetLength(LBuffer, LCharsRead);
      LWriter.WriteString(string(LBuffer));
      Inc(LPosition, LCharsRead);
    until LCharsRead < cBufferSize;
    LBuilder := TCodexAST.Create;
    try
      LBuilder.InitDefinesDefinedByCompiler;
      Result := LBuilder.RunNoMessages(LWriter);
    finally
      LBuilder.Free;
    end;
  finally
    LWriter.Free;
  end;
end;

function TCodexAST.RunNoMessages(const ASource: TStream): TSyntaxNode;
begin
  Result := TSyntaxNode.Create(ntUnit);
  FStack.Clear;
  FStack.Push(Result);
  try
    inherited Run('', ASource);
  finally
    FStack.Pop;
  end;
end;

end.
