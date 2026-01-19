unit PlSeComponentsRegister;

{$R plc.SE.Components.Icons.res}

interface

uses
  System.Classes;

procedure Register;

implementation

uses
  PlSynEditPrintUtils;

procedure Register;
begin
  RegisterComponents('PlSynEditTools', [TPlSynEditPrintSystem]);
end;

end.

