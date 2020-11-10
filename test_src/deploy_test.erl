%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(deploy_test).  
   
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
    MathDeploymentInfo=if_db:deployment_spec_read("math","1.0.0"),
    ?assertEqual([{"math","1.0.0",no_restrictions,
		   [{"adder_service","1.0.0"},{"divi_service","1.0.0"}]}],MathDeploymentInfo),

    Glurk=if_db:deployment_spec_read("glurk","1.0.0"),
    ?assertEqual([],Glurk),
   

    ok.
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
% create(Vm,Module,Line,Severity,Date,Time,Text)


test1()->
    ?assertEqual([],if_db:deployment_read_all()),

    ?assertEqual({atomic,ok},if_db: deployment_create(deployment_id_1,
						      "math","1.0.0",
						      {2020,11,01},{07,15,30},
						      "sthlm_1","30000",
						      [{"adder_service","1.0.0"},{"divi_service","1.0.0"}],
						      stopped)),
    timer:sleep(300),
    ?assertEqual([{deployment_id_1,
		   "math","1.0.0",
		   {2020,11,1},{7,15,30},
		   "sthlm_1","30000",
		   [{"adder_service","1.0.0"},{"divi_service","1.0.0"}],
		   stopped}],
		 if_db:deployment_read_all()),

    ?assertEqual({atomic,ok},if_db: deployment_create(deployment_id_2,
						      "math","1.0.0",
						      {2020,11,01},{07,15,30},
						      "sthlm_1","30001",
						      [{"adder_service","1.0.0"},{"divi_service","1.0.0"}],
						      stopped)),

    ?assertEqual([
		  {deployment_id_2,"math","1.0.0",{2020,11,1},{7,15,30},"sthlm_1","30001",
		   [{"adder_service","1.0.0"},{"divi_service","1.0.0"}],stopped},
		  {deployment_id_1,"math","1.0.0",{2020,11,1},{7,15,30},"sthlm_1","30000",
		   [{"adder_service","1.0.0"},{"divi_service","1.0.0"}],stopped}
		 ],
		 if_db:deployment_read_all()),
    
    ?assertEqual({atomic,ok},if_db: deployment_update_status(deployment_id_2,started)),

    ?assertEqual([{deployment_id_2,"math","1.0.0",{2020,11,1},{7,15,30},"sthlm_1","30001",[{"adder_service","1.0.0"},{"divi_service","1.0.0"}],started},
		  {deployment_id_1,"math","1.0.0",{2020,11,1},{7,15,30},"sthlm_1","30000",[{"adder_service","1.0.0"},{"divi_service","1.0.0"}],stopped}
		 ],
		 if_db:deployment_read_all()),

    ?assertEqual({atomic,ok},if_db: deployment_delete(deployment_id_1)),
    ?assertEqual({atomic,ok},if_db: deployment_delete(deployment_id_2)),
    ?assertEqual([],
		 if_db:deployment_read_all()),
    
    
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


