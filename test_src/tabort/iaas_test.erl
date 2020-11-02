%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(iaas_test). 
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").


%%---------------------------------------------------------------------
%% Records for test
%%

%% --------------------------------------------------------------------

-export([start/0]).
-define(ControlVmId,"10250").
-define(TimeOut,3000).
-define(ControlVmIds,["10250"]).
-define(EtcdVmIds,["2381","2379","2380"]).
-define(WorkerVmIds,["30000","30001","30002","30003","30004","30005","30006","30007","30008","30009"]).

%-define(WorkerVmIds,["30000","30001","30002","30003","30004","30005","30006","30007","30008","30009",
%		   "30010","30011","30012","30013","30014","30015","30016","30017","30018","30019",
%		   "30020","30021","30022","30023","30024","30025","30026","30027","30028","30029"]).

%% ====================================================================
%% External functions
%% ====================================================================
setup()->
    Vm=list_to_atom("10250@sthlm_1"),
    rpc:call(Vm,init,stop,[]),
    ssh:start(),
    ?assertEqual(ok,application:start(iaas)),
   % {atomic,ok}=db_computer:delete("glurk"),
   % {atomic,ok}=db_computer:delete("glurk2"),

   % {atomic,ok}=db_computer:create({computer,"wrong_hostname","pi","festum01","192.168.0.110",60100}),
   % {atomic,ok}=db_computer:create({computer,"wrong_ipaddr","pi","festum01","25.168.0.110",60100}),
   % {atomic,ok}=db_computer:create({computer,"wrong_port","pi","festum01","192.168.0.110",2323}),
   % {atomic,ok}=db_computer:create({computer,"wrong_userid","glurk","festum01","192.168.0.110",60100}),
   % {atomic,ok}=db_computer:create({computer,"wrong_passwd","pi","glurk","192.168.0.110",60100}),

   
    ok.

cleanup()->
  %  ?assertEqual(ok,application:stop(iaas)),
    ok.
% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    %initiate table 
    ?debugMsg("Start setup"),
    ?assertEqual(ok,setup()),
    ?debugMsg("End setup"),

    ?debugMsg("Start check_computer_status"),
    ?assertEqual(ok,check_computer_status()),
    ?debugMsg("End check_computer_status"),
    
    ?debugMsg("Start hb_check"),
    ?assertEqual(ok,hb_check()),
    ?debugMsg("End hb_check"),
    
    ?debugMsg("Start cleanup"),
    ?assertEqual(ok,cleanup()),
    ?debugMsg("End cleanup"),
    ok.







		       


% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
check_computer_status()->
    _ComputerStatus=computer:check_computers(),
%    ?assertEqual([{stopped,"glurk"},
%		  {running,"asus"},
%		  {running,"sthlm_1"}],ComputerStatus),

    ?assertEqual(["asus"],iaas:running_computers()),
    ?assertEqual(["sthlm_1"],iaas:available_computers()),
  %  ?assertEqual(60,lists:flatlength(iaas:not_available_computers())),

    ok.
    


% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
hb_check()->
    ?debugMsg("Start Update current state"),
    RunningComputers=iaas:running_computers(),
    AvailableComputers=iaas:available_computers(),
    NotAvailableComputers=iaas:not_available_computers(),
%    io:format("RunningComputers = ~p~n",[{RunningComputers, ?MODULE,?LINE}]),
%    io:format("AvailableComputers = ~p~n",[{AvailableComputers,?MODULE,?LINE}]),
%    io:format("NotAvailableComputers = ~p~n",[{NotAvailableComputers,?MODULE,?LINE}]),
    ?debugMsg("End Update current state"),

    ?debugMsg("Start clean and start Control nodes"),
    HostId="sthlm_1",
    VmId="10250",
    Vm=list_to_atom(VmId++"@"++HostId),
    ?assertEqual(ok,node_clean(HostId,VmId)),
    ResultHostVmStart=node_start(HostId,VmId),
    ?assertEqual(ok,ResultHostVmStart),
    pong=net_adm:ping(Vm),
    ?debugMsg("End clean and start Control nodes"),
    
    ?debugMsg("Start clean and start Worker nodes"),
    WorkerVms=[list_to_atom(WorkerId++"@"++HostId)||WorkerId<-?WorkerVmIds],
    ResultWorkerClean= map_clean_node(?WorkerVmIds,HostId),
    ResultWorkerStart=map_node_start(?WorkerVmIds,HostId),
    ?debugMsg("End clean and start Worker nodes"),

  %  io:format("WorkerStart = ~p~n",[{ResultWorkerStart,?MODULE,?LINE}]),
    ?debugMsg("Start mnesia on Control node"),
    ok=rpc:call(list_to_atom(?ControlVmId++"@"++HostId),mnesia,start,[]),
    ?debugMsg("End mnesia on Control node"),
    
    ok.

% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

map_node_start(VmIds,HostId)->
    F1=fun start_node/2,
    F2=fun start_node_result/3,
    L=[{HostId,VmId}||VmId<-VmIds],
    ResultNodeStart=mapreduce:start(F1,F2,[],L),
    ResultNodeStart.


start_node(Parent,{HostId,VmId})->
    StartResult=case db_computer:read(HostId) of
		    []->
			{error,[eexists,HostId]};
		    [{HostId,User,PassWd,IpAddr,Port}]->
			ControlVm=list_to_atom(?ControlVmId++"@"++HostId),
			ok=rpc:call(ControlVm,file,make_dir,[VmId]),
			[]=rpc:call(ControlVm,os,cmd,["erl -sname "++VmId++" -setcookie abc -detached "],2*?TimeOut),
			Vm=list_to_atom(VmId++"@"++HostId),
			R=check_started(500,Vm,10,{error,[Vm]}),
		%	io:format("VmId = ~p",[{VmId,?MODULE,?LINE}]),
		%	io:format(",  ~p~n",[{R,?MODULE,?LINE}]),
			R
		end,
    Parent!{start_node,StartResult}.

