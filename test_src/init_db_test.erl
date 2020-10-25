%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(init_db_test).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
%% --------------------------------------------------------------------

-define(Master,"asus").
-define(MnesiaNodes,['10250@asus','10250@sthlm_1']).
-define(DiscCopy,['10250@sthlm_1']).

-define(Hosts,["asus","sthlm_1"]).
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
 
    ?debugMsg("Start setup "),
    ?assertEqual(ok,setup()),
    ?debugMsg("Stop setup "),
    
    ?debugMsg("Start init_computer "),
    ?assertEqual(ok,init_computer()),
    ?debugMsg("Stop init_computer "),

    ?debugMsg("Start init_vm "),
    ?assertEqual(ok,init_vm()),
    ?debugMsg("Stop init_vm "),

    ?debugMsg("Start init_service_def "),
    ?assertEqual(ok,init_service_def()),
    ?debugMsg("Stop init_service_def "),

    ?debugMsg("Start init_passwd "),
    ?assertEqual(ok, init_passwd()),
    ?debugMsg("Stop  init_passwd "),


    ?debugMsg("Start init_deployment_spec "),
    ?assertEqual(ok, deployment_spec()),
    ?debugMsg("Stop deployment_spec "),


    ?debugMsg("Start init_deployment "),
    ?assertEqual(ok, deployment()),
    ?debugMsg("Stop deployment "),


    ?debugMsg("Start init_sd "),
    ?assertEqual(ok, sd()),
    ?debugMsg("Stop sd "),

      %% End application tests
    cleanup(),
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
sd()->
    ?assertEqual(ok,
		 db_sd:create_table(?DiscCopy)),
    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
deployment()->
    ?assertEqual(ok,
		 db_deployment:create_table(?DiscCopy)),
    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
deployment_spec()->
    ?assertEqual(ok,
		 db_deployment_spec:create_table(?DiscCopy)),
    {atomic,ok}=db_deployment_spec:create("math","1.0.0",no,[{"adder_service","1.0.0"},
							     {"multi_service","1.0.0"}]),    
    ?assertEqual([{"math","1.0.0",no,[{"adder_service","1.0.0"},
				      {"multi_service","1.0.0"}]}],
		 db_deployment_spec:read_all()),
    ok.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
init_passwd()->
     ?assertEqual(ok,
		  db_passwd:create_table(?DiscCopy)),
    {atomic,ok}=db_passwd:create("joq62","20Qazxsw20"),    
    ?assertEqual([{"joq62","20Qazxsw20"}],
		 db_passwd:read_all()),
    ok.


%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
init_service_def()->

  ?assertEqual(ok,
		 db_service_def:create_table(?DiscCopy)),

    % Create
    {atomic,ok}=db_service_def:create("dbase_service","1.0.0","joq62"),
    {atomic,ok}=db_service_def:create("node_service","1.0.0","joq62"),
    {atomic,ok}=db_service_def:create("log_service","1.0.0","joq62"),
    {atomic,ok}=db_service_def:create("catalog_service","1.0.0","joq62"),
    {atomic,ok}=db_service_def:create("orchistrate_service","1.0.0","joq62"),
    {atomic,ok}=db_service_def:create("adder_service","1.0.0","joq62"),
    {atomic,ok}=db_service_def:create("multi_service","1.0.0","joq62"),
    {atomic,ok}=db_service_def:create("divi_service","1.0.0","joq62"),

    ?assertMatch([{_,_,"joq62"},{_,_,"joq62"},{_,_,"joq62"},{_,_,"joq62"},
		  {_,_,"joq62"},{_,_,"joq62"},{_,_,"joq62"},{_,_,"joq62"}
		 ],
		 db_service_def:read_all()),
    ok.
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
init_computer()->
    
    ?assertEqual(ok,
		 db_computer:create_table(?DiscCopy)),

    % Create
    {atomic,ok}=db_computer:create("asus","pi","festum01","192.168.0.100",60100,not_available),
    {atomic,ok}=db_computer:create("sthlm_1","pi","festum01","192.168.0.110",60110,not_available),
    {atomic,ok}=db_computer:create("wrong_hostname","pi","festum01","192.168.0.110",60100,not_available),
    {atomic,ok}=db_computer:create("wrong_ipaddr","pi","festum01","25.168.0.110",60100,not_available),
    {atomic,ok}=db_computer:create("wrong_userid","glurk","festum01","192.168.0.110",60100,not_available),
    {atomic,ok}=db_computer:create("wrong_passwd","pi","glurk","192.168.0.110",60100,not_available),
    {atomic,ok}=db_computer:create("wrong_port","pi","festum01","192.168.0.110",2323,not_available),

    ?assertMatch([{_,_,_,_,_,not_available},
		  {_,_,_,_,_,not_available},
		  {_,_,_,_,_,not_available},
		  {_,_,_,_,_,not_available},
		  {_,_,_,_,_,not_available},
		  {_,_,_,_,_,not_available},
		  {_,_,_,_,_,not_available}
		 ],
		 db_computer:read_all()),
    ok.
    
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
init_vm()->
    
    ?assertEqual(ok,
		 db_vm:create_table(?DiscCopy)),
    % Create
    db_vm:create(list_to_atom("10250"++"@"++"asus"),"asus","10250",controller,running),
    db_vm:create(list_to_atom("10250"++"@"++"sthlm_1"),"sthlm_1","10250",controller,not_available),
    [db_vm:create(list_to_atom(VmId++"@"++HostId),HostId,VmId,worker,not_available)||HostId<-?Hosts,VmId<-?WorkerVmIds],

    ?assertEqual([{'30009@asus',"asus","30009",worker,not_available},{'30008@asus',"asus","30008",worker,not_available},
		  {'30007@asus',"asus","30007",worker,not_available},{'30006@asus',"asus","30006",worker,not_available},
		  {'30005@asus',"asus","30005",worker,not_available},{'30004@asus',"asus","30004",worker,not_available},
		  {'30003@asus',"asus","30003",worker,not_available},{'30002@asus',"asus","30002",worker,not_available},
		  {'30001@asus',"asus","30001",worker,not_available},{'30000@asus',"asus","30000",worker,not_available},
		  {'30009@sthlm_1',"sthlm_1","30009",worker,not_available},{'30008@sthlm_1',"sthlm_1","30008",worker,not_available},
		  {'30007@sthlm_1',"sthlm_1","30007",worker,not_available},{'30006@sthlm_1',"sthlm_1","30006",worker,not_available},
		  {'30005@sthlm_1',"sthlm_1","30005",worker,not_available},{'30004@sthlm_1',"sthlm_1","30004",worker,not_available},
		  {'30003@sthlm_1',"sthlm_1","30003",worker,not_available},{'30002@sthlm_1',"sthlm_1","30002",worker,not_available},
		  {'30001@sthlm_1',"sthlm_1","30001",worker,not_available},{'30000@sthlm_1',"sthlm_1","30000",worker,not_available},
		  {'10250@sthlm_1',"sthlm_1","10250",controller,not_available},{'10250@asus',"asus","10250",controller,running}],
		  db_vm:read_all()),
		 
    ok.
    
 

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
setup()->

    [rpc:call(Vm,os,cmd,["rm -rf Mn*"])||Vm<-?MnesiaNodes],
    [rpc:call(Node,application,stop,[mnesia])||Node<-?MnesiaNodes], 
    io:format("~p~n",[{?MODULE,?LINE,mnesia:create_schema(?MnesiaNodes)}]),
    [rpc:call(Node,application,start,[mnesia])||Node<-?MnesiaNodes],
    ok.

cleanup()->


    ok.


