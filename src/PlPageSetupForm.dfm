object frmPlPageSetup: TfrmPlPageSetup
  Left = 0
  Top = 0
  Caption = 'Page Setup'
  ClientHeight = 314
  ClientWidth = 392
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  TextHeight = 15
  object lblPreset: TLabel
    Left = 20
    Top = 16
    Width = 87
    Height = 15
    Caption = 'Formato pagina:'
  end
  object lblUnit: TLabel
    Left = 20
    Top = 50
    Width = 83
    Height = 15
    Caption = 'Unit'#224' di misura:'
  end
  object lblWidth: TLabel
    Left = 20
    Top = 82
    Width = 55
    Height = 15
    Caption = 'Larghezza:'
  end
  object lblHeight: TLabel
    Left = 240
    Top = 82
    Width = 40
    Height = 15
    Caption = 'Altezza:'
  end
  object cboPreset: TComboBox
    Left = 140
    Top = 14
    Width = 200
    Height = 23
    Style = csDropDownList
    TabOrder = 0
    Items.Strings = (
      'Personalizzato'
      'A4 (Verticale)'
      'A4 (Orizzontale)'
      'Letter (Verticale)'
      'Letter (Orizzontale)')
  end
  object cboUnit: TComboBox
    Left = 140
    Top = 48
    Width = 100
    Height = 23
    Style = csDropDownList
    TabOrder = 1
    Items.Strings = (
      'Millimeters'
      'Inches')
  end
  object edtWidth: TEdit
    Left = 140
    Top = 80
    Width = 80
    Height = 23
    TabOrder = 2
    OnClick = SyncronizePreset
  end
  object edtHeight: TEdit
    Left = 300
    Top = 80
    Width = 80
    Height = 23
    TabOrder = 3
    OnClick = SyncronizePreset
  end
  object grpMargins: TGroupBox
    Left = 20
    Top = 115
    Width = 360
    Height = 80
    Caption = 'Margini'
    TabOrder = 4
    object lblLeft: TLabel
      Left = 20
      Top = 20
      Width = 42
      Height = 15
      Caption = 'Sinistro:'
    end
    object lblRight: TLabel
      Left = 150
      Top = 20
      Width = 37
      Height = 15
      Caption = 'Destro:'
    end
    object lblTop: TLabel
      Left = 20
      Top = 50
      Width = 53
      Height = 15
      Caption = 'Superiore:'
    end
    object lblBottom: TLabel
      Left = 150
      Top = 50
      Width = 47
      Height = 15
      Caption = 'Inferiore:'
    end
    object edtMarginLeft: TEdit
      Left = 80
      Top = 18
      Width = 50
      Height = 23
      TabOrder = 0
    end
    object edtMarginRight: TEdit
      Left = 200
      Top = 18
      Width = 50
      Height = 23
      TabOrder = 1
    end
    object edtMarginTop: TEdit
      Left = 80
      Top = 48
      Width = 50
      Height = 23
      TabOrder = 2
    end
    object edtMarginBottom: TEdit
      Left = 200
      Top = 48
      Width = 50
      Height = 23
      TabOrder = 3
    end
  end
  object grpOrientation: TGroupBox
    Left = 20
    Top = 205
    Width = 360
    Height = 50
    Caption = 'Orientamento'
    TabOrder = 5
    object radPortrait: TRadioButton
      Left = 40
      Top = 20
      Width = 113
      Height = 17
      Caption = 'Ritratto'
      TabOrder = 0
      OnClick = SyncronizePreset
    end
    object radLandscape: TRadioButton
      Left = 140
      Top = 20
      Width = 113
      Height = 17
      Caption = 'Paesaggio'
      TabOrder = 1
      OnClick = SyncronizePreset
    end
  end
  object btnOK: TButton
    Left = 210
    Top = 270
    Width = 80
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 6
  end
  object btnCancel: TButton
    Left = 300
    Top = 270
    Width = 80
    Height = 25
    Caption = 'Annulla'
    ModalResult = 2
    TabOrder = 7
  end
end
