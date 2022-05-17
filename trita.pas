{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit trita;

interface

uses
  WTComboBox, WTCheckBox, WTMemo, wtList, wtEditComp, WTStringGridSql, 
  WTSGSqlUpdate, WTekrtf, wteditcompNew, WTComboBoxSql, WTNavigator, 
  wtexpression, WTimage, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('WTComboBox', @WTComboBox.Register);
  RegisterUnit('WTCheckBox', @WTCheckBox.Register);
  RegisterUnit('WTMemo', @WTMemo.Register);
  RegisterUnit('wtEditComp', @wtEditComp.Register);
  RegisterUnit('WTStringGridSql', @WTStringGridSql.Register);
  RegisterUnit('WTSGSqlUpdate', @WTSGSqlUpdate.Register);
  RegisterUnit('WTekrtf', @WTekrtf.Register);
  RegisterUnit('wteditcompNew', @wteditcompNew.Register);
  RegisterUnit('WTComboBoxSql', @WTComboBoxSql.Register);
  RegisterUnit('WTNavigator', @WTNavigator.Register);
  RegisterUnit('WTimage', @WTimage.Register);
end;

initialization
  RegisterPackage('trita', @Register);
end.
