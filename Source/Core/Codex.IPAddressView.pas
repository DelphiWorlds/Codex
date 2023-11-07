unit Codex.IPAddressView;

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
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TIPAddressView = class(TFrame)
    ColonLabel: TLabel;
    IPEditPanel: TPanel;
    Byte2PeriodLabel: TLabel;
    Byte1PeriodLabel: TLabel;
    Byte3PeriodLabel: TLabel;
    IPByte2Edit: TEdit;
    IPByte1Edit: TEdit;
    IPByte3Edit: TEdit;
    IPByte4Edit: TEdit;
    IPPortEdit: TEdit;
    procedure IPByteEditChange(Sender: TObject);
    procedure IPByteEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure IPByteEditKeyPress(Sender: TObject; var Key: Char);
  private
    FIsValid: Boolean;
    FOnChanged: TNotifyEvent;
    FOnExecute: TNotifyEvent;
    procedure CheckIPAddress;
    procedure DoChanged;
    procedure DoExecute;
    function GetIPAddress: string;
    function GetPort: string;
    procedure SetIPAddress(const AIP: string);
    procedure SetPort(const Value: string);
  public
    property IP: string read GetIPAddress write SetIPAddress;
    property Port: string read GetPort write SetPort;
    property IsValid: Boolean read FIsValid;
    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
  end;

implementation

{$R *.dfm}

uses
  System.Character;

procedure TIPAddressView.IPByteEditKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if (Chr(Key).IsDigit and (Length(TEdit(Sender).Text) = 3)) then
    SelectNext(TWinControl(Sender), True, True)
  else if Key = VK_RETURN then
    DoExecute;
end;

procedure TIPAddressView.IPByteEditKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = '.') and (Length(TEdit(Sender).Text) > 0) then
    SelectNext(TWinControl(Sender), True, True);
  if not (CharInSet(Key, [#9, #13, #8]) or Key.IsDigit) then
    Key := #0;
end;

procedure TIPAddressView.IPByteEditChange(Sender: TObject);
begin
  CheckIPAddress;
end;

procedure TIPAddressView.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TIPAddressView.DoExecute;
begin
  if Assigned(FOnExecute) then
    FOnExecute(Self);
end;

function TIPAddressView.GetIPAddress: string;
begin
  Result := IPByte1Edit.Text + '.' + IPByte2Edit.Text + '.' + IPByte3Edit.Text + '.' + IPByte4Edit.Text;
end;

function TIPAddressView.GetPort: string;
begin
  Result := IPPortEdit.Text;
end;

procedure TIPAddressView.SetIPAddress(const AIP: string);
var
  LParts: TArray<string>;
begin
  IPByte1Edit.Text := '';
  IPByte2Edit.Text := '';
  IPByte3Edit.Text := '';
  IPByte4Edit.Text := '';
  LParts := AIP.Split(['.'], 4);
  if Length(LParts) = 4 then
  begin
    IPByte1Edit.Text := LParts[0];
    IPByte2Edit.Text := LParts[1];
    IPByte3Edit.Text := LParts[2];
    IPByte4Edit.Text := LParts[3];
  end;
end;

procedure TIPAddressView.SetPort(const Value: string);
begin
  IPPortEdit.Text := Value;
end;

procedure TIPAddressView.CheckIPAddress;
var
  LParts: TArray<string>;
  I, LValue: Integer;
begin
  FIsValid := False;
  LParts := GetIPAddress.Split(['.'], 4);
  if Length(LParts) = 4 then
  begin
    FIsValid := True;
    for I := 0 to 3 do
    begin
      if not TryStrToInt(LParts[I], LValue) or (LValue > 255) then
      begin
        FIsValid := False;
        Break;
      end;
    end;
  end;
  FIsValid := FIsValid and (StrToIntDef(IPPortEdit.Text, 0) > 0);
  DoChanged;
end;

end.
