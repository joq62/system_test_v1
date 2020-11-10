%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(sd_test).  
   
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
    
      %% End application tests
    cleanup(),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
test2()->
  

    
    
    ok.
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
% create(Vm,Module,Line,Severity,Date,Time,Text)


test1()->
    
    ?assertEqual([{"control","1.0.0","asus","10250",'10250@asus'},
		  {"iaas","1.0.0","asus","10250",'10250@asus'}],if_db:sd_read_all()),
    ?assertEqual({atomic,ok},if_db:sd_create("glurk","1.2.3","asus","30003",'30003@asus')),
    ?assertEqual([{"control","1.0.0","asus","10250",'10250@asus'},
		   {"glurk","1.2.3","asus","30003",'30003@asus'},
		   {"iaas","1.0.0","asus","10250",'10250@asus'}],
		 if_db:sd_read_all()),
    ?assertEqual({atomic,ok},if_db:sd_delete("glurk","1.2.3",'30003@asus')),
    ?assertEqual([{"control","1.0.0","asus","10250",'10250@asus'},
		  {"iaas","1.0.0","asus","10250",'10250@asus'}],
		 if_db:sd_read_all()),

    ?assertEqual([{"control","1.0.0","asus","10250",'10250@asus'}],
		 if_db:sd_read("control")),

    ?assertEqual(['10250@asus'],
		 if_db:sd_get("control")),
    
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


