unit nosoconsensus;

{
nosoconsensus 1.0
December 28th, 2022
Noso Unit to get a consensus
Requires: nosogeneral
}

{$mode ObjFPC}{$H+}


interface

uses
  Classes, SysUtils, strutils, nosogeneral;

Type

  TThreadNodeStatus = class(TThread)
    private
      Slot: Integer;
    protected
      procedure Execute; override;
    public
      constructor Create(const CreatePaused: Boolean;TSlot:Integer);
    end;

  TConsensus = array of string;

  TNodeConsensus = record
    host  : string;
    port  : integer;
    Data  : string;
    end;

  TConsensusData = record
    Value : string;
    count : integer;
    end;

Function GetConsensus(NodesList:string = ''):TConsensus;

var
  Consensus : TConsensus;
  NodesArray    : array of TNodeConsensus;

IMPLEMENTATION

var
  CSNodesArray  : TRTLCriticalSection;
  OpenThreads   : Integer;
  ReachedNodes  : integer;
  CSOpenThreads : TRTLCriticalSection;


Procedure DecOpenThreads(Reached : boolean);
Begin
  EnterCriticalSection(CSOpenThreads);
  Dec(OpenThreads);
  if reached then Inc(ReachedNodes);
  LeaveCriticalSection(CSOpenThreads);
End;

Function OpenThreadsValue():integer;
Begin
  EnterCriticalSection(CSOpenThreads);
  Result := OpenThreads;
  LeaveCriticalSection(CSOpenThreads);
End;

Function GetNodeIndex(index:integer):TNodeConsensus;
Begin
  EnterCriticalSection(CSNodesArray);
  Result := NodesArray[index];
  LeaveCriticalSection(CSNodesArray);
End;

{$REGION Thread consulting node}

Constructor TThreadNodeStatus.Create(const CreatePaused: Boolean; TSlot:Integer);
Begin
  inherited Create(CreatePaused);
  Slot := TSlot;
  FreeOnTerminate := True;
End;

Procedure TThreadNodeStatus.Execute;
var
  ThisNode   : TNodeConsensus;
  ReadedLine : string;
  Reached    : boolean = false;
Begin
  ThisNode := GetNodeIndex(slot);
  ReadedLine := RequestLineToPeer(ThisNode.host,ThisNode.port,'NODESTATUS');
  if copy(ReadedLine,1,10) = 'NODESTATUS' then
    begin
    ThisNode.Data:= ReadedLine;
    reached := true;
    end
  else ThisNode.Data:= '';
  EnterCriticalSection(CSNodesArray);
  NodesArray[slot] := ThisNode;
  LeaveCriticalSection(CSNodesArray);
  DecOpenThreads(Reached);
End;

{$ENDREGION}

{Set the values for the array of nodes}
Procedure SetNodesArray(NodesList:string);
var
  counter : integer;
  MyArray : array of string;
Begin
  setlength(NodesArray,0);
  NodesList := Trim(StringReplace(NodesList,':',' ',[rfReplaceAll, rfIgnoreCase]));
  MyArray := SplitString(NodesList,' ');
  EnterCriticalSection(CSNodesArray);
  for counter := 0 to high(MyArray) do
    begin
    MyArray[counter] := StringReplace(MyArray[counter],';',' ',[rfReplaceAll, rfIgnoreCase]);
    Setlength(NodesArray,length(NodesArray)+1);
    NodesArray[length(NodesArray)-1].host := Parameter(MyArray[counter],0) ;
    NodesArray[length(NodesArray)-1].port := StrToIntDef(Parameter(MyArray[counter],1),8080);
    NodesArray[length(NodesArray)-1].data := '';
    end;
  LeaveCriticalSection(CSNodesArray);
End;

Function GetConsensus(NodesList:string = ''):TConsensus;
var
  counter     : integer;
  ParamNumber : integer = 1;
  ThisThread  : TThreadNodeStatus;
  isFinished  : boolean = false;
  ArrayCon    : array of TConsensusData;
  ThisHigh    : string;

  Procedure AddValue(Tvalue:String);
  var
    counter   : integer;
    ThisItem  : TConsensusData;
  Begin
    for counter := 0 to length(ArrayCon)-1 do
      begin
      if Tvalue = ArrayCon[counter].Value then
        begin
        ArrayCon[counter].count+=1;
        Exit;
        end;
      end;
  ThisItem.Value:=Tvalue;
  ThisItem.count:=1;
  Insert(ThisITem,ArrayCon,length(ArrayCon));
  End;

  Function GetHighest():string;
  var
    maximum : integer = 0;
    counter : integer;
    MaxIndex : integer = 0;
  Begin
    result := '';
    if length(ArrayCon) > 0 then
      begin
      for counter := 0 to high(ArrayCon) do
        begin
        if ArrayCon[counter].count> maximum then
          begin
          maximum := ArrayCon[counter].count;
          MaxIndex := counter;
          end;
        end;
      result := ArrayCon[MaxIndex].Value;
      end;
  End;

Begin
  SetLength(Result,0);
  if NodesList <> '' then SetNodesArray(NodesList);
  OpenThreads := length(NodesArray);
  ReachedNodes := 0;
  for counter := 0 to high(NodesArray) do
    begin
    ThisThread := TThreadNodeStatus.Create(True,counter);
    ThisThread.FreeOnTerminate:=true;
    ThisThread.Start;
    Sleep(1);
    end;
  Repeat
    sleep(1);
  until OpenThreadsValue <= 0;
  insert(Reachednodes.ToString+'/'+length(NodesArray).tostring,result,length(Result));
  Repeat
  SetLength(ArrayCon,0);
  for counter := 0 to high(NodesArray) do
    AddValue(Parameter(NodesArray[counter].Data,paramnumber));
  ThisHigh := GetHighest;
  if thishigh = '' then isFinished := true
  else insert(ThisHigh,result,length(Result));
  Inc(ParamNumber);
  until isFinished;
  setlength(consensus,0);
  Consensus := copy(result,0,length(result));
End;

INITIALIZATION
  setlength(NodesArray,0);
  InitCriticalSection(CSNodesArray);
  InitCriticalSection(CSOpenThreads);

FINALIZATION
  DoneCriticalSection(CSNodesArray);
  DoneCriticalSection(CSOpenThreads);

END. {END UNIT}

