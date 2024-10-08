object PackageDownloadView: TPackageDownloadView
  Left = 0
  Top = 0
  Margins.Left = 8
  Margins.Top = 8
  Margins.Right = 8
  Margins.Bottom = 8
  Caption = 'Package Download/Extract'
  ClientHeight = 648
  ClientWidth = 915
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  ShowHint = True
  OnClose = FormClose
  OnResize = FormResize
  DesignSize = (
    915
    648)
  TextHeight = 13
  object EdgeBrowser: TEdgeBrowser
    Left = 0
    Top = 0
    Width = 929
    Height = 648
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 5
    AllowSingleSignOnUsingOSPrimaryAccount = False
    TargetCompatibleBrowserVersion = '117.0.2045.28'
    UserDataFolder = '%LOCALAPPDATA%\bds.exe.WebView2'
    OnExecuteScript = EdgeBrowserExecuteScript
    OnNavigationCompleted = EdgeBrowserNavigationCompleted
  end
  object ExtractButtonsPanel: TPanel
    Left = 0
    Top = 609
    Width = 915
    Height = 39
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object MessageLabel: TLabel
      AlignWithMargins = True
      Left = 293
      Top = 0
      Width = 453
      Height = 39
      Margins.Left = 4
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 173
      ExplicitWidth = 576
    end
    object ExtractAARButton: TButton
      AlignWithMargins = True
      Left = 749
      Top = 3
      Width = 82
      Height = 33
      Action = ExtractAction
      Align = alRight
      TabOrder = 0
    end
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 837
      Top = 3
      Width = 75
      Height = 33
      Align = alRight
      Caption = '&Close'
      DoubleBuffered = True
      ModalResult = 8
      ParentDoubleBuffered = False
      TabOrder = 1
      OnClick = CloseButtonClick
    end
    object RetainWorkingFilesCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 169
      Top = 0
      Width = 120
      Height = 39
      Hint = 'Retains the files generated, for diagnostic purposes'
      Margins.Left = 4
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'Retain working files'
      TabOrder = 2
    end
    object RetainAarFilesCheckBox: TCheckBox
      AlignWithMargins = True
      Left = 4
      Top = 0
      Width = 161
      Height = 39
      Hint = 'Retains .aar files that contain resources'
      Margins.Left = 4
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alLeft
      Caption = 'Retain resource .aar files '
      Checked = True
      State = cbChecked
      TabOrder = 3
    end
  end
  object ExtractPathPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 555
    Width = 915
    Height = 50
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 4
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object SelectExtractPathButton: TSpeedButton
      AlignWithMargins = True
      Left = 888
      Top = 22
      Width = 23
      Height = 25
      Margins.Left = 0
      Margins.Right = 4
      Align = alRight
      Caption = '...'
      OnClick = SelectExtractPathActionExecute
      ExplicitLeft = 892
      ExplicitTop = 24
      ExplicitHeight = 23
    end
    object ExtractPathLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 909
      Height = 13
      Align = alTop
      Caption = 'Extract Root Path:'
      ExplicitWidth = 90
    end
    object ExtractPathEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 23
      Width = 884
      Height = 23
      Hint = 'Path to extract the jars and resources to'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 21
    end
  end
  object GradlePathPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 8
    Width = 915
    Height = 50
    Margins.Left = 0
    Margins.Top = 8
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 2
    object SelectGradlePathButton: TSpeedButton
      AlignWithMargins = True
      Left = 888
      Top = 22
      Width = 23
      Height = 24
      Margins.Left = 0
      Margins.Right = 4
      Align = alRight
      Caption = '...'
      OnClick = SelectGradlePathButtonClick
      ExplicitLeft = 892
      ExplicitTop = 24
      ExplicitHeight = 21
    end
    object GradlePathLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 909
      Height = 13
      Align = alTop
      Caption = 'Gradle (gradle.bat) location: (selection will be remembered)'
      ExplicitWidth = 284
    end
    object GradlePathEdit: TEdit
      AlignWithMargins = True
      Left = 4
      Top = 23
      Width = 884
      Height = 22
      Hint = 
        'Location of gradle.bat file in your Gradle install. Obtain Gradl' +
        'e from here: https://gradle.org/releases/'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 0
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      ExplicitHeight = 21
    end
  end
  object PackagesPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 420
    Width = 915
    Height = 131
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 4
    Align = alBottom
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 3
    object PackagesLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 909
      Height = 13
      Align = alTop
      Caption = 
        'Packages: Each package on a new line, using Gradle short format ' +
        'e.g: androidx.biometric:biometric:1.1.0'
      ExplicitWidth = 505
    end
    object PackagesMemo: TMemo
      AlignWithMargins = True
      Left = 4
      Top = 23
      Width = 907
      Height = 103
      Hint = 'Packages to download'
      Margins.Left = 4
      Margins.Top = 4
      Margins.Right = 4
      Margins.Bottom = 4
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  object PackageSearchPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 62
    Width = 915
    Height = 354
    Margins.Left = 0
    Margins.Top = 4
    Margins.Right = 0
    Margins.Bottom = 4
    Align = alClient
    BevelOuter = bvNone
    Padding.Bottom = 1
    TabOrder = 4
    object SearchPackagesLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 909
      Height = 13
      Align = alTop
      Caption = 'Search Packages:'
      ExplicitWidth = 85
    end
    object URLLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 58
      Width = 909
      Height = 13
      Align = alTop
      Caption = 'URL:'
      ExplicitWidth = 23
    end
    object PackageSearchEditPanel: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 19
      Width = 915
      Height = 36
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      BevelOuter = bvNone
      Padding.Bottom = 1
      TabOrder = 0
      object SearchEdit: TEdit
        AlignWithMargins = True
        Left = 4
        Top = 3
        Width = 809
        Height = 25
        Margins.Left = 4
        Margins.Right = 0
        Margins.Bottom = 7
        Align = alClient
        TabOrder = 0
        OnKeyPress = SearchEditKeyPress
        ExplicitHeight = 21
      end
      object PackageSearchButton: TButton
        AlignWithMargins = True
        Left = 821
        Top = 0
        Width = 90
        Height = 31
        Margins.Left = 8
        Margins.Top = 0
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alRight
        Caption = 'Search'
        TabOrder = 1
        OnClick = PackageSearchButtonClick
      end
    end
    object PackageSearchResultsPanel: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 110
      Width = 915
      Height = 243
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Padding.Bottom = 1
      TabOrder = 1
      object PackagesListView: TListView
        AlignWithMargins = True
        Left = 4
        Top = 0
        Width = 557
        Height = 242
        Margins.Left = 4
        Margins.Top = 0
        Margins.Right = 4
        Margins.Bottom = 0
        Align = alClient
        Columns = <
          item
            Caption = 'Title'
            Width = 200
          end
          item
            Caption = 'Package'
            Width = 350
          end>
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = PackagesListViewSelectItem
      end
      object ReleasesPanel: TPanel
        Left = 565
        Top = 0
        Width = 350
        Height = 242
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object ReleasesListView: TListView
          AlignWithMargins = True
          Left = 0
          Top = 0
          Width = 350
          Height = 197
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alClient
          Columns = <
            item
              Caption = 'Name'
              Width = 200
            end
            item
              Caption = 'Version'
              Width = 125
            end>
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
          OnDblClick = ReleasesListViewDblClick
        end
        object AddPackageButton: TButton
          AlignWithMargins = True
          Left = 0
          Top = 201
          Width = 350
          Height = 37
          Margins.Left = 0
          Margins.Top = 4
          Margins.Right = 0
          Margins.Bottom = 4
          Action = AddPackageAction
          Align = alBottom
          TabOrder = 1
        end
      end
    end
    object Panel1: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 74
      Width = 915
      Height = 36
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      BevelOuter = bvNone
      Padding.Bottom = 1
      TabOrder = 2
      object URLEdit: TEdit
        AlignWithMargins = True
        Left = 4
        Top = 3
        Width = 809
        Height = 25
        Margins.Left = 4
        Margins.Right = 0
        Margins.Bottom = 7
        Align = alClient
        TabOrder = 0
        OnKeyPress = URLEditKeyPress
        ExplicitHeight = 21
      end
      object URLGetButton: TButton
        AlignWithMargins = True
        Left = 821
        Top = 0
        Width = 90
        Height = 31
        Margins.Left = 8
        Margins.Top = 0
        Margins.Right = 4
        Margins.Bottom = 4
        Align = alRight
        Caption = 'Get'
        TabOrder = 1
        OnClick = URLGetButtonClick
      end
    end
  end
  object GradleOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'Gradle'
        FileMask = 'gradle.bat'
      end>
    Options = [fdoFileMustExist]
    Title = 'Select location of Gradle'
    Left = 658
    Top = 716
  end
  object ExtractPathOpenDialog: TFileOpenDialog
    FavoriteLinks = <>
    FileTypes = <>
    Options = [fdoPickFolders, fdoPathMustExist]
    Title = 'Select path to extract packages to'
    Left = 886
    Top = 716
  end
  object ActionList: TActionList
    Left = 474
    Top = 712
    object ExtractAction: TAction
      Caption = 'Extract'
      OnExecute = ExtractActionExecute
      OnUpdate = ExtractActionUpdate
    end
    object AddPackageAction: TAction
      Caption = 'Add To List'
      OnExecute = AddPackageActionExecute
      OnUpdate = AddPackageActionUpdate
    end
  end
  object SearchTimer: TTimer
    Enabled = False
    Interval = 30000
    OnTimer = SearchTimerTimer
    Left = 1108
    Top = 712
  end
end
