{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit wDataEdit;

interface

uses
  WDateEdit, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('WDateEdit', @WDateEdit.Register);
end;

initialization
  RegisterPackage('wDataEdit', @Register);
end.
