object MainForm: TMainForm
  Left = 218
  Top = 125
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Example RIFF / Wave'
  ClientHeight = 145
  ClientWidth = 418
  Color = clBtnFace
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -15
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 120
  TextHeight = 16
  object HeaderLbl: TLabel
    Left = 8
    Top = 8
    Width = 401
    Height = 65
    Alignment = taCenter
    AutoSize = False
    Caption = 
      'This program will play WAVE sound whatsoever, but without resort' +
      'ing to an external drive or built-in functions such as PlaySound' +
      '. This application plays the file itself and even communicate di' +
      'rectly with your driver multimedia!'
    WordWrap = True
  end
  object BrowseBtn: TButton
    Left = 8
    Top = 80
    Width = 193
    Height = 25
    Caption = 'Choose WAVE file'
    TabOrder = 0
    OnClick = BrowseBtnClick
  end
  object WaveEdit: TEdit
    Left = 208
    Top = 80
    Width = 201
    Height = 24
    ReadOnly = True
    TabOrder = 1
  end
  object PlayBtn: TButton
    Left = 8
    Top = 112
    Width = 193
    Height = 25
    Caption = 'Play WAVE'
    TabOrder = 2
    OnClick = PlayBtnClick
  end
  object StopBtn: TButton
    Left = 208
    Top = 112
    Width = 201
    Height = 25
    Caption = 'Stop playing'
    TabOrder = 3
    OnClick = StopBtnClick
  end
  object OpenDlg: TOpenDialog
    DefaultExt = 'wav'
    Filter = 'Fichier WAVE (.wav)|*.wav*'
    Title = 'Choisir un fichier WAVE ...'
    Left = 40
    Top = 24
  end
end
