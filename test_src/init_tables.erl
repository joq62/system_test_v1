%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(init_tables). 
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").

%%---------------------------------------------------------------------
%% Records for test
%%
-define(InitFile,"./test_src/table_info.hrl").

%% --------------------------------------------------------------------

-export([start/0]).

%% ====================================================================
%% External functions
%% ====================================================================
init_table()->
    {ok,Info}=file:consult(?InitFile),
    dbase:init_table_info(Info),
   
    ?assertEqual(["wrong_port","asus","wrong_hostname",
		  "sthlm_1","wrong_ipaddr","wrong_passwd",
		  "wrong_userid"],
		 mnesia:dirty_all_keys(computer)),
    ?assertEqual([],
		 mnesia:dirty_all_keys(deployment)),
    ?assertEqual(["math"],
		 mnesia:dirty_all_keys(deployment_spec)),
    ?assertEqual(["joq62"],
		 mnesia:dirty_all_keys(passwd)),
    ?assertEqual([],
		 mnesia:dirty_all_keys(sd)),
    ?assertEqual(["adder_service","divi_service","multi_service"],
		 mnesia:dirty_all_keys(service_def)),
    ?assertEqual(['30009@asus','30008@asus','30007@asus','30006@asus','30005@asus',
		  '30004@asus','30003@asus','30002@asus','30001@asus','30000@asus',
		  '30009@sthlm_1','30008@sthlm_1','30007@sthlm_1','30006@sthlm_1','30005@sthlm_1',
		  '30004@sthlm_1','30003@sthlm_1','30002@sthlm_1','30001@sthlm_1','30000@sthlm_1',
		  '10250@sthlm_1','10250@asus'],
		 mnesia:dirty_all_keys(vm)),
    ok.


% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    %initiate table 
    ?assertEqual(ok,init_table()),
    

    ok.
