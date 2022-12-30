program popwnet;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  Classes, sysutils, nosodebug, Noso_TUI, popwnetunit, nososettings, NosoTime,
  nosocrypto, nosogeneral, nosoconsensus
  { you can add units after this };

{$REGION StartApp}

Procedure StartApp;
Begin
  Randomize;
  if not fileExists('ntps.txt') then SaveTextToDisk('ntps.txt',DefNTPs);
  DefNtps := LoadTextFromDisk('ntps.txt');
  Toconsole('NTP servers loaded');
  if not fileExists('nodes.txt') then SaveTextToDisk('nodes.txt',DefNodes);
  DefNodes := LoadTextFromDisk('nodes.txt');
  Toconsole('Mainnet nodes loaded');

  if not fileexists('capedips.dat') then SaveTextToDisk('capedips.dat','');
  LoadCapedIPs;

  ToConsole('Synchronizing time...');
  GetTimeOffset(DefNTPs);
  ToConsole('Time synchronized with : '+NosoT_LastServer);
  ToConsole('Retrieving mainnet consensus...');
  GetConsensus(defnodes);
  ToConsole('Completed!');
End;

{$ENDREGION}

{$REGION Screen initialization}

Procedure UpdateClock();
const
  LastTime : int64 = 0;
Begin
  if UTCTime <> LastTime then
    begin
    LastTime := UTCTime;
    SetContol('blockage',BlockAge.ToString,true);
    end;
End;

Procedure InitScreen();
Begin
  SetCursorMode(curhide);
  Cls(1,1,80,25);
  DWindow(1,1,80,10,'PoPWNet '+AppVersion,white,blue);
  DWindow(1,10,80,24,'Console',white,blue);
  SetConsole(2,11,79,23,white,black);
  VertLine(26,1,10,white,blue,true);
  VertLine(53,1,10,white,blue,true);

  {left panel}
  DLabel(3,2,GetSetStr('poolname'),22,AlCenter,green,Black,False);
  DLabel(3,3,GetSetStr('poolhost'),22,AlCenter,green,Black,False);
  Dlabel(3,4,GetSetStr('pooladdress'),22,AlLeft,white,black,false);
  CreateControl('addbalance',Int2curr(0),3,5,22,green,white,alright);
  TextOut(3,6,'Port',brown,black,true);
    DLabel(15,6,GetSetStr('poolport'),10,AlRight,yellow,Black,true);
  TextOut(3,7,'Fee',brown,black,true);
    DLabel(15,7,GetSetStr('poolfee'),10,AlRight,yellow,Black,true);
  TextOut(3,8,'Interval',brown,black,true);
    DLabel(15,8,GetSetStr('poolinterval'),10,AlRight,yellow,Black,true);
  TextOut(3,9,'Donation',brown,black,true);
    DLabel(15,9,GetSetStr('pooldonation'),10,AlRight,yellow,Black,true);

  {center panel}
  TextOut(28,2,'Block',brown,black,true);
    CreateControl('block','0',42,2,10,green,black,alright);
  TextOut(28,3,'Age',brown,black,true);
    CreateControl('blockage','0',42,3,10,green,black,alright);
  TextOut(28,4,'Sync',brown,black,true);
    CreateControl('sync','0',42,4,10,green,black,alright);
  TextOut(28,5,'Dripers',brown,black,true);

  {right panel}
  TextOut(55,2,'Dripers',brown,black,true);
  TextOut(55,3,'Bad IPs',brown,black,true);

  {Bottom bar}
  Dlabel(1,25,'Alt+X Exit',14,alCenter,white,red,true);
End;

{$ENDREGION}

Procedure CloseApp(ExitMessage:string='');
Begin
  Cls(1,1,80,25);
  if ExitMessage<> '' then
    begin
    writeln(ExitMessage);
    writeln('Press enter to close');
    Readln();
    end;
End;

BEGIN {APP START}
  InitializeSettings;
  InitScreen;
  RunInitialVerification;
  StartApp;
  SetContol('block',consensus[2],true);
  SetContol('sync',consensus[0],true);
  Repeat
    UpdateClock;
    keycode := KeyPressedCode;
    if keycode <>0 then TextOut(1,1,keycode.ToString,white,black,true);
    if Keycode = 11520 then FinishApp := true;
    if keycode = 15104 then ToConsole('NewLine:'+myCOnsole.Height.ToString);
    if keycode = 18432 then ConsoleScrollUp(1);
    if keycode = 18688 then ConsoleScrollUp(MyConsole.Height);
    if keycode = 18176 then ConsoleScrollUp(999999);
    if keycode = 20480 then ConsoleScrollDown(1);
    if keycode = 20736 then ConsoleScrollDown(MyConsole.Height);
    if keycode = 20224 then ConsoleScrollDown(999999);
    sleep(1);
  until FinishApp;
  CloseApp;
END. {END APP}


