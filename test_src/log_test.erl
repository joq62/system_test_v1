%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(log_test).  
   
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
 
    ?debugMsg("Start test1"),
    ?assertEqual(ok,test1()),
    ?debugMsg("Stop test1 "),

    ?debugMsg("Start test2"),
    ?assertEqual(ok,test2()),
    ?debugMsg("Stop test2"),
    
      %% End application tests
    cleanup(),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
test2()->
     ?assertEqual([{error,node2,m2,l1,error,{2020,10,1},{12,0,0},"Error 1"},
		   {error,node2,m3,l3,error,{2021,5,1},{12,0,0},"Error 2"}],
		  db_log:severity(error)),
     ?assertEqual([{info,'10250@asus',module1,line1,info,{1962,3,7},{22,18,34},"System start and intial init of mnesia"},
		  {info,'10250@asus',log_test,55,info,{2020,10,1},{13,0,0},"Event 2"},
		  {info,'10250@asus',log_test,66,info,{2020,10,1},{13,0,0},"Event 3"}],
		  db_log:severity(info)),
    
    ok.
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
% create(Vm,Module,Line,Severity,Date,Time,Text)


test1()->
    D1={2020,10,01},
    T1={13,00,00},
    ?assertEqual({atomic,ok},db_log:create(node(),?MODULE,55,info,D1,T1,"Event 2")),
    
    ?assertEqual([{info,'10250@asus',module1,line1,{1962,3,7},{22,18,34},"System start and intial init of mnesia"},
		  {info,'10250@asus',log_test,55,{2020,10,1},{13,0,0},"Event 2"}],db_log:read_all()),
    D2={2020,10,01},
    T2={13,00,00},
    ?assertEqual({atomic,ok},db_log:create(node(),?MODULE,66,info,D2,T2,"Event 3")),
    ?assertEqual([{info,'10250@asus',module1,line1,{1962,3,7},{22,18,34},"System start and intial init of mnesia"},
		  {info,'10250@asus',log_test,55,{2020,10,1},{13,0,0},"Event 2"},
		  {info,'10250@asus',log_test,66,{2020,10,1},{13,0,0},"Event 3"}],db_log:read_all()),

    ?assertEqual({atomic,ok},db_log:create(node2,m2,l1,error,{2020,10,01},{12,00,00},"Error 1")),
    ?assertEqual({atomic,ok},db_log:create(node2,m3,l3,error,{2021,05,01},{12,00,00},"Error 2")),

    ?assertEqual([{error,node2,m2,l1,{2020,10,1},{12,0,0},"Error 1"},
		  {error,node2,m3,l3,{2021,5,1},{12,0,0},"Error 2"},
		  {info,'10250@asus',module1,line1,{1962,3,7},{22,18,34},"System start and intial init of mnesia"},
		  {info,'10250@asus',log_test,55,{2020,10,1},{13,0,0},"Event 2"},
		  {info,'10250@asus',log_test,66,{2020,10,1},{13,0,0},"Event 3"}],db_log:read_all()),
    			 
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


