unit DW.Vcl.ExtendedListBox;

interface

uses
  System.Classes,
  Vcl.StdCtrls;

type
  TListBox = class(Vcl.StdCtrls.TListBox)
  private
    procedure CopySelectedToClipboard;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    procedure CopyToClipboard(const AAll: Boolean = True);
    function HasSelections: Boolean;
    function SelectedCount: Integer;
    function SelectedItem: string;
    function SelectItem(const AItem: string): Integer;
    function SelectLastItem: Boolean;
  end;

implementation

uses
  Vcl.Clipbrd;

{ TListBox }

procedure TListBox.CopySelectedToClipboard;
var
  I: Integer;
  LItems: TStrings;
begin
  LItems := TStringList.Create;
  try
    for I := 0 to Count - 1 do
    begin
      if Selected[I] then
        LItems.Add(Items[I]);
    end;
    Clipboard.AsText := LItems.Text;
  finally
    LItems.Free;
  end;
end;

procedure TListBox.CopyToClipboard(const AAll: Boolean = True);
begin
  if AAll then
    Clipboard.AsText := Items.Text
  else
    CopySelectedToClipboard;
end;

function TListBox.HasSelections: Boolean;
begin
  Result := SelectedCount > 0;
end;

procedure TListBox.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (ssCtrl in Shift) and (Key = Ord('C')) then
    CopyToClipboard(not (ssShift in Shift));
end;

function TListBox.SelectedCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    if Selected[I] then
      Inc(Result);
  end;
end;

function TListBox.SelectedItem: string;
begin
  Result := '';
  if ItemIndex > -1 then
    Result := Items[ItemIndex];
end;

function TListBox.SelectItem(const AItem: string): Integer;
begin
  Result := Items.IndexOf(AItem);
  if Result > -1 then
    ItemIndex := Result;
end;

function TListBox.SelectLastItem: Boolean;
begin
  if ItemIndex = -1 then
    ItemIndex := Count - 1;
  Result := ItemIndex > -1;
end;


end.
