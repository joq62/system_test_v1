%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(allocate_free).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

-define(Master,"asus").
-define(MnesiaNodes,['iaas@asus']).

-define(WorkerVmIds,["30000","30001","30002","30003","30004","30005","30006","30007","30008","30009"]).


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
    setup(),
 
    ?debugMsg("Start allocate"),
    ?assertEqual(ok,allocate_free()),
    ?debugMsg("Stop allocate "),
    
      %% End application tests
    cleanup(),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
allocate_free()->
    
    ?assertMatch({error,_},
		 iaas:allocate_vm()),
    timer:sleep(2*61*1000),
    R=iaas:allocate_vm(),
    ?assertMatch({ok,_},R),
    {ok,Vm}=R,
%    io:format("Allocated ~p~n",[{?MODULE,?LINE,Vm,
%				 iaas:vm_status(allocated),
%				 iaas:vm_status(free)
%				}]),
    timer:sleep(62*1000),
    ?assertMatch({error,_},iaas:free_vm(glurk)),   
    Free=iaas:free_vm(Vm),
    ?assertMatch(ok,Free),
 %   io:format("Allocated ~p~n",[{?MODULE,?LINE,Vm,
%				 iaas:vm_status(allocated),
%				 iaas:vm_status(free)
%				}]),
    
				 
    ok.




%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->
    
    ok.

cleanup()->


    ok.


