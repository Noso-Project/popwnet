unit Noso_TUI;

{$mode ObjFPC}{$H+}

{
NosoTUI 1.2
December 28th, 2022
Noso project unit to manage the output to screen on cli apps.
No external dependencyes.

Changes:
- BKColor changed to SetBKColor.
- Console scroll functions.
}

interface

uses
  Classes, SysUtils, video, keyboard;

Type
  TAlign   = (AlLeft, AlRight, AlCenter);
  TBorder  = (BdSingle, BdDouble, BdBlock, BdSimple);

  TEditData = Record
    OutString : string;
    OutKey    : integer;
    end;

  TConsole = Record
    Active     : boolean;
    x1         : integer;
    y1         : integer;
    x2         : integer;
    y2         : integer;
    Width      : integer;
    Height     : integer;
    LastLine   : integer;
    LastShowed : integer;
    Auto       : boolean;
    FColor     : word;
    BColor     : word;
    end;

  TCustControl = Record
    CName     : string;
    CValue    : string;
    xpos      : word;
    ypos      : word;
    CWidth    : word;
    CAlign    : TAlign;
    TextColor : word;
    BackColor : word;
    end;

{General}
Procedure GotoXy(x,y:word);
Procedure SetColor(color:word);
Procedure SetBKColor(color:word);
Procedure SetBorder(LBorder:TBorder);
Procedure ClrLine(LNumber:integer;bkcolor:word=black);
Procedure Cls(x1:integer = 0;y1:integer=0;x2:integer=0;y2:integer=0);
Procedure SetCursorMode(Mode:word);

{Basic}
Procedure TextOut(X,Y : Word;Const S : String;FC,BC:word;update:boolean = true);
Procedure DLabel(x,y:word;Texto:String;Lwidth:integer;LAling:TAlign;forCol,BacCol:word;update:boolean=true);
Procedure HorizLine(filenum,x1,x2,FroCol, BackCol:word;Limits:boolean = false);
Procedure VertLine(Column,y1,y2,FroCol, BackCol:word;Limits:boolean = false);
Procedure DWindow(x1,y1,x2,y2:integer;title:String;FC,FB:word);

{Console}
Procedure ClearConsole;
Procedure SetConsole(x1,y1,x2,y2,fc,bc:word);
Procedure ToConsole(TextContent:string);
Procedure ConsoleNewLine;
Procedure ConsoleScrollUp(Lines:integer);
Procedure ConsoleScrollDown(lines:integer);

{KeyBoard}
Function KeyPressedCode:integer;
Function ReadEditScreen(x,y:integer;InitialString:String;EditWidth:Integer):TEditData;
Function ReadNavigationKey():integer;

{Controls}
Procedure CreateControl(CName,CValue:String;xpos,ypos,cWidth,cColor,cBColor:Word;Calign:TAlign);
Procedure SetContol(Name,Value:String;UPDScreen:Boolean = false);

Const
  black = video.black;
  blue  = video.blue;
  green = video.green;
  cyan  = video.cyan;
  red   = video.red;
  magenta = video.magenta;
  brown = video.brown;
  lightGray = video.lightGray;
  darkGray = video.darkGray;
  lightBlue = video.lightBlue;
  lightGreen = video.lightGreen;
  lightCyan = video.lightCyan;
  lightRed = video.lightRed;
  lightMagenta = video.lightMagenta;
  yellow = video.yellow;
  white = video.white;
  curhide = video.crHidden;
  curshow = video.crUnderLine;
  curblock = video.crBlock;
  curhalfblock = video.crHalfBlock;

var
  Fcolor            : word = video.lightgray;
  BColor            : word = video.black;
  Borders           : Array of string;
  ActiveBorderStile : TBorder = BdSimple;
  LChar             : string = #043#045#043#043#124#043#043#043#043#043;
  MyConsole         : TConsole;
  SLConsole         : TStringList;
  LockBorder        : boolean = false;
  ArrayControls     : Array of TCustControl;

