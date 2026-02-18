unit fMakeKey;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmMakeKey = class(TForm)
    lblString: TLabel;
    edtString: TEdit;
    lblResultingKey: TLabel;
    steResultingKey: TStaticText;
    btnCopy: TButton;
    btnExit: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btnCopyClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure edtStringChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmMakeKey: TfrmMakeKey;

implementation

{$R *.dfm}

uses
  Vcl.Clipbrd,
  PlLanguageEncoder;

procedure TfrmMakeKey.FormCreate(Sender: TObject);
begin
  btnCopy.Enabled := False;
  edtString.Text := '';
  steResultingKey.Caption := '';
end;

procedure TfrmMakeKey.btnCopyClick(Sender: TObject);
begin
  Clipboard.AsText := steResultingKey.Caption;
end;

procedure TfrmMakeKey.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfrmMakeKey.edtStringChange(Sender: TObject);
begin
  btnCopy.Enabled := edtString.Text <> '';
  steResultingKey.Caption := TPlLineEncoder.MakeKey(edtString.Text);
end;

end.
