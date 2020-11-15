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
-define(DbaseVmId,"10250").
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
    ?debugMsg("Start setup"),
    ?assertEqual(ok,setup()),
    ?debugMsg("stop setup"),

 %   ?debugMsg("Start allocate and free vm"),
 %   ?assertEqual(ok,allocate_free:start()),
 %   ?debugMsg("stop allocate and free vm"),

    ?debugMsg("Start sd test"),
    ?assertEqual(ok,sd_test:start()),
    ?debugMsg("stop sd test"),

    ?debugMsg("Start log test"),
    ?assertEqual(ok,log_test:start()),
    ?debugMsg("stop log test"),

    ?debugMsg("Start deploy test"),
    ?assertEqual(ok,deploy_test:start()),
    ?debugMsg("stop deploy test"),
  
 %   ?debugMsg("Start remote_node"),    
 %   remote_node(),
 %   ?debugMsg("Stop remote_node"),
 
%    ?debugMsg("Start init_db_test"),    
 %   init_db_test:start(),
 %   ?debugMsg("Stop init_db_test"), 

 %   ?debugMsg("Start system_start_test"),    
 %   system_start_test(),
 %   ?debugMsg("Stop system_start_test"), 

%    ?debugMsg("print_status()"),    
%    spawn(fun()->print_status() end),


%    ?debugMsg("deployment_test"),    
%    ?assertEqual(ok,deployment_test:start()),


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
setup()->
    rpc:call('10250@sthlm_1',init,stop,[]),
    % Start and init local mnesia
  
    ?assertEqual(ok,application:start(dbase)), 
    ?assertMatch({pong,_,_},dbase:ping()),
    ?assertEqual(ok,init_tables:start()),
    timer:sleep(500),
    ?assertEqual(ok,application:start(iaas)), 
    ?assertMatch({pong,_,_},iaas:ping()),
    ?assertEqual(ok,application:start(control)), 
    ?assertMatch({pong,_,_},control:ping()),
  %  spawn(fun()->
%		  print_status() end),
    


    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
print_status()->
     timer:sleep(10*1000),
     io:format(" *************** "),
    io:format(" ~p",[{time()}]),
    io:format(" *************** ~n"),
    
    io:format("Services = : ~p~n",[if_db:sd_read_all()]),

    io:format("RunningComputers : ~p~n",[iaas:computer_status(running)]),
    io:format("AvailableComputers : ~p~n",[iaas:computer_status(available)]),
    io:format( "NotAvailableComputers : ~p~n",[iaas:computer_status(not_available)]),

    io:format("Allocated Vms : ~p~n",[iaas:vm_status(allocated)]),
    io:format("Free Vms : ~p~n",[iaas:vm_status(free)]),
    io:format( "NotAvailable Vms : ~p~n",[iaas:vm_status(not_available)]),

    


  %  io:format( "Candidates : ~p~n",[rpc:call(DbaseVm,db_vm,read_all,[])]),  


    timer:sleep(50*1000),
    print_status().




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
-define(IpAddr,"192.168.0.110").
-define(Port,60110).
-define(User,"pi").
-define(PassWd,"festum01").
-define(VmId,"10250").
-define(HostId,"sthlm_1").
-define(TimeOut,3000).

remote_node()->
    ssh:start(),
    ok=my_ssh:ssh_send(?IpAddr,?Port,?User,?PassWd,"erl -sname "++?VmId++" -setcookie abc -detached ",2*?TimeOut),
    Vm=list_to_atom(?VmId++"@"++?HostId),
    R=check_started(500,Vm,10,{error,[Vm]}),
    rpc:call(Vm,mnesia,start,[]),
    ok.

system_start_test()->

    io:format("~p~n",[{?MODULE,?LINE,[computer:clean_vms(?WorkerVmIds,HostId)||HostId<-?Hosts]}]),
    io:format("~p~n",[{?MODULE,?LINE,[computer:start_vms(?WorkerVmIds,HostId)||HostId<-?Hosts]}]),

    application:start(iaas),
    ok.

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
