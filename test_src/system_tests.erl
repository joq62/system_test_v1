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
    
    ?debugMsg("Start print_status"),
    spawn(fun()->print_status() end),

 %   ?debugMsg("Start allocate and free vm"),
 %   ?assertEqual(ok,allocate_free:start()),
 %   ?debugMsg("stop allocate and free vm"),

    ?debugMsg("Start boot_test"),
    ?assertEqual(ok,boot_test:start()),
    ?debugMsg("stop boot_test"),

    ?debugMsg("Start cluster_test"),
    ?assertEqual(ok,cluster_test:start()),
    ?debugMsg("stop cluster_test"),

      %% End application tests
  
  %  cleanup(),
    ?debugMsg("------>"++atom_to_list(?MODULE)++" ENDED SUCCESSFUL ---------"),
    ok.




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
   
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
print_status()->
    timer:sleep(30*1000),
    io:format(" *************** "),
    io:format(" ~p",[{time(),?MODULE}]),
    io:format(" *************** ~n"),
    io:format("~p~n",[iaas:machine_status(all)]),
    spawn(fun()->print_status() end).

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------    

cleanup()->
    init:stop(),
    ok.
