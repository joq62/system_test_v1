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

    ?assertEqual(ok,cleanup()),

    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
    ?assertEqual(ok,clone_start("common")),
     ?assertEqual(ok,clone_start("dbase")),
    ?assertEqual(ok,clone_start("server")),
    server:preload_dbase(?ClusterConfigDir,?ClusterConfigFileName,?GitUser,?GitPassWd),
    ?assertEqual(ok,clone_start("iaas")),

    % check if server has started dbase
    ?assertMatch([{"c2",_,_,"192.168.0.202",22,not_available},
		  {"c1",_,_,"192.168.0.201",22,not_available},
		  {"c0",_,_,"192.168.0.200",22,not_available}],
		 if_db:server_read_all()),
    ?assertMatch([{_,_}],
		 if_db:passwd_read_all()),

    ?assertMatch([{iaas,_,_},
		  {ssh,_,_},
		  {public_key,_,_},
		  {asn1,_,_},
		  {crypto,_,_},
		  {server,_,_},
		  {dbase,_,_},
		  {mnesia,_,_},
		  {common,_,_},
		  {stdlib,_,_},
		  {kernel,_,_}],
		 application:which_applications()),
    
    ok.

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
