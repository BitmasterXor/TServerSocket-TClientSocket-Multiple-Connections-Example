object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'TServerSocket Multiple Clients Example By: BitmasterXor'
  ClientHeight = 266
  ClientWidth = 646
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  TextHeight = 15
  object ListView1: TListView
    Left = 0
    Top = 0
    Width = 645
    Height = 244
    Columns = <
      item
        AutoSize = True
        Caption = 'IP Address'
      end
      item
        AutoSize = True
        Caption = 'Client ID'
      end>
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 247
    Width = 646
    Height = 19
    Panels = <
      item
        Text = 'Status: Active on port 3434'
        Width = 180
      end
      item
        Text = 'Victims Online: 0'
        Width = 150
      end>
  end
  object PopupMenu1: TPopupMenu
    Left = 48
    Top = 40
    object B1: TMenuItem
      Caption = 'Broadcast Message To ALL Victims'
      OnClick = B1Click
    end
    object S1: TMenuItem
      Caption = 'Send Message To Selected Victim'
      OnClick = S1Click
    end
  end
  object ServerSocket1: TServerSocket
    Active = False
    Port = 0
    ServerType = stNonBlocking
    OnClientDisconnect = ServerSocket1ClientDisconnect
    OnClientRead = ServerSocket1ClientRead
    Left = 152
    Top = 40
  end
end
