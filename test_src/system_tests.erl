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

% Control plane
% Kubernetes API Server 6443
% etcd 	       	      2379-2380
% kube-scheduler      10251
% kube-controller-mgr 10252

% worker nodes
% kubelet API	      10250
% pod		      30000-32767
-define(Hosts,["asus","sthlm_1"]).
-define(ControlVmIds,["10250","10251","10252"]).
-define(EtcdVmIds,["2381","2379","2380"]).
-define(WorkerVmIds,["30000","30001","30002","30003","30004","30005","30006","30007","30008","30009"]).



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

    ?debugMsg("print_status()"),    
    spawn(fun()->print_status() end),


    ?debugMsg("deployment_test"),    
    ?assertEqual(ok,deployment_test:start()),


  %  ?debugMsg("control_test"),    
  %  ?assertEqual(ok,control_test:start()),


  %  ?debugMsg("iaas_test"),    
  %  ?assertEqual(ok,iaas_2_test:start()),

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
print_status()->
     io:format(" *************** "),
    io:format(" ~p",[{time()}]),
    io:format(" *************** ~n"),
 
    io:format("RunningComputers : ~p~n",[iaas:computer_status(running)]),
    io:format("AvailableComputers : ~p~n",[iaas:computer_status(available)]),
    io:format( "NotAvailableComputers : ~p~n",[iaas:computer_status(not_available)]),

    io:format("RunningVms : ~p~n",[iaas:vm_status(running)]),
    io:format("AvailableVms : ~p~n",[iaas:vm_status(available)]),

    io:format( "NotAvailableVms : ~p~n",[iaas:vm_status(not_available)]),
    io:format( "Candidates : ~p~n",[iaas:get_all_vms()]),  


    timer:sleep(60*1000),
    print_status().




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
system_start_test()->
    ssh:start(),
    ok=application:start(dbase_service),
    dbase_service:load_textfile(?TEXTFILE),
    timer:sleep(1000),

%
    
    io:format("~p~n",[{?MODULE,?LINE,[computer:clean_vms(?WorkerVmIds,HostId)||HostId<-?Hosts]}]),
    io:format("~p~n",[{?MODULE,?LINE,[computer:start_vms(?WorkerVmIds,HostId)||HostId<-?Hosts]}]),

    ok=application:start(iaas),
    ok=application:start(sd),
    ok=application:start(control),
    ok.



cleanup()->
  %  AllVmIds= lists:append([?ControlVmIds,?EtcdVmIds,?WorkerVmIds]),
  %  clean_host(net_adm:localhost(),AllVmIds),
    MyNode=node(),
    [rpc:call(Node,init,stop,[])||Node<-[MyNode]],
    init:stop(),
    ok.
