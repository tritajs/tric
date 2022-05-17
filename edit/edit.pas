{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit Edit;

interface

uses
  umEdit, WDateEdit, LSystemTrita, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('umEdit', @umEdit.Register);
  RegisterUnit('WDateEdit', @WDateEdit.Register);
end;

initialization
  RegisterPackage('Edit', @Register);
end.
