unit popwnetunit;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, nososettings, nosocrypto, nosotime;

Type
  TCapedIP = record
    Ip    : string;
    Cap   : integer;
    block : integer;
    end;

Procedure InitializeSettings();
Function RunInitialVerification():string;

{Capped}
Function LoadCapedIPs:Boolean ;

const
  AppVersion = '1.0';

var
  FinishApp   : boolean = false;
  KeyCode     : integer;
  DefNodes    : string = '47.87.181.190;8080:47.87.178.205;8080:81.22.38.101;8080:66.151.117.247;8080:47.87.180.219;8080:47.87.137.96;8080:192.3.85.196;8080:192.3.254.186;8080:198.46.218.125;8080:63.227.69.162;8080:101.100.138.125;8080:';
  DefNTPs     : string = 'ts2.aco.net:hora.roa.es:time.esa.int:time.stdtime.gov.tw:stratum-1.sjc02.svwh.net:ntp1.sp.se:1.de.pool.ntp.org:ntps1.pads.ufrj.br:utcnist2.colorado.edu:tick.usask.ca:ntp1.st.keio.ac.jp:';

  {Caped IPs}
  ArrCapped    : array of TCapedIP;
  CS_ArrCapped : TRTLCriticalSection;

IMPLEMENTATION

{$REGION Init}

Procedure InitializeSettings();
Begin
  SetSettingsFilename('popwnet.conf');
  InitSetting('pubkey','','The public key of the pool address');
  InitSetting('privkey','','The private key of the pool address');
  InitSetting('pooladdress','','Pool noso address hash');
  InitSetting('poolhost','192.168.1.1','Pool public host');
  InitSetting('poolname','mypool','Pool name');
  InitSetting('poolport','8082','Pool server port');
  InitSetting('poolfee','200','Pool fee');
  InitSetting('poolinterval','48','Pool payment fee');
  InitSetting('pooldonation','5','Pool percentage for donation');
  If not fileexists(SettingsFilename) then SaveSettings();
  LoadSettings();
End;

Function RunInitialVerification():string;
Begin
  result := '';
  if not KeysMatch(GetSetStr('pubkey'),GetSetStr('privkey')) then
    Exit('Keys do not match');
  if GetAddressFromPublicKey(GetSetStr('pubkey')) <> GetSetStr('pooladdress') then
    Exit('Pool address do not match public key');
End;

{$ENDREGION}

{$REGION Capped}

Function LoadCapedIPs:Boolean;
Begin

End;

{$ENDREGION}

INITIALIZATION
  InitCriticalSection(CS_ArrCapped);

FINALIZATION
  DoneCriticalSection(CS_ArrCapped);

END.

