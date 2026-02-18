object frmMakeKey: TfrmMakeKey
  Left = 0
  Top = 0
  Caption = 'Make Key for Plc Language System'
  ClientHeight = 216
  ClientWidth = 645
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  TextHeight = 15
  object lblString: TLabel
    Left = 40
    Top = 48
    Width = 34
    Height = 15
    Caption = '&String:'
    FocusControl = edtString
  end
  object lblResultingKey: TLabel
    Left = 40
    Top = 104
    Width = 74
    Height = 15
    Caption = 'Resulting &Key:'
    FocusControl = steResultingKey
  end
  object edtString: TEdit
    Left = 136
    Top = 45
    Width = 441
    Height = 23
    TabOrder = 0
    OnChange = edtStringChange
  end
  object steResultingKey: TStaticText
    Left = 136
    Top = 104
    Width = 441
    Height = 19
    AutoSize = False
    BorderStyle = sbsSunken
    TabOrder = 1
  end
  object btnCopy: TButton
    Left = 304
    Top = 160
    Width = 75
    Height = 25
    Caption = '&Copy Key'
    TabOrder = 2
    OnClick = btnCopyClick
  end
  object btnExit: TButton
    Left = 502
    Top = 160
    Width = 75
    Height = 25
    Caption = '&Exit'
    TabOrder = 3
    OnClick = btnExitClick
  end
end
