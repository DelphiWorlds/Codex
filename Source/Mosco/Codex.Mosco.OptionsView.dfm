object MoscoOptionsView: TMoscoOptionsView
  Left = 0
  Top = 0
  Caption = 'Mosco Options'
  ClientHeight = 466
  ClientWidth = 587
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Position = poOwnerFormCenter
  ShowHint = True
  TextHeight = 13
  object RootPanel: TPanel
    Left = 0
    Top = 0
    Width = 587
    Height = 466
    Align = alClient
    BevelOuter = bvNone
    ParentShowHint = False
    ShowHint = False
    TabOrder = 0
    object ServerLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 581
      Height = 13
      Align = alTop
      Caption = 'Mosco Server:'
      ExplicitWidth = 69
    end
    object ErrorsLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 179
      Width = 581
      Height = 13
      Align = alTop
      Caption = 'Errors'
      ExplicitWidth = 29
    end
    object OthersLabel: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 255
      Width = 581
      Height = 13
      Align = alTop
      Caption = 'Others'
      ExplicitWidth = 33
    end
    object ServerPanel: TPanel
      AlignWithMargins = True
      Left = 6
      Top = 19
      Width = 578
      Height = 154
      Margins.Left = 6
      Margins.Top = 0
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 0
      object ServerDetailsPanel: TPanel
        Left = 0
        Top = 0
        Width = 492
        Height = 154
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object ServerHostPanel: TPanel
          AlignWithMargins = True
          Left = 0
          Top = 37
          Width = 492
          Height = 29
          Margins.Left = 0
          Margins.Top = 4
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object HostEdit: TEdit
            AlignWithMargins = True
            Left = 159
            Top = 3
            Width = 144
            Height = 23
            Hint = 'IP or hostname for Mosco on the Mac'
            Align = alLeft
            TabOrder = 0
            ExplicitHeight = 21
          end
          object HostRadioButton: TRadioButton
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 150
            Height = 23
            Hint = 'Uses the host as defined in the host edit'
            Align = alLeft
            Caption = 'Host:'
            ParentShowHint = False
            ShowHint = True
            TabOrder = 1
            OnClick = HostRadioButtonClick
          end
        end
        object ServerPortPanel: TPanel
          AlignWithMargins = True
          Left = 0
          Top = 70
          Width = 492
          Height = 29
          Margins.Left = 0
          Margins.Top = 4
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 1
          object ServerPortLabel: TLabel
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 150
            Height = 23
            Align = alLeft
            AutoSize = False
            Caption = 'Port:'
            Transparent = True
            Layout = tlCenter
          end
          object PortEdit: TEdit
            AlignWithMargins = True
            Left = 159
            Top = 3
            Width = 54
            Height = 23
            Hint = 'Port number for Mosco on the Mac'
            Align = alLeft
            NumbersOnly = True
            TabOrder = 0
            ExplicitHeight = 21
          end
        end
        object ServerTimeoutPanel: TPanel
          AlignWithMargins = True
          Left = 0
          Top = 99
          Width = 492
          Height = 29
          Margins.Left = 0
          Margins.Top = 0
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 2
          object ServerTimeoutLabel: TLabel
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 150
            Height = 23
            Align = alLeft
            AutoSize = False
            Caption = 'Request timeout (secs)'
            Transparent = True
            Layout = tlCenter
          end
          object ServerTimeoutEdit: TSpinEdit
            AlignWithMargins = True
            Left = 159
            Top = 3
            Width = 54
            Height = 23
            Hint = 'Number of seconds before the network request times out'
            Align = alLeft
            MaxValue = 120
            MinValue = 1
            TabOrder = 0
            Value = 1
          end
        end
        object ProfilePanel: TPanel
          AlignWithMargins = True
          Left = 0
          Top = 4
          Width = 492
          Height = 29
          Margins.Left = 0
          Margins.Top = 4
          Margins.Right = 0
          Margins.Bottom = 0
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 3
          object ProfileLabel: TLabel
            AlignWithMargins = True
            Left = 159
            Top = 3
            Width = 330
            Height = 23
            Align = alClient
            AutoSize = False
            Transparent = True
            Layout = tlCenter
            ExplicitLeft = 143
            ExplicitWidth = 166
          end
          object ProfileRadioButton: TRadioButton
            AlignWithMargins = True
            Left = 3
            Top = 3
            Width = 150
            Height = 23
            Hint = 'Uses the currently active macOS profile'
            Align = alLeft
            Caption = 'Use active macOS profile'
            Checked = True
            ParentShowHint = False
            ShowHint = True
            TabOrder = 0
            TabStop = True
            OnClick = ProfileRadioButtonClick
          end
        end
      end
      object ServerTestPanel: TPanel
        Left = 492
        Top = 0
        Width = 86
        Height = 154
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object ServerTestButton: TButton
          AlignWithMargins = True
          Left = 2
          Top = 2
          Width = 80
          Height = 28
          Hint = 'Test the connection between Codex and Mosco'
          Margins.Left = 2
          Margins.Top = 2
          Margins.Right = 4
          Margins.Bottom = 2
          Action = ServerTestAction
          Align = alTop
          TabOrder = 0
        end
      end
    end
    object ErrorsPanel: TPanel
      AlignWithMargins = True
      Left = 6
      Top = 195
      Width = 578
      Height = 54
      Margins.Left = 6
      Margins.Top = 0
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 1
      object ErrorsDiagnosticCheckBox: TCheckBox
        AlignWithMargins = True
        Left = 3
        Top = 33
        Width = 572
        Height = 17
        Hint = 'Include diagnostic information from Mosco in the errors'
        Align = alTop
        Caption = 'Include diagnostics (useful for bug reports)'
        TabOrder = 1
      end
      object ErrorsInMessagesCheckBox: TCheckBox
        AlignWithMargins = True
        Left = 3
        Top = 10
        Width = 572
        Height = 17
        Hint = 'Show Mosco errors in the Messages window of the IDE'
        Margins.Top = 10
        Align = alTop
        Caption = 'Show in messages window'
        TabOrder = 0
        OnClick = ErrorsInMessagesCheckBoxClick
      end
    end
    object OthersPanel: TPanel
      AlignWithMargins = True
      Left = 6
      Top = 271
      Width = 578
      Height = 122
      Margins.Left = 6
      Margins.Top = 0
      Align = alTop
      BevelOuter = bvNone
      ParentColor = True
      TabOrder = 2
      object DisableLockCheckCheckBox: TCheckBox
        AlignWithMargins = True
        Left = 3
        Top = 99
        Width = 572
        Height = 17
        Hint = 
          'Disable the check for whether or not a device connected to the M' +
          'ac is locked'
        Margins.Top = 10
        Align = alTop
        Caption = 'Disable device lock check'
        TabOrder = 3
        Visible = False
        OnClick = ErrorsInMessagesCheckBoxClick
      end
      object CertWarningPanel: TPanel
        AlignWithMargins = True
        Left = 0
        Top = 0
        Width = 578
        Height = 29
        Margins.Left = 0
        Margins.Top = 0
        Margins.Right = 0
        Margins.Bottom = 0
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object CertWarnEdit: TSpinEdit
          AlignWithMargins = True
          Left = 227
          Top = 3
          Width = 54
          Height = 23
          Align = alLeft
          MaxValue = 0
          MinValue = 0
          TabOrder = 0
          Value = 7
        end
        object CertWarnCheckBox: TCheckBox
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 218
          Height = 23
          Hint = 
            'Show a warning if any Apple developer certificates are about to ' +
            'expire'
          Align = alLeft
          Caption = 'Apple certificate expiry warning (days)'
          TabOrder = 1
          OnClick = ErrorsInMessagesCheckBoxClick
        end
      end
      object CheckValidProfileCheckBox: TCheckBox
        AlignWithMargins = True
        Left = 3
        Top = 39
        Width = 572
        Height = 17
        Hint = 
          'Automatically check that a valid provisioning profile exists for' +
          ' the project'
        Margins.Top = 10
        Align = alTop
        Caption = 'Auto check valid provisioning profile exists'
        TabOrder = 1
        OnClick = ErrorsInMessagesCheckBoxClick
      end
      object AutoFillMacCertsCheckBox: TCheckBox
        AlignWithMargins = True
        Left = 3
        Top = 69
        Width = 572
        Height = 17
        Hint = 
          'Automatically fill macOS certificate details in Provisioing in P' +
          'roject Options'
        Margins.Top = 10
        Align = alTop
        Caption = 'Auto fill macOS certificate info'
        TabOrder = 2
        OnClick = ErrorsInMessagesCheckBoxClick
      end
    end
  end
  object ActionList: TActionList
    Left = 384
    Top = 209
    object ServerTestAction: TAction
      Caption = 'Test'
      OnExecute = ServerTestActionExecute
      OnUpdate = ServerTestActionUpdate
    end
    object OKAction: TAction
      Caption = 'OK'
      OnUpdate = OKActionUpdate
    end
  end
end
