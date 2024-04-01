object PackageDownloadView: TPackageDownloadView
  Left = 0
  Top = 0
  Margins.Left = 12
  Margins.Top = 12
  Margins.Right = 12
  Margins.Bottom = 12
  Caption = 'Package Download/Extract'
  ClientHeight = 972
  ClientWidth = 1379
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -17
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  ShowHint = True
  OnClose = FormClose
  PixelsPerInch = 144
  DesignSize = (
    1379
    972)
  TextHeight = 21
  object EdgeBrowser: TEdgeBrowser
    Left = 0
    Top = 0
    Width = 1394
    Height = 972
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
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
    Top = 914
    Width = 1379
    Height = 58
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object MessageLabel: TLabel
      AlignWithMargins = True
      Left = 260
      Top = 0
      Width = 864
      Height = 58
      Margins.Left = 6
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      AutoSize = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clRed
      Font.Height = -17
      Font.Name = 'Tahoma'
      Font.Style = [fsBold]
      ParentFont = False
      Layout = tlCenter
      ExplicitWidth = 856
      ExplicitHeight = 59
    end
    object ExtractAARButton: TButton
      AlignWithMargins = True
      Left = 1129
      Top = 5
      Width = 123
      Height = 48
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Action = ExtractAction
      Align = alRight
      TabOrder = 0
    end
    object CloseButton: TButton
      AlignWithMargins = True
      Left = 1262
      Top = 5
      Width = 112
      Height = 48
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alRight
      Caption = '&Close'
      DoubleBuffered = True
      ModalResult = 8
      ParentDoubleBuffered = False
      TabOrder = 1
      OnClick = CloseButtonClick
    end
    object RetainCheckBox: TCheckBox
      Left = 0
      Top = 0
      Width = 254
      Height = 58
      Hint = 'Retains the files generated, for diagnostic purposes'
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alLeft
      Caption = 'Retain working files'
      TabOrder = 2
    end
  end
  object ExtractPathPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 833
    Width = 1379
    Height = 75
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 6
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object SelectExtractPathButton: TSpeedButton
      AlignWithMargins = True
      Left = 1338
      Top = 36
      Width = 35
      Height = 34
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 6
      Margins.Bottom = 5
      Align = alRight
      Caption = '...'
      OnClick = SelectExtractPathActionExecute
      ExplicitLeft = 1329
      ExplicitTop = 33
      ExplicitHeight = 38
    end
    object ExtractPathLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 1369
      Height = 21
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Extract Root Path:'
      ExplicitWidth = 137
    end
    object ExtractPathEdit: TEdit
      AlignWithMargins = True
      Left = 6
      Top = 37
      Width = 1332
      Height = 32
      Hint = 'Path to extract the jars and resources to'
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 0
      Margins.Bottom = 6
      Align = alClient
      TabOrder = 0
      ExplicitHeight = 29
    end
  end
  object GradlePathPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 12
    Width = 1379
    Height = 75
    Margins.Left = 0
    Margins.Top = 12
    Margins.Right = 0
    Margins.Bottom = 0
    Align = alTop
    BevelOuter = bvNone
    Padding.Bottom = 2
    TabOrder = 2
    object SelectGradlePathButton: TSpeedButton
      AlignWithMargins = True
      Left = 1338
      Top = 36
      Width = 35
      Height = 32
      Margins.Left = 0
      Margins.Top = 5
      Margins.Right = 6
      Margins.Bottom = 5
      Align = alRight
      Caption = '...'
      OnClick = SelectGradlePathButtonClick
      ExplicitLeft = 1329
      ExplicitTop = 33
      ExplicitHeight = 36
    end
    object GradlePathLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 1369
      Height = 21
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Gradle (gradle.bat) location: (selection will be remembered)'
      ExplicitWidth = 448
    end
    object GradlePathEdit: TEdit
      AlignWithMargins = True
      Left = 6
      Top = 37
      Width = 1332
      Height = 30
      Hint = 
        'Location of gradle.bat file in your Gradle install. Obtain Gradl' +
        'e from here: https://gradle.org/releases/'
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 0
      Margins.Bottom = 6
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      ExplicitHeight = 29
    end
  end
  object PackagesPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 630
    Width = 1379
    Height = 197
    Margins.Left = 0
    Margins.Top = 0
    Margins.Right = 0
    Margins.Bottom = 6
    Align = alBottom
    BevelOuter = bvNone
    Padding.Bottom = 2
    TabOrder = 3
    object PackagesLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 1369
      Height = 21
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 
        'Packages: Each package on a new line, using Gradle short format ' +
        'e.g: androidx.biometric:biometric:1.1.0'
      ExplicitWidth = 779
    end
    object PackagesMemo: TMemo
      AlignWithMargins = True
      Left = 6
      Top = 37
      Width = 1367
      Height = 152
      Hint = 'Packages to download'
      Margins.Left = 6
      Margins.Top = 6
      Margins.Right = 6
      Margins.Bottom = 6
      Align = alClient
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
    end
  end
  object PackageSearchPanel: TPanel
    AlignWithMargins = True
    Left = 0
    Top = 93
    Width = 1379
    Height = 531
    Margins.Left = 0
    Margins.Top = 6
    Margins.Right = 0
    Margins.Bottom = 6
    Align = alClient
    BevelOuter = bvNone
    Padding.Bottom = 2
    TabOrder = 4
    object SearchPackagesLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 5
      Width = 1369
      Height = 21
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'Search Packages:'
      ExplicitWidth = 130
    end
    object URLLabel: TLabel
      AlignWithMargins = True
      Left = 5
      Top = 90
      Width = 1369
      Height = 21
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Align = alTop
      Caption = 'URL:'
      ExplicitTop = 87
      ExplicitWidth = 36
    end
    object PackageSearchEditPanel: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 31
      Width = 1379
      Height = 54
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      BevelOuter = bvNone
      Padding.Bottom = 2
      TabOrder = 0
      object SearchEdit: TEdit
        AlignWithMargins = True
        Left = 6
        Top = 5
        Width = 1220
        Height = 36
        Margins.Left = 6
        Margins.Top = 5
        Margins.Right = 0
        Margins.Bottom = 11
        Align = alClient
        TabOrder = 0
        ExplicitHeight = 29
      end
      object PackageSearchButton: TButton
        AlignWithMargins = True
        Left = 1238
        Top = 0
        Width = 135
        Height = 46
        Margins.Left = 12
        Margins.Top = 0
        Margins.Right = 6
        Margins.Bottom = 6
        Align = alRight
        Caption = 'Search'
        TabOrder = 1
        OnClick = PackageSearchButtonClick
      end
    end
    object PackageSearchResultsPanel: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 170
      Width = 1379
      Height = 359
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alClient
      BevelOuter = bvNone
      Padding.Bottom = 2
      TabOrder = 1
      object PackagesListView: TListView
        AlignWithMargins = True
        Left = 6
        Top = 0
        Width = 842
        Height = 357
        Margins.Left = 6
        Margins.Top = 0
        Margins.Right = 6
        Margins.Bottom = 0
        Align = alClient
        Columns = <
          item
            Caption = 'Title'
            Width = 300
          end
          item
            Caption = 'Package'
            Width = 525
          end>
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnSelectItem = PackagesListViewSelectItem
      end
      object ReleasesPanel: TPanel
        Left = 854
        Top = 0
        Width = 525
        Height = 357
        Margins.Left = 5
        Margins.Top = 5
        Margins.Right = 5
        Margins.Bottom = 5
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object ReleasesListView: TListView
          AlignWithMargins = True
          Left = 0
          Top = 0
          Width = 525
          Height = 290
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alClient
          Columns = <
            item
              Caption = 'Name'
              Width = 300
            end
            item
              Caption = 'Version'
              Width = 188
            end>
          ReadOnly = True
          RowSelect = True
          TabOrder = 0
          ViewStyle = vsReport
        end
        object AddPackageButton: TButton
          AlignWithMargins = True
          Left = 0
          Top = 296
          Width = 525
          Height = 55
          Margins.Left = 0
          Margins.Top = 6
          Margins.Right = 0
          Margins.Bottom = 6
          Action = AddPackageAction
          Align = alBottom
          TabOrder = 1
        end
      end
    end
    object Panel1: TPanel
      AlignWithMargins = True
      Left = 0
      Top = 116
      Width = 1379
      Height = 54
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      BevelOuter = bvNone
      Padding.Bottom = 2
      TabOrder = 2
      object URLEdit: TEdit
        AlignWithMargins = True
        Left = 6
        Top = 5
        Width = 1220
        Height = 36
        Margins.Left = 6
        Margins.Top = 5
        Margins.Right = 0
        Margins.Bottom = 11
        Align = alClient
        TabOrder = 0
        ExplicitHeight = 29
      end
      object URLGetButton: TButton
        AlignWithMargins = True
        Left = 1238
        Top = 0
        Width = 135
        Height = 46
        Margins.Left = 12
        Margins.Top = 0
        Margins.Right = 6
        Margins.Bottom = 6
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