IMPLEMENTATION

{$REGION General}

{Place the cursos in the specified position}
Procedure GotoXy(x,y:word);
Begin
SetCursorPos(x-1,y-1);
End;

{Set the text color}
Procedure SetColor(color:word);
Begin
FColor := color;
UpdateScreen(true);
End;

{Set the backgroundcolor}
Procedure SetBKColor(color:word);
Begin
BColor := color;
UpdateScreen(true);
End;

{Set the border style}
Procedure SetBorder(LBorder:TBorder);
Begin
if not LockBorder then
   begin
   ActiveBorderStile := LBorder;
   LCHar := Borders[Ord(LBorder)];
   end;
End;

{Clears the specified line on screen}
Procedure ClrLine(LNumber:integer;bkcolor:word=black);
var
  counter : integer;
Begin
for counter := 1 to ScreenWidth do
   TextOut(counter,lnumber,' ',fcolor,bkcolor,false);
UpdateScreen(true);
End;

{Clears a region of the screen}
Procedure Cls(x1:integer = 0;y1:integer=0;x2:integer=0;y2:integer=0);
var
  row,col : integer;
Begin
if x1 = 0 then ClearScreen
else
   begin
   for row := y1 to y2 do
      begin
      for col := x1 to x2 do
         begin
         TextOut(col,row,' ',fcolor,bcolor,false);
         end;
      end;
   end;
UpdateScreen(true);
End;

Procedure SetCursorMode(Mode:word);
Begin
  SetCursorType(Mode);
End;

{$ENDREGION}

{$REGION Basic}

{Show the specified text with the specified details}
 Procedure TextOut(X,Y : Word;Const S : String;FC,BC:word;update:boolean = true);
Var
  P,I,M : Word;
Begin
  P:=((X-1)+(Y-1)*ScreenWidth);
  M:=Length(S);
  If P+M>ScreenWidth*ScreenHeight then
    M:=ScreenWidth*ScreenHeight-P;
  For I:=1 to M do
    VideoBuf^[P+I-1]:=Ord(S[i])+(FC + BC shl 4) shl 8;
  if update then UpdateScreen(true);
End;

{Shows a label}
Procedure DLabel(x,y:word;Texto:String;Lwidth:integer;LAling:TAlign;forCol,BacCol:word;update:boolean=true);
var
  OutText : string;
  Whites  : integer;
Begin
  if LEngth(Texto)>LWidth then SetLEngth(Texto,LWidth);
  Whites := (LWidth div 2)-(LEngth(Texto) div 2);
  if LAling = AlLeft then OutText := Format('%0:-'+Lwidth.ToString+'s',[Texto])
  else if LAling = AlRight then OutText := Format('%0:'+Lwidth.ToString+'s',[Texto])
  else OutText := Format('%0:-'+Lwidth.ToString+'s',[Space(Whites)+Texto]);
  TextOut(X,Y,OutText,ForCol,BacCol,false);
  if update then UpdateScreen(true);
End;

{Draws a horizontal line}
Procedure HorizLine(filenum,x1,x2,FroCol, BackCol:word;Limits:boolean = false);
var
  Counter : integer;
Begin
  for counter := x1 to x2 do
    TextOut(counter,filenum,LChar[2],FroCol,BackCol,false);
  if limits then
    begin
    TextOut(x1,filenum,LChar[10],FroCol,BackCol,false);
    TextOut(x2,filenum,LChar[6],FroCol,BackCol,false);
    end;
  UpdateScreen(true);
End;

{Draws a vertical line}
Procedure VertLine(Column,y1,y2,FroCol, BackCol:word;Limits:boolean = false);
var
  Counter : integer;
Begin
  for counter := y1 to y2 do
    TextOut(Column,counter,LChar[5],FroCol,BackCol,false);
  if limits then
    begin
    TextOut(Column,y1,LChar[3],FroCol,BackCol,false);
    TextOut(Column,y2,LChar[8],FroCol,BackCol,false);
    end;
  UpdateScreen(true);