start_node_result(Key,Vals,_)->		
    Vals.



node_start(HostId,VmId)->
    StartResult=case db_computer:read(HostId) of
		    []->
			{error,[eexists,HostId]};
		    [{HostId,User,PassWd,IpAddr,Port}]->
			ok=my_ssh:ssh_send(IpAddr,Port,User,PassWd,"mkdir "++VmId,2*?TimeOut),
			ok=my_ssh:ssh_send(IpAddr,Port,User,PassWd,"erl -sname "++VmId++" -setcookie abc -detached ",2*?TimeOut),
			Vm=list_to_atom(VmId++"@"++HostId),
			R=check_started(500,Vm,10,{error,[Vm]}),
		%	io:format("VmId = ~p",[{VmId,?MODULE,?LINE}]),
		%	io:format(",  ~p~n",[{R,?MODULE,?LINE}]),
%			timer:sleep(500),
			R
		end,
    StartResult.

% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
map_clean_node(VmIds,HostId)->
    F1=fun clean_node/2,
    F2=fun clean_node_result/3,
    L=[{HostId,VmId}||VmId<-VmIds],
    ResultNodeStart=mapreduce:start(F1,F2,[],L),
    ResultNodeStart.

clean_node(Parent,{HostId,VmId})->
    % Read computer info 
    Result=case db_computer:read(HostId) of
	       []->
		   {error,[eexists,HostId]};
	       [{HostId,User,PassWd,IpAddr,Port}]->
						%	    ok=rpc:call(list_to_atom(?ControlVmId++"@"++HostId),
						%			file,del_dir_r,[VmId]),
		   rpc:call(list_to_atom(?ControlVmId++"@"++HostId),
			      os,cmd,["rm -rf "++VmId]),
		   R=rpc:call(list_to_atom(?ControlVmId++"@"++HostId),filelib,is_dir,[VmId]),
		   timer:sleep(300),
		   rpc:call(list_to_atom(VmId++"@"++HostId),
			    init,stop,[]),
		   timer:sleep(300),
%		   io:format("rm -rf VmId = ~p~n",[{R,VmId,?MODULE,?LINE}]),
		   {R,VmId}
    end,
    Parent!{clean_node,Result}.

clean_node_result(Key,Vals,_)->		
    Vals.

node_clean(HostId,VmId)->
    % Read computer info 
    case db_computer:read(HostId) of
	[]->
	    {error,[eexists,HostId]};
	[{HostId,User,PassWd,IpAddr,Port}]->
	    ok=my_ssh:ssh_send(IpAddr,Port,User,PassWd,"rm -rf "++VmId,2*?TimeOut)
%	    io:format("VmId = ~p",[{VmId,?MODULE,?LINE}])
	  
    end,
    ok.

%create_start(HostId,AllVmIds)->
%    AllVms=[list_to_atom(VmId++"@"++HostId)||VmId<-AllVmIds],
%    [os:cmd("mkdir "++VmId)||VmId<-AllVmIds],
%    start_vm(AllVmIds,[]),
%    R=[net_adm:ping(Vm)||Vm<-AllVms],
%    io:format("~p~n",[R]),
    

start_vm([],R)->
    R;
start_vm([VmId|T],Acc)->
    R2=os:cmd("erl -detached -setcookie abc -sname "++VmId),
    HostId=net_adm:localhost(),
    R1=check_started(100,list_to_atom(VmId++"@"++HostId),20,{error,VmId}),
%    io:format("~p~n",[{?MODULE,?LINE,VmId,R1,R2}]),
    start_vm(T,[{R1,R2}|Acc]).

check_started(_N,_Vm,_Timer,ok)->
    ok;
check_started(0,_Vm,_Timer,Result)->
    Result;
check_started(N,Vm,Timer,_Result)->
    NewResult=case net_adm:ping(Vm) of
		  pong->
		      ok;
		  Err->
		      timer:sleep(Timer),
		      {error,[Err,Vm]}
	      end,
    check_started(N-1,Vm,Timer,NewResult).













system_start()->
    
    AllVmIds= lists:append([?ControlVmIds,?EtcdVmIds,?WorkerVmIds]),
  

    % clean computer rm -rf service
    HostId=net_adm:localhost(),
    ControlVms=[list_to_atom(VmId++"@"++HostId)||VmId<-?ControlVmIds],
    EtcdVms=[list_to_atom(VmId++"@"++HostId)||VmId<-?EtcdVmIds],
    WorkerVms=[list_to_atom(VmId++"@"++HostId)||VmId<-?WorkerVmIds],
    AllVms=lists:append([ControlVms,EtcdVms,WorkerVms]),
    AllVmIds= lists:append([?ControlVmIds,?EtcdVmIds,?WorkerVmIds]),

    %Stop detached vms and delete dirs
   % [rpc:call(Vm,init,stop,[])||Vm<-AllVms],
   % [os:cmd("rm -rf "++VmId)||VmId<-AllVmIds],
    
    % create dirs and start vms
    [os:cmd("mkdir "++VmId)||VmId<-AllVmIds],
 
    start_vm(AllVmIds,[]),
    R=[net_adm:ping(Vm)||Vm<-AllVms],
    io:format("~p~n",[R]),
    
    % start dbase_service 
     io:format("~p~n",[application:start(dbase_service)]),
    
    % clone include
    % Node_service
    % clone dbase 
    % clone 
    ?assertMatch({pong,_,_},dbase_service:ping()),
    timer:sleep(500),
    ok.