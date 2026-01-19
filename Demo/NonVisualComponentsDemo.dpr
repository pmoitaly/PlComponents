program NonVisualComponentsDemo;

uses
  madExcept,
  madLinkDisAsm,
  madListHardware,
  madListProcesses,
  madListModules,
  Vcl.Forms,
  fNonVisualComponentsDemo in 'fNonVisualComponentsDemo.pas' {frmNonVisualCompDemo},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Aqua Light Slate');
  Application.CreateForm(TfrmNonVisualCompDemo, frmNonVisualCompDemo);
  Application.Run;
end.