End;

{Draws a rectangle with optional title}
Procedure DWindow(x1,y1,x2,y2:integer;title:String;FC,FB:word);
var
  counter  : integer;
  TitleX   : integer;
Begin
  TextOut(x1,y1,LChar[1],FC,FB,false);
  TextOut(x1,y2,LChar[9],FC,FB,false);
  TextOut(x2,y1,LChar[4],FC,FB,false);
  TextOut(x2,y2,LChar[7],FC,FB,false);
  for counter := x1+1 to x2-1 do
    begin
    TextOut(counter,y1,LChar[2],FC,FB,false);
    TextOut(counter,y2,LChar[2],FC,FB,false);
    end;
  for counter := y1+1 to y2-1 do
    begin
    TextOut(x1,counter,LChar[5],FC,FB,false);
    TextOut(x2,counter,LChar[5],FC,FB,false);
    end;
  if Title <> '' then
    begin
    TitleX := (x2-x1) div 2;
    TitleX := TitleX-(Length(Title)div 2);
    TextOut(TitleX,y1,LChar[6],FC,FB,false);
    TextOut(TitleX+1,y1,' '+Title+' ',FC,FB,false);
    TextOut(TitleX+3+length(title),y1,LChar[10],FC,FB,false);
    end;
  UpdateScreen(true);
End;

{$ENDREGION}

{$REGION Console}

Procedure ClearConsole;
Begin
MyConsole := Default(TConsole);
End;

Procedure SetConsole(x1,y1,x2,y2,fc,bc:word);
var
  CurrColor : word;
Begin
MyConsole.Active:=true;
MyConsole.x1:=x1;
MyConsole.x2:=x2;
MyConsole.y1:=y1;
MyConsole.y2:=y2;
MyConsole.width := x2-x1+1;
MyConsole.height := y2-y1+1;
MyConsole.LastLine:=0;
MyConsole.LastShowed := 0;
MyConsole.Auto:=true;
MyConsole.FColor := fc;
MyConsole.BColor := bc;
CurrColor := BColor;
SetBkColor(bc);
cls(x1,y1,x2,y2);
SetBkColor(CurrColor);
End;

Procedure ToConsole(TextContent:string);
var
  Splits   : integer;
  Counter  : integer;
  ToShow   : String;
Begin
if not Myconsole.Active then exit;
if length(TextContent) = 0 then exit;
Splits := (length(textContent) div MyConsole.width);
if (length(textContent) mod MyConsole.width) > 0 then inc(Splits);
For counter := 1 to splits do
   begin
   ToShow := Copy(TextContent,1+((counter-1)*Myconsole.width),Myconsole.width);
   if MyConsole.Auto then
     begin
     if MyConsole.LastLine>=MyConsole.Height then ConsoleNewLine;
     TextOut(MyCOnsole.x1,MyConsole.y1+MyConsole.LastLine,ToShow,myconsole.FColor,myconsole.BColor,false);
     Inc(MyConsole.LastLine);
     end;
   SLConsole.Add(ToShow);
   end;
if MyConsole.Auto then MyConsole.LastShowed:=SLConsole.Count;
UpdateScreen(true);
End;

Procedure ConsoleNewLine;
var
  counter : integer;
Begin
cls(MyConsole.x1,MyConsole.y1,MyConsole.x2,MyConsole.y2);
for counter := 0 to MyConsole.height-2 do
   TextOut(MyCOnsole.x1,MyConsole.y1+counter,SLConsole[SLConsole.Count-MyConsole.height+counter+1],white,black,false);
Dec(MyConsole.LastLine);
End;

Procedure ConsoleScrollUp(Lines:integer);
var
  counter : integer;
