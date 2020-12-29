%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Create1d : 10 dec 2012
%%% -------------------------------------------------------------------
-module(boot_test). 
    
%% --------------------------------------------------------------------
%% Include files

-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Definitions
-define(ClusterConfigDir,"cluster_config").
-define(ClusterConfigFileName,"cluster_info.hrl").
-define(ServiceSpecsDir,"service_specs").
-define(AppSpecsDir,"app_specs").
-define(GitUser,"joq62").
-define(GitPassWd,"20Qazxsw20").
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% External exports
-export([start/0]).

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

    ?debugMsg("Start load_status"),
    ?assertEqual(ok,load_status()),
    ?debugMsg("stop load_status"),
 
    ?debugMsg("Start load_specs"),
    ?assertEqual(ok,load_specs()),
    ?debugMsg("stop load_specs"),

    ?debugMsg("Start start_servers"),
    ?assertEqual(ok,start_servers()),
    ?debugMsg("stop start_servers"),

    

    ?assertEqual(ok,cleanup()),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start_servers()->
    ?assertEqual(ok,start_server("server_a_100.app_spec")),
    ?assertEqual(ok,start_server("server_b_100.app_spec")),
    ?assertEqual(ok,start_server("server_c_100.app_spec")),
    ok.
    
start_server(AppSpec)->
    Result = case sys_test_deployment:create_application(AppSpec) of
		 {ok,AppSpec,HostId,VmId,Vm}->
		     io:format("{ok,AppSpec,HostId,VmId,Vm} ~p~n",[{ok,AppSpec,HostId,VmId,Vm}]),
		     ok;
		 Reason ->
		     io:format("Reason ~p~n",[Reason]),
		     Reason
	     end,
    Result.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
load_specs()->
    _AppSpecLoad=sys_test_deployment:load_app_specs(?AppSpecsDir,?GitUser,?GitPassWd),
    
    ?assertMatch([{"calc_100.app_spec",_,_,_},
		  {"server_c_100.app_spec",_,_,_},
		  {"server_a_100.app_spec",_,_,_},
		  {"server_b_100.app_spec",_,_,_},
		  {"test1_100.app_spec",_,_,_}],
		 sys_test_deployment:read_app_specs()),
    
    _ServiceSpecLoad=sys_test_deployment:load_service_specs(?ServiceSpecsDir,?GitUser,?GitPassWd),
    ?assertMatch([{"multi_100.service_spec",_,_,_,_},
		  {"server_100.service_spec",_,_,_,_},
		  {"adder_100.service_spec",_,_,_,_},
		  {"divi_100.service_spec",_,_,_,_},
		  {"common_100.service_spec",_,_,_,_},
		  {"dbase_100.service_spec",_,_,_,_}],sys_test_deployment:read_service_specs()),
    
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
load_status()->
    StatusServers=sys_test_machine:status(all),
    ok=sys_test_machine:update_status(StatusServers),
    ?assertEqual([{running,["c2","c1","c0"]},{not_available,[]}],sys_test_machine:read_status(all)),
    
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
    ssh:start(),
    ?assertEqual(ok,clone_start("common")),
    ?assertEqual(ok,clone_start("dbase")),
    preload_dbase(?ClusterConfigDir,?ClusterConfigFileName,?GitUser,?GitPassWd),
    % check if server has started dbase
    ?assertMatch([{"c2",_,_,"192.168.0.202",22,not_available},
		  {"c1",_,_,"192.168.0.201",22,not_available},
		  {"c0",_,_,"192.168.0.200",22,not_available}],
		 db_server:read_all()),
    ?assertMatch([{_,_}],
		 db_passwd:read_all()),

    
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
preload_dbase(ClusterConfigDir,ClusterConfigFileName,GitUser,GitPassWd)->
 %% Get initial configuration
    os:cmd("rm -rf "++ClusterConfigDir),
    GitCmd="git clone https://"++GitUser++":"++GitPassWd++"@github.com/"++GitUser++"/"++ClusterConfigDir++".git",
    os:cmd(GitCmd),
    ConfigFilePath=filename:join([".",ClusterConfigDir,ClusterConfigFileName]),
    {ok,Info}=file:consult(ConfigFilePath),
    rpc:call(node(),dbase,init_table_info,[Info]).


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
clone_start(ServiceId)->
    os:cmd("rm -rf "++ServiceId),
    os:cmd("git clone https://"++?GitUser++":"++?GitPassWd++"@github.com/"++?GitUser++"/"++ServiceId++".git"),
    ?assertEqual(true,code:add_path(ServiceId++"/ebin")),
    ?assertEqual(ok,application:start(list_to_atom(ServiceId))),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

cleanup()->

    ok.
