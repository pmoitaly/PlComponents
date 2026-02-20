program MakeKey;

uses
  Vcl.Forms,
  fMakeKey in 'fMakeKey.pas' {frmMakeKey};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMakeKey, frmMakeKey);
  Application.Run;
end.