Begin
  if SLConsole.Count< MyConsole.Height then exit;
  if MyConsole.LastShowed< MyConsole.Height then exit;
  MyConsole.Auto:=false;
  Dec(MyConsole.LastShowed,lines);
  if MyConsole.LastShowed<MyConsole.Height then MyConsole.LastShowed:=MyConsole.Height;
  cls(MyConsole.x1,MyConsole.y1,MyConsole.x2,MyConsole.y2);
  for counter := 0 to MyConsole.height-1 do
    TextOut(MyCOnsole.x1,MyConsole.y1+counter,SLConsole[MyCOnsole.LastShowed+counter-MyConsole.Height],white,black,false);
  UpdateScreen(True);
End;

Procedure ConsoleScrollDown(lines:integer);
var
  counter : integer;
Begin
  if MyConsole.LastShowed = SLConsole.Count then exit;
  Inc(MyConsole.LastShowed,lines);
  if MyConsole.LastShowed>SLConsole.Count then MyConsole.LastShowed:=SLConsole.Count;
  cls(MyConsole.x1,MyConsole.y1,MyConsole.x2,MyConsole.y2);
  for counter := 0 to MyConsole.height-1 do
    TextOut(MyCOnsole.x1,MyConsole.y1+counter,SLConsole[MyCOnsole.LastShowed+counter-MyConsole.Height],white,black,false);
  if MyConsole.LastShowed = SLConsole.Count then MyConsole.Auto:=true;
  UpdateScreen(True);
End;

{$ENDREGION}

{$REGION Keyboard}

Function KeyPressedCode:integer;
var
  LKey : TKeyEvent;
Begin
result := 0;
LKey:=PollKeyEvent;
If LKey<>0 then
   begin
   LKey:=GetKeyEvent;
   Result :=  GetKeyEventCode(LKey);
   end;
End;

Function ReadEditScreen(x,y:integer;InitialString:String;EditWidth:Integer):TEditData;
var
  currentValue : string;
  IsDone       : boolean = false;
  KChar: Char;
  K: TKeyEvent;
  KCode : integer;
  ExitCode     : integer;
Begin
Dlabel(x,y,Initialstring,EditWidth,AlLEft,black,white);
Gotoxy(x+length(InitialString),y);
currentValue := InitialString;
Repeat
   sleep(1);
   K := PollKeyEvent;
   if K <> 0 then
      begin
      K := GetKeyEvent;
      K := TranslateKeyEvent(K);
      KCode := GetKeyEventCode(K);
      KChar := GetKeyEventChar(K);
      if KChar = #27 then
         begin
         CurrentValue := InitialString;
         ExitCode := 72;
         IsDone := true;
         end
      else if KChar=#13 then
         begin
         ExitCode := 80;
         IsDone := true;
         end
      else if KCode=65319 then
         begin
         ExitCode := 80;
         IsDone := true;
         end
      else if KCode=65313 then
         begin
         ExitCode := 72;
         IsDone := true;
         end
      else if KChar=#8 then
         begin
         if Length(currentValue)>0 then
            begin
            Setlength(CurrentValue,Length(currentValue)-1);
            if length(currentValue)>EditWidth-1 then
               Dlabel(x,y,RightStr(currentValue,EditWidth-1),EditWidth,AlLeft,black,white)
            else Dlabel(x,y,currentValue,EditWidth,AlLEft,black,white);
            if length(currentValue)>EditWidth-1 then Gotoxy(x+EditWidth-1,y)
            else Gotoxy(x+length(currentValue),y);
            end;
         end
      else
         begin
         CurrentValue := currentValue+KChar;
         if length(currentValue)>EditWidth-1 then
            Dlabel(x,y,RightStr(currentValue,EditWidth-1),EditWidth,AlLeft,black,white)
         else Dlabel(x,y,currentValue,EditWidth,AlLEft,black,white);
         if length(currentValue)>EditWidth-1 then Gotoxy(x+EditWidth-1,y)
         else Gotoxy(x+length(currentValue),y);
         end;
      end;
