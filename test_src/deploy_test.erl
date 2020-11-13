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

    ?debugMsg("Start test3"),
    ?assertEqual(ok,test3()),
    ?debugMsg("Stop test3"),
    
      %% End application tests
    cleanup(),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
test3()->
    {ok,DeplId}=deploy(10,20*1000,"math","1.0.0",{error,[init]}),
    io:format("DeplId= ~p~n",[{DeplId,time(),?MODULE,?LINE}]),
    [AdderVm]=if_db:sd_get("adder_service","1.0.0"),
    io:format("AdderVm = ~p~n",[{AdderVm,time(),?MODULE,?LINE}]),
    ?assertEqual(42,rpc:call(AdderVm,adder_service,add,[20,22],5000)),
    io:format("sd:read_all = ~p~n",[{if_db:sd_read_all(),time(),?MODULE,?LINE}]),
    timer:sleep(61*1000),
    ?assertEqual(ok,deployment:depricate_app(DeplId)),
    timer:sleep(1000),
  %  ?assertEqual([],if_db:sd_get("adder_service","1.0.0")),
    ?assertMatch({badrpc,_},rpc:call(AdderVm,adder_service,add,[20,22],5000)),
    io:format("sd:read_all = ~p~n",[{if_db:sd_read_all(),time(),?MODULE,?LINE}]),
    
      ok.

deploy(0,_,_,_,Result)->
    Result;
deploy(N,Interval,AppId,AppVsn,_Result)->
    case rpc:call(node(),deployment,deploy_app,[AppId,AppVsn],20000) of
	{error,Err}->
	  %  io:format("{error,Err}= ~p~n",[{{error,Err},time(),?MODULE,?LINE}]),
	    timer:sleep(Interval),
	    NewN=N-1,
	    NewResult={error,Err};
	{badrpc,Err}->
	 %   io:format("{badrpc,Err}= ~p~n",[{{badrpc,Err},time(),?MODULE,?LINE}]),
	    timer:sleep(Interval),
	    NewN=N-1,
	    NewResult={badrpc,Err};
	{ok,DeplId}->
	 %   io:format("ok= ~p~n",[{R,time(),?MODULE,?LINE}]),
	    NewN=0,
	    NewResult={ok,DeplId}
    end,
    deploy(NewN,Interval,AppId,AppVsn,NewResult).
	    
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
    ?assertEqual([{genesis,"control","1.0.0",{1970,1,1},{0,0,0},"asus","10250",
		   [{"control","1.0.0",'10250@asus'},{"iaas","1.0.0",'10250@asus'}],ta_bort}],if_db:deployment_read_all()),

    ?assertEqual({atomic,ok},if_db: deployment_create(deployment_id_1,
						      "math","1.0.0",
						      {2020,11,01},{07,15,30},
						      "sthlm_1","30000",
						      [{"adder_service","1.0.0"},{"divi_service","1.0.0"}],
						      stopped)),
    timer:sleep(300),
    ?assertEqual([{genesis,"control","1.0.0",{1970,1,1},{0,0,0},
		   "asus","10250",[{"control","1.0.0",'10250@asus'},
				   {"iaas","1.0.0",'10250@asus'}],
		   ta_bort},
		  {deployment_id_1,"math","1.0.0",{2020,11,1},{7,15,30},
		   "sthlm_1","30000",[{"adder_service","1.0.0"},
				      {"divi_service","1.0.0"}],stopped}],
		 if_db:deployment_read_all()),

    ?assertEqual({atomic,ok},if_db: deployment_create(deployment_id_2,
						      "math","1.0.0",
						      {2020,11,01},{07,15,30},
						      "sthlm_1","30001",
						      [{"adder_service","1.0.0"},{"divi_service","1.0.0"}],
						      stopped)),

    ?assertEqual([
		  {genesis,"control","1.0.0",{1970,1,1},{0,0,0},"asus","10250",
		   [{"control","1.0.0",'10250@asus'},{"iaas","1.0.0",'10250@asus'}],ta_bort},
		  {deployment_id_2,"math","1.0.0",{2020,11,1},{7,15,30},"sthlm_1","30001",[{"adder_service","1.0.0"},{"divi_service","1.0.0"}],stopped},
		   {deployment_id_1,"math","1.0.0",{2020,11,1},{7,15,30},"sthlm_1","30000",[{"adder_service","1.0.0"},{"divi_service","1.0.0"}],stopped}
		],
		 if_db:deployment_read_all()),
    
    ?assertEqual({atomic,ok},if_db: deployment_update_status(deployment_id_2,started)),

    ?assertEqual([
		  {genesis,"control","1.0.0",{1970,1,1},{0,0,0},"asus","10250",[{"control","1.0.0",'10250@asus'},{"iaas","1.0.0",'10250@asus'}],ta_bort},
		  {deployment_id_2,"math","1.0.0",{2020,11,1},{7,15,30},"sthlm_1","30001",[{"adder_service","1.0.0"},{"divi_service","1.0.0"}],started},
		  {deployment_id_1,"math","1.0.0",{2020,11,1},{7,15,30},"sthlm_1","30000",[{"adder_service","1.0.0"},{"divi_service","1.0.0"}],stopped}
		 ],
		 if_db:deployment_read_all()),

    ?assertEqual({atomic,ok},if_db: deployment_delete(deployment_id_1)),
    ?assertEqual({atomic,ok},if_db: deployment_delete(deployment_id_2)),
    ?assertEqual([{genesis,"control","1.0.0",{1970,1,1},{0,0,0},"asus","10250",
		   [{"control","1.0.0",'10250@asus'},{"iaas","1.0.0",'10250@asus'}],ta_bort}],
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


