unit nososettings;

{$mode ObjFPC}{$H+}

INTERFACE

uses
  Classes, SysUtils, strutils;

Type

  TSetting = Record
    name    : string;
    value   : string;
    Comment : string;
    end;

Procedure SetSettingsFilename(name:string);
Procedure InitSetting(Name,value,comment:string);
Function GetSetInt(name:string):int64;
Function GetSetStr(name:string):string;
Function GetSetBool(name:string):boolean;
Procedure SaveSettings();
Procedure LoadSettings();

var
  ArraySettings     : Array of TSetting;
  SettingsFilename  : string = 'config.conf';
  SetsFile          : TextFile;

IMPLEMENTATION

Procedure SetSettingsFilename(name:string);
Begin
  SettingsFilename := name;
  AssignFile(SetsFile, SettingsFilename);
End;

Procedure InitSetting(Name,value,comment:string);
Begin
  SetLength(ArraySettings,Length(ArraySettings)+1);
  ArraySettings[Length(ArraySettings)-1].name    := name;
  ArraySettings[Length(ArraySettings)-1].value   := value;
  ArraySettings[Length(ArraySettings)-1].Comment := comment;
End;

Function GetSetInt(name:string):int64;
var
  counter : integer;
Begin
  result := 0;
  for counter := 0 to high(ArraySettings) do
    if UpperCase(ArraySettings[counter].name) = Uppercase(name) then
      begin
      result := StrToInt64Def(ArraySettings[counter].value,0);
      break;
      end;
End;

Function GetSetStr(name:string):string;
var
  counter : integer;
Begin
  result := '';
  for counter := 0 to high(ArraySettings) do
    if UpperCase(ArraySettings[counter].name) = Uppercase(name) then
      begin
      result := ArraySettings[counter].value;
      break;
      end;
End;

Function GetSetBool(name:string):boolean;
var
  counter : integer;
Begin
  result := false;
  for counter := 0 to high(ArraySettings) do
    if UpperCase(ArraySettings[counter].name) = Uppercase(name) then
      begin
      result := StrTOBoolDef(ArraySettings[counter].value,False);
      break;
      end;
End;

Procedure SaveSettings();
var
  counter : integer;
Begin
  Rewrite(SetsFile);
  for counter := 0 to high(ArraySettings) do
    begin
    writeln(SetsFile,format('# %s',[ArraySettings[counter].Comment]));
    writeln(SetsFile,format('%s %s',[ArraySettings[counter].name,ArraySettings[counter].value]));
    writeln(Setsfile,'');
    end;
  CloseFile(SetsFile);
End;

Procedure LoadSettings();
var
  LLine   : string;
  DataArr : array of string;
  Counter : integer;
Begin
  reset(SetsFile);
  While not eof(SetsFile) do
     begin
     Readln(SetsFile,LLine);
     DataArr := SplitString(LLine,' ');
     for counter := 0 to high(ArraySettings) do
       begin
       if Uppercase(DataArr[0]) = Uppercase(ArraySettings[counter].name) then
         begin
         ArraySettings[counter].value:= DataArr[1];
         end;
       end;
     end;
  CloseFile(SetsFile);
End;

INITIALIZATION
  SetLength(ArraySettings,0);
  AssignFile(SetsFile, SettingsFilename);

END.{End unit}