until IsDone ;
Result.OutKey:=ExitCode;
Result.OutString:=CurrentValue;
End;

Function ReadNavigationKey():integer;
var
  IsDone       : boolean = false;
  KChar: Char;
  K: TKeyEvent;
  KCode : integer;
  ExitCode     : integer;
Begin
Repeat
   sleep(1);
   K := PollKeyEvent;
   if K <> 0 then
      begin
      K := GetKeyEvent;
      K := TranslateKeyEvent(K);
      KCode := GetKeyEventCode(K);
      KChar := GetKeyEventChar(K);
      if KChar = #27 then
         begin
         ExitCode := 27;
         IsDone := true;
         end
      else if KChar=#13 then
         begin
         ExitCode := 13;
         IsDone := true;
         end
      else if KCode=65319 then
         begin
         ExitCode := 80;
         IsDone := true;
         end
      else if KCode=65313 then
         begin
         ExitCode := 72;
         IsDone := true;
         end
      else if KCode=65315 then
         begin
         ExitCode := 75;
         IsDone := true;
         end
      else if KCode=65317 then
         begin
         ExitCode := 77;
         IsDone := true;
         end
      end;
until isdone;
Result := ExitCode;
End;

{$ENDREGION}

{$REGION Controls}

{Creates a control}
Procedure CreateControl(CName,CValue:String;xpos,ypos,cWidth,cColor,cBColor:Word;Calign:TAlign);
Begin
   SetLength(ArrayControls,Length(ArrayControls)+1);
   ArrayControls[Length(ArrayControls)-1].CName    := CName;
   ArrayControls[Length(ArrayControls)-1].CValue   := CValue;
   ArrayControls[Length(ArrayControls)-1].xpos     := Xpos;
   ArrayControls[Length(ArrayControls)-1].ypos     := ypos;
   ArrayControls[Length(ArrayControls)-1].CWidth   := cWidth;
   ArrayControls[Length(ArrayControls)-1].TextColor:= cColor;
   ArrayControls[Length(ArrayControls)-1].BackColor:= cBcolor;
   ArrayControls[Length(ArrayControls)-1].CAlign   := cAlign;
   DLabel(xpos,ypos,Cvalue,CWidth,CAlign,CColor,cBColor,false);
End;

{Updates a control value}
Procedure SetContol(Name,Value:String;UPDScreen:Boolean = false);
var
  counter : integer;
Begin
  for counter := 0 to high(ArrayControls) do
    if uppercase(ArrayControls[counter].CName) = uppercase(Name) then
      begin
      ArrayControls[counter].CValue:=Value;
      break;
      end;
  DLabel(ArrayControls[counter].xpos,ArrayControls[counter].ypos,value,ArrayControls[counter].CWidth,
         ArrayControls[counter].CAlign,ArrayControls[counter].TextColor,ArrayControls[counter].BackColor,false);
  if UPDScreen then UpdateScreen(true);
End;

{$ENDREGION}

INITIALIZATION
  case
    GetTextCodePage(Output) of 932,936,949,950,951: LockBorder := true;
  end;
  InitVideo;
  InitKeyBoard;
  ScreenWidth := 80;
  ScreenHeight := 25;
  Setlength(Borders,4);
  {               ┌   ─   ┬   ┐   │   ┤   ┘   ┴   └   ├   }
  Borders[0] := #218#196#194#191#179#180#217#193#192#195;
  Borders[1] := #201#205#203#187#186#185#188#202#200#204;
  Borders[2] := #219#219#219#219#219#219#219#219#219#219;
  Borders[3] := #043#045#043#043#124#043#043#043#043#043;
  SetBorder(bdSingle);
  ClearConsole;
  SLConsole := TStringList.Create;
  SetLength(ArrayControls,0);

FINALIZATION
  DoneKeyBoard;
  DoneVideo;
  SLConsole.Free;

END.
