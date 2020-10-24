%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(system_tests). 
    
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").




%% --------------------------------------------------------------------
%% External exports
-export([start/0]).


-define(TEXTFILE,"./test_src/dbase_init.hrl").


%% ====================================================================
%% External functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function:tes cases
%% Description: List of test cases 
%% Returns: non
%% --------------------------------------------------------------------
start()->
    ?debugMsg("Test system setup"),
    system_start_test(),

%    ?debugMsg("mapreduce_test"),    
%    ?assertEqual(105,mapreduce:test()),


    ?debugMsg("control_test"),    
    ?assertEqual(ok,control_test:start()),


    ?debugMsg("iaas_test"),    
    ?assertEqual(ok,iaas_2_test:start()),

%    ?debugMsg("init_test"),    
%    ?assertEqual(ok,second_test:start()),

      %% End application tests
  
  %  cleanup(),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
system_start_test()->
 %   HostId=net_adm:localhost(),
 %   MnesiaVm=list_to_atom("10250@"++HostId),
 %   ok=application:start(dbase_service),
 %   rpc:call(MnesiaVm,dbase_service,load_textfile,[?TEXTFILE]),
 %   timer:sleep(1000),
 % receive 
%	infinity->
%	    ok
 %   end,
    ok.


% Control plane
% Kubernetes API Server 6443
% etcd 	       	      2379-2380
% kube-scheduler      10251
% kube-controller-mgr 10252

% worker nodes
% kubelet API	      10250
% pod		      30000-32767

-define(ControlVmIds,["10250","10251","10252"]).
-define(EtcdVmIds,["2381","2379","2380"]).
-define(WorkerVmIds,["30000","30001","30002","30003","30004","30005","30006","30007","30008","30009",
		   "30010","30011","30012","30013","30014","30015","30016","30017","30018","30019",
		   "30020","30021","30022","30023","30024","30025","30026","30027","30028","30029"]).

system_start()->

    AllVmIds= lists:append([?ControlVmIds,?EtcdVmIds,?WorkerVmIds]),
    clean_host(net_adm:localhost(),AllVmIds),

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


clean_host(HostId,AllVmIds)->
    
    AllVms=[list_to_atom(VmId++"@"++HostId)||VmId<-AllVmIds],
    %Stop detached vms and delete dirs
    [rpc:call(Vm,init,stop,[])||Vm<-AllVms],
    [os:cmd("rm -rf "++VmId)||VmId<-AllVmIds],
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
    io:format("~p~n",[{?MODULE,?LINE,VmId,R1,R2}]),
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



cleanup()->
  %  AllVmIds= lists:append([?ControlVmIds,?EtcdVmIds,?WorkerVmIds]),
  %  clean_host(net_adm:localhost(),AllVmIds),
    MyNode=node(),
    [rpc:call(Node,init,stop,[])||Node<-[MyNode]],
    init:stop(),
    ok.
