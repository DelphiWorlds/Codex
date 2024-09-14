object DeployExtensionsView: TDeployExtensionsView
  Left = 0
  Top = 0
  Margins.Left = 4
  Margins.Top = 4
  Margins.Right = 4
  Margins.Bottom = 4
  Caption = 'Deploy Extensions'
  ClientHeight = 355
  ClientWidth = 722
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  OnResize = FormResize
  TextHeight = 15
  object CommandButtonsPanel: TPanel
    Left = 0
    Top = 319
    Width = 722
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object CancelButton: TButton
      AlignWithMargins = True
      Left = 645
      Top = 3
      Width = 74
      Height = 30
      Align = alRight
      Cancel = True
      Caption = 'Cancel'
      Default = True
      DoubleBuffered = True
      ModalResult = 2
      ParentDoubleBuffered = False
      TabOrder = 0
    end
    object OKButton: TButton
      AlignWithMargins = True
      Left = 565
      Top = 3
      Width = 74
      Height = 30
      Action = OKAction
      Align = alRight
      DoubleBuffered = True
      ParentDoubleBuffered = False
      TabOrder = 1
    end
  end
  object ExtensionsListView: TListView
    AlignWithMargins = True
    Left = 2
    Top = 5
    Width = 718
    Height = 307
    Margins.Left = 2
    Margins.Top = 5
    Margins.Right = 2
    Margins.Bottom = 7
    Align = alClient
    Columns = <
      item
        Caption = 'Project'
        Width = 229
      end
      item
        Caption = 'App Extension'
        Width = 350
      end
      item
        Caption = 'Date/Time'
        Width = 120
      end>
    MultiSelect = True
    ReadOnly = True
    RowSelect = True
    TabOrder = 1
    ViewStyle = vsReport
  end
  object ActionList: TActionList
    Left = 332
    Top = 59
    object OKAction: TAction
      Caption = 'OK'
      OnExecute = OKActionExecute
      OnUpdate = OKActionUpdate
    end
  end
end
