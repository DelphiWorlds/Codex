object ProjectFilesView: TProjectFilesView
  Left = 0
  Top = 0
  ClientHeight = 315
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poOwnerFormCenter
  TextHeight = 15
  object ProjectFilesPanel: TPanel
    AlignWithMargins = True
    Left = 4
    Top = 4
    Width = 616
    Height = 311
    Margins.Left = 4
    Margins.Top = 4
    Margins.Right = 4
    Margins.Bottom = 0
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 612
    ExplicitHeight = 310
    object FilesLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 610
      Height = 15
      Align = alTop
      Caption = 'Project Files:'
      ExplicitWidth = 66
    end
    object FilesButtonsPanel: TPanel
      Left = 0
      Top = 273
      Width = 616
      Height = 38
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitTop = 272
      ExplicitWidth = 612
      object RemoveFileButton: TButton
        AlignWithMargins = True
        Left = 101
        Top = 3
        Width = 92
        Height = 32
        Action = RemoveFilesAction
        Align = alLeft
        TabOrder = 1
      end
      object AddFileButton: TButton
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 92
        Height = 32
        Action = AddFilesAction
        Align = alLeft
        TabOrder = 0
      end
      object CloseButton: TButton
        AlignWithMargins = True
        Left = 521
        Top = 3
        Width = 92
        Height = 32
        Align = alRight
        Caption = '&Close'
        DoubleBuffered = True
        ModalResult = 8
        ParentDoubleBuffered = False
        TabOrder = 2
        ExplicitLeft = 517
      end
    end
    object FilesListBox: TListBox
      AlignWithMargins = True
      Left = 3
      Top = 24
      Width = 610
      Height = 246
      Align = alClient
      ItemHeight = 15
      MultiSelect = True
      TabOrder = 0
      ExplicitWidth = 606
      ExplicitHeight = 245
    end
  end
  object ActionList: TActionList
    Left = 59
    Top = 39
    object AddFilesAction: TAction
      Caption = 'Add..'
      Hint = 'Add files to the list'
      OnExecute = AddFilesActionExecute
    end
    object RemoveFilesAction: TAction
      Caption = 'Remove'
      Hint = 'Remove the selected files'
      OnExecute = RemoveFilesActionExecute
      OnUpdate = RemoveFilesActionUpdate
    end
  end
  object FilesOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoAllowMultiSelect]
    Title = 'Select files to add to project file list'
    Left = 152
    Top = 40
  end
end
