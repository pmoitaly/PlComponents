object frmNonVisualCompDemo: TfrmNonVisualCompDemo
  Left = 0
  Top = 0
  Caption = 'PlComponents - Non visual components Demo'
  ClientHeight = 378
  ClientWidth = 766
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = mmnMain
  OnCreate = FormCreate
  OnMouseMove = FormMouseMove
  TextHeight = 15
  object lblCursorPosition: TLabel
    Left = 0
    Top = 363
    Width = 766
    Height = 15
    Align = alBottom
    Caption = 'Cursor position: 0,0'
    ExplicitWidth = 102
  end
  object pctMain: TPageControl
    Left = 0
    Top = 0
    Width = 766
    Height = 363
    ActivePage = tbsPlRecentFilesComponent
    Align = alClient
    TabOrder = 0
    ExplicitWidth = 760
    ExplicitHeight = 346
    object tbsIntro: TTabSheet
      Caption = '&Intro'
    end
    object tbsPlMenuFromFolder: TTabSheet
      Caption = 'PlMenuFromFolder'
      ImageIndex = 1
      object lblPlMenuFromFolder: TLabel
        Left = 32
        Top = 16
        Width = 278
        Height = 90
        Caption = 
          'TMenuFromFolderDemo'#13#10#13#10'Dynamically builds menuitems from the con' +
          'tents of a filesystem folder.'#13#10'Select a folder in the tree and o' +
          'pen the Folder menu to see the effect, then click an item.'
        WordWrap = True
      end
      object lblLastMenuItemSelectd: TLabel
        Left = 27
        Top = 176
        Width = 283
        Height = 17
        AutoSize = False
      end
      object douMenuFromFolder: TDirectoryOutline
        Left = 336
        Top = 16
        Width = 249
        Height = 305
        ItemHeight = 22
        Options = [ooDrawFocusRect]
        PictureLeaf.Data = {
          46030000424D460300000000000036000000280000000E0000000E0000000100
          2000000000001003000000000000000000000000000000000000800080008000
          8000800080008000800080008000800080008000800080008000800080008000
          8000800080008000800080008000800080008000800080008000800080008000
          8000800080008000800080008000800080008000800080008000800080008000
          8000800080008000800080008000800080008000800080008000800080008000
          8000800080008000800080008000800080008000800080008000800080008000
          8000800080000000000000000000000000000000000000000000000000000000
          00000000000000000000000000008000800080008000800080000000000000FF
          FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
          FF000000000080008000800080008000800000000000FFFFFF0000FFFF00FFFF
          FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000008000
          800080008000800080000000000000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
          FF00FFFFFF0000FFFF00FFFFFF0000FFFF000000000080008000800080008000
          800000000000FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
          FF0000FFFF00FFFFFF00000000008000800080008000800080000000000000FF
          FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
          FF000000000080008000800080008000800000000000FFFFFF0000FFFF00FFFF
          FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000008000
          8000800080008000800000000000000000000000000000000000000000000000
          0000000000000000000000000000000000008000800080008000800080008000
          80008000800000000000FFFFFF0000FFFF00FFFFFF0000FFFF00000000008000
          8000800080008000800080008000800080008000800080008000800080008080
          8000000000000000000000000000000000008080800080008000800080008000
          8000800080008000800080008000800080008000800080008000800080008000
          8000800080008000800080008000800080008000800080008000800080008000
          80008000800080008000}
        TabOrder = 0
        TextCase = tcAsIs
        OnChange = NewMenuFromFolder
        Data = {10}
      end
      object chkSearchForSubfolders: TCheckBox
        Left = 32
        Top = 304
        Width = 153
        Height = 17
        Caption = 'Search for subfolders'
        TabOrder = 1
        OnClick = AllowSubfoldersInMenu
      end
      object chkAutoUpdateMenu: TCheckBox
        Left = 32
        Top = 272
        Width = 129
        Height = 17
        Caption = 'Auto Update Menu'
        TabOrder = 2
        OnClick = AllowAutoUpdateMenu
      end
    end
    object tbsPlRecentFilesComponent: TTabSheet
      Caption = 'PlRecentFilesComponent'
      ImageIndex = 2
      object lblPlRecentFiles: TLabel
        Left = 40
        Top = 24
        Width = 329
        Height = 273
        AutoSize = False
        Caption = 
          'TPlRecentFilesComponent'#13#10#13#10'PlRecentFileComponent is a wrapper co' +
          'mponent around TPlRecentFileManager class.'#13#10'Its purpose is to ma' +
          'ke recent-file management easily usable from a Form, without req' +
          'uiring manual instantiation or lifecycle handling of the underly' +
          'ing'#13#10'manager class.'#13#10#13#10'Load some text file and open the File->Re' +
          'cent File menu to see the list. '#13#10'Use the "Clear" menu item to c' +
          'lear the list and "Purge" menu item to delete only invalid entri' +
          'es (i.e. renamed or deleted files).'#13#10#13#10'Data are stored in VCLNon' +
          'VisualComponentsDemo.ini file in your Temp folder, until you don' +
          #39't delete it.'
        WordWrap = True
      end
      object memTest: TMemo
        Left = 401
        Top = 132
        Width = 288
        Height = 209
        TabOrder = 0
      end
      object btnLoad: TButton
        Left = 609
        Top = 24
        Width = 74
        Height = 25
        Caption = '&Load'
        TabOrder = 1
        OnClick = LoadTextFile
      end
      object flbRecent: TFileListBox
        Left = 401
        Top = 24
        Width = 184
        Height = 97
        ExtendedSelect = False
        ItemHeight = 15
        Mask = '*.txt'
        TabOrder = 2
      end
    end
    object tbsPlLanguage: TTabSheet
      Caption = 'PlLanguage'
      ImageIndex = 3
      object lblPlLanguage: TLabel
        Left = 56
        Top = 40
        Width = 633
        Height = 105
        AutoSize = False
        Caption = 
          'TPlLanguage'#13#10#13#10'The simplest way to translate your GUI in runtime' +
          '.'#13#10#13#10'Just click the Language menu and choose one of the availabl' +
          'e idioms. The GUI will be updated in real time.'
        WordWrap = True
      end
      object rbtLanguageJson: TRadioButton
        Left = 176
        Top = 192
        Width = 113
        Height = 17
        Caption = 'Use &Json'
        TabOrder = 0
      end
      object rbtLanguageIni: TRadioButton
        Left = 352
        Top = 192
        Width = 113
        Height = 17
        Caption = 'Use &Ini'
        Checked = True
        TabOrder = 1
        TabStop = True
      end
    end
    object tbsPlLockWndManager: TTabSheet
      Caption = 'PlLockWndManager'
      ImageIndex = 4
      object lblPlLockWndManager: TLabel
        Left = 48
        Top = 32
        Width = 329
        Height = 249
        AutoSize = False
        Caption = 
          'TPlLockWndManagr'#13#10#13#10'`TPlLockWndManager` is a Delphi component th' +
          'at manages redraw locking on a target window using the Windows m' +
          'essage `WM_SETREDRAW`.  '#13#10'This is useful when performing batch u' +
          'pdates on controls or forms, preventing flicker and unnecessary ' +
          'redraws until the operation is complete.'#13#10#13#10'Click the Start butt' +
          'on and the box content will be updated every second. Howewer, th' +
          'e windows will not repainted for 5 seconds. Then you will see in' +
          ' the box the result of the updates.'
        WordWrap = True
      end
      object memLockWnd: TMemo
        Left = 432
        Top = 29
        Width = 273
        Height = 188
        Lines.Strings = (
          'memLockWnd')
        TabOrder = 0
      end
      object btnStartLock: TButton
        Left = 536
        Top = 240
        Width = 75
        Height = 25
        Caption = 'Start'
        TabOrder = 1
        OnClick = PerformLock
      end
    end
    object tbsPlRuntimeDesigner: TTabSheet
      Caption = 'PlRuntimeDesigner'
      ImageIndex = 5
      object lblPlRuntimeDemo: TLabel
        Left = 16
        Top = 16
        Width = 561
        Height = 193
        AutoSize = False
        Caption = 
          'Runtime Design Demo'#13#10'To begin moving and resizing components, us' +
          'e the Designer|Start menu.'#10#13#10'Move a cursor over any interface ob' +
          'ject: it will change to a straight arrow to resize it, or a cros' +
          'shair to move it. '#13#10'Thene click and move the mouse cursor until ' +
          'you achieve the desired effect. '#13#10'When you'#39're finished, use the ' +
          'Designer|End menu.'#10#13#10'To make your changes persistent, use the De' +
          'signer|Save menu; you can reload a saved position at any time wi' +
          'th the Designer|Load menu.'
        WordWrap = True
      end
    end
    object tbsPlStyleMenuManager: TTabSheet
      Caption = 'PlStyleMenuManager'
      ImageIndex = 6
      object lblPlStyleMenuManager: TLabel
        Left = 16
        Top = 16
        Width = 377
        Height = 145
        AutoSize = False
        Caption = 
          'TPlStyleMenuManager is a component that displays all the applica' +
          'tion'#39's styles in a menu.'#13#10'Click the "Styles" item in the main me' +
          'nu to see a list of available styles.'#13#10'If you want menu items to' +
          ' be rendered with their respective styles, select or deselect th' +
          'e chekbox on the right.'
        WordWrap = True
      end
      object chkStylePreview: TCheckBox
        Left = 436
        Top = 40
        Width = 95
        Height = 17
        Caption = 'Style preview'
        TabOrder = 0
        OnClick = SwitchStylePreview
      end
    end
  end
  object rtdDemo: TPlRunTimeDesigner
    Active = False
    IniName = 'C:\Temp\RtdDemo.ini'
    ManageForm = True
    OwnerOnly = True
    Proximity = 5
    Left = 424
    Top = 264
  end
  object mmnMain: TMainMenu
    Left = 696
    Top = 328
    object mitFile: TMenuItem
      Caption = '&File'
      object mitRecentFiles: TMenuItem
        Caption = 'Recent Files'
        object N2: TMenuItem
          Caption = '-'
        end
        object mitClearList: TMenuItem
          Caption = 'Clear list'
          OnClick = ClearRecentFilesList
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Windows'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Amakrits'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Aqua Light Slate'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Turquoise Gray'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Windows11 White Smoke'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Windows11 MineShaft'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Glow'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Mountain_Mist'
            Checked = True
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Emerald'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Windows11 Polar Light'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Calypso SE'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Windows11 Modern Dark'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Flat UI Light'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Windows Designer Dark'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Stellar'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Windows11 Polar Dark'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Windows Designer'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Stellar Dark'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Win10IDE_Dark'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Windows11 Modern Light'
            RadioItem = True
          end
          object TMenuItem
            AutoCheck = True
            AutoHotkeys = maManual
            Caption = 'Calypso'
            RadioItem = True
          end
        end
        object mitPurgeList: TMenuItem
          Caption = 'PurgeList'
          OnClick = PurgeRecentFilesList
        end
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mitExit: TMenuItem
        Caption = 'E&xit'
        ShortCut = 32883
        OnClick = ExitApplication
      end
    end
    object mitDesigner: TMenuItem
      Caption = 'Designer'
      object mitDesignerStart: TMenuItem
        Caption = 'Start'
        ShortCut = 49235
        OnClick = StartRuntimeDesign
      end
      object mitDesignerEnd: TMenuItem
        Caption = 'End'
        ShortCut = 49221
        OnClick = EndRuntimeDesign
      end
      object N3: TMenuItem
        Caption = '-'
      end
      object mitDesignerLoad: TMenuItem
        Caption = 'Load'
        ShortCut = 49228
        OnClick = LoadPositions
      end
      object mitDesignerSave: TMenuItem
        Caption = 'Save'
        ShortCut = 49235
        OnClick = SavePositionsData
      end
    end
    object mitFolder: TMenuItem
      Caption = 'Folder'
    end
    object mitOptions: TMenuItem
      Caption = 'Options'
      object mitStyle: TMenuItem
        Caption = 'Style'
      end
      object N4: TMenuItem
        Caption = '-'
      end
      object mitLanguage: TMenuItem
        Caption = 'Language'
        SubMenuImages = imlFlags
      end
    end
  end
  object mffDemo: TPlMenuFromFolder
    AutoUpdate = False
    Enabled = True
    HelpContext = 0
    MenuItem = mitFolder
    WatchSubTree = False
    OnClick = ShowLastMenuSelection
    Left = 372
    Top = 330
  end
  object tmrLockWindow: TTimer
    Enabled = False
    OnTimer = LockWindowUpdate
    Left = 540
    Top = 330
  end
  object lwmDemo: TPlLockWndManager
    Left = 628
    Top = 330
  end
  object lngDemo: TPlLanguage
    CreateIfMissing = True
    ExcludeClasses.Strings = (
      'TImage'
      'TImageList'
      'TPlLanguage'
      'TPlMenuFromFolder'
      'TPlRecentFilesComponent'
      'TPlRuntimeDesigner'
      'TPlStylesMenuManager')
    ExcludeOnAction = True
    ExcludeProperties.Strings = (
      'Category'
      'DefaultDir'
      'FileName'
      'HelpFile'
      'HelpKeyword'
      'ImageName'
      'ImeName'
      'IniFile'
      'LangFile'
      'LangPath'
      'Language'
      'Name'
      'PrioritySchedule'
      'StyleName')
    FileFormat = lpIni
    Language = 'English'
    RegisterOnStart = True
    Left = 508
    Top = 266
  end
  object mffLanguage: TPlMenuFromFolder
    AutoUpdate = True
    Enabled = True
    HelpContext = 0
    ImageList = imlFlags
    MenuItem = mitLanguage
    WatchSubTree = False
    Left = 292
    Top = 330
  end
  object smmDemo: TPlStylesMenuManager
    Active = True
    CustomStylesExt = '*.vsf'
    MenuItem = mitStyle
    MenuTag = 100
    StylePreview = False
    Left = 612
    Top = 266
  end
  object rfcDemo: TPlRecentFilesComponent
    RecentMenu = mitRecentFiles
    Left = 444
    Top = 330
  end
  object imlFlags: TImageList
    ColorDepth = cd16Bit
    Masked = False
    Left = 716
    Top = 234
  end
end
