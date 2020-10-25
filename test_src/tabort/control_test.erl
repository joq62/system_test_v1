%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(control_test). 
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").


%%---------------------------------------------------------------------
%% Records for test
%%

-record(service_discovery,
	{
	  id,
	  vsn,
	  vm
	}).

-record(deployment_spec,
	{
	  id,   %"etcd_0"
	  vsn,  %"1.0.0"
	  services % [{service_id,vsn,num,options}]
	}).

-record(service_def,
	{
	  id,
	  vsn,
	  source
	}).

-record(deployment,
	{
	  id,
	  vsn,
	  service_id,
	  service_vsn,
	  vm
	}).



%% --------------------------------------------------------------------

-export([start/0]).

%% ====================================================================
%% External functions
%% ====================================================================
setup()->
  %  Vm=list_to_atom("10250@sthlm_1"),
  %  rpc:call(Vm,init,stop,[]),
  %  ssh:start(),
    ?assertEqual(ok,application:start(iaas)),
   % {atomic,ok}=db_computer:delete("glurk"),
   % {atomic,ok}=db_computer:delete("glurk2"),

   % {atomic,ok}=db_computer:create({computer,"wrong_hostname","pi","festum01","192.168.0.110",60100}),
   % {atomic,ok}=db_computer:create({computer,"wrong_ipaddr","pi","festum01","25.168.0.110",60100}),
   % {atomic,ok}=db_computer:create({computer,"wrong_port","pi","festum01","192.168.0.110",2323}),
   % {atomic,ok}=db_computer:create({computer,"wrong_userid","glurk","festum01","192.168.0.110",60100}),
   % {atomic,ok}=db_computer:create({computer,"wrong_passwd","pi","glurk","192.168.0.110",60100}),

   
    ok.

cleanup()->
  %  ?assertEqual(ok,application:stop(iaas)),
    ok.
% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    %initiate table 
    ?debugMsg("Start setup"),
    ?assertEqual(ok,setup()),
    ?debugMsg("End setup"),

    ?debugMsg("db_service_def"),
    db_service_def(),
    ?debugMsg("db_service_discovery"),
    db_service_discovery_test(),
    ?debugMsg("db_deployment_spec"),
    db_deployment_spec(),
    ?debugMsg("db_deployment"),

    ?debugMsg("Start create_deployment_spec"),
    ?assertEqual(ok,create_deployment_spec()),
    ?debugMsg("End create_deployment_spec"),

%    ?debugMsg("Start loop"),
%    ?assertEqual(ok,loop(100,20000)),
 %   ?debugMsg("End loop"),
    
  %  ?debugMsg("Start hb_check"),
  %  ?assertEqual(ok,hb_check()),
 %   ?debugMsg("End hb_check"),
    
    ?debugMsg("Start cleanup"),
    ?assertEqual(ok,cleanup()),
    ?debugMsg("End cleanup"),
    ok.








% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
create_deployment_spec()->
    db_deployment_spec:create(#deployment_spec{id="calculus",vsn="1.0.0",
					       services=[{"adder_service","1.0.0",[]},
							 {"multi_service","1.0.0",[]},
							 {"divi_service","1.0.0",[]}]}),
    
    ?assertMatch([{"calculus","1.0.0",
		   [{"adder_service","1.0.0",[]},
		    {"multi_service","1.0.0",[]},
		    {"divi_service","1.0.0",[]}]}],
		 db_deployment_spec:read("calculus")),
    ok.
			      



% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
db_deployment_spec()->
    %db_deployment_spec:delete("telldus","1.0.1"),
    %db_deployment_spec:delete("math","2.0.0"),    


     ?assertMatch([{"math","1.0.0",[{"adder_service","1.0.0",[]}]}],
		 db_deployment_spec:read("math")),

    db_deployment_spec:create(#deployment_spec{id="math",vsn="1.0.1",
					       services=[{"adder_service","1.0.0",[{from,"asus"}]}]}), 

    ?assertMatch([{"math","1.0.0",[{"adder_service","1.0.0",[]}]},
		  {"math","1.0.1",[{"adder_service","1.0.0",[{from,"asus"}]}]}],
		 db_deployment_spec:read("math")),
  
    ?assertMatch([{"math","1.0.1",[{"adder_service","1.0.0",[{from,"asus"}]}]}],
%		 db_deployment_spec:read("math")),
		 db_deployment_spec:read("math","1.0.1")),


    db_deployment_spec:delete("math","1.0.1"),
    db_deployment_spec:create(#deployment_spec{id="telldus",vsn="1.0.1",
					       services=[{"tellstick_service","1.2.3",[{from,"asus"}]},
							 {"glurk","2.4.1",[{from,"asus"}]}]}), 

    ?assertMatch([{"math","1.0.0",[{"adder_service","1.0.0",[]}]},
		  {"telldus","1.0.1",[{"tellstick_service","1.2.3",[{from,"asus"}]},
				      {"glurk","2.4.1",[{from,"asus"}]}]}],db_deployment_spec:read_all()),

    db_deployment_spec:update("math","1.0.0","2.0.0",
			      [{"adder_service","1.2.0",[{from,"asus"}]}]),

    ?assertMatch([{"math","2.0.0",[{"adder_service","1.2.0",[{from,"asus"}]}]},
		  {"telldus","1.0.1",[{"tellstick_service","1.2.3",[{from,"asus"}]},
				      {"glurk","2.4.1",[{from,"asus"}]}]}],db_deployment_spec:read_all()),

    db_deployment_spec:delete("telldus","1.0.1"),
    ?assertMatch([{"math","2.0.0",[{"adder_service","1.2.0",[{from,"asus"}]}]}],db_deployment_spec:read_all()),
    db_deployment_spec:delete("telldus","1.0.1"),
    db_deployment_spec:delete("math","2.0.0"),    
    ok.
		       

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
db_deployment()->
    db_deployment:create(#deployment{id="etcd",vsn="1.0.0",
				     service_id="etcd_service",
				     service_vsn="2.3.4",
				     vm='2378@host1'}),
    ?assertMatch([{"etcd","1.0.0","etcd_service","2.3.4",'2378@host1'}],
		 db_deployment:read_all()),
    db_deployment:create(#deployment{id="etcd",vsn="1.0.0",
				     service_id="etcd_service",
				     service_vsn="2.3.4",
				     vm='2379@host1'}),
    db_deployment:create(#deployment{id="etcd",vsn="1.0.0",
				     service_id="etcd_service",
				     service_vsn="2.3.4",
				     vm='2380@host1'}),
    
    ?assertMatch([{"etcd","1.0.0","etcd_service","2.3.4",'2378@host1'},
		  {"etcd","1.0.0","etcd_service","2.3.4",'2379@host1'},
		  {"etcd","1.0.0","etcd_service","2.3.4",'2380@host1'}],
		 db_deployment:read("etcd")),


    ?assertMatch([{"etcd","1.0.0","etcd_service","2.3.4",'2378@host1'},
		  {"etcd","1.0.0","etcd_service","2.3.4",'2379@host1'},
		  {"etcd","1.0.0","etcd_service","2.3.4",'2380@host1'}],
		 db_deployment:read_all()),

    {atomic,ok}=db_deployment:delete("etcd","1.0.0","etcd_service","2.3.4",'2379@host1'),

    ?assertMatch([{"etcd","1.0.0","etcd_service","2.3.4",'2378@host1'},
		  {"etcd","1.0.0","etcd_service","2.3.4",'2380@host1'}],
		 db_deployment:read_all()),
    ok.



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
db_service_discovery_test()->
    db_service_discovery:delete("adder_service","1.0.0",'30000@sthlm_1'),
    ?assertMatch([],db_service_discovery:read("adder_service")),
    ?assertMatch(['10250@asus'],db_service_discovery:read("dbase_service")),
    db_service_discovery:create(#service_discovery{id="adder_service",vsn="1.0.0",vm='30000@sthlm_1'}),
    ?assertMatch(['30000@sthlm_1'],
		 db_service_discovery:read("adder_service")),
    db_service_discovery:create(#service_discovery{id="adder_service",vsn="1.0.0",vm='30000@host2'}),

    ?assertMatch(['30000@sthlm_1','30000@host2'],
		 db_service_discovery:read("adder_service")),
    db_service_discovery:delete("adder_service","1.0.0",'30000@host2'),
    ?assertMatch(['30000@sthlm_1'],db_service_discovery:read("adder_service")),

    ok.
%% -----------

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------


db_service_def()->
     % db_service_def
    db_service_def:delete("glurk","1.0.0"),
    db_service_def:delete("adder_service","1.0.1"),
    

    ?assertMatch([{"node_service","1.0.0","joq62"},
		  {"adder_service","1.0.0","joq62"},
		  {"catalog_service","1.0.0","joq62"},
		  {"log_service","1.0.0","joq62"},
		  {"divi_service","1.0.0","joq62"},
		  {"dbase_service","1.0.0","joq62"},
		  {"orchistrate_service","1.0.0","joq62"},
		  {"multi_service","1.0.0","joq62"}],db_service_def:read_all()),

    ?assertMatch([{"adder_service","1.0.0","joq62"}],db_service_def:read("adder_service")),
    db_service_def:create(#service_def{id="adder_service",vsn="1.0.1",
				       source="joq62"}),
    ?assertMatch([{"adder_service","1.0.0","joq62"},
		  {"adder_service","1.0.1","joq62"}],
		 db_service_def:read("adder_service")),
    ?assertMatch([{"adder_service","1.0.1","joq62"}],
		 db_service_def:read("adder_service","1.0.1")),
   db_service_def:create(#service_def{id="glurk",vsn="1.0.0",
				      source="joq62"}),
    ?assertMatch([{"glurk","1.0.0","joq62"}],db_service_def:read("glurk")),
    db_service_def:delete("glurk","1.0.0"),

    ok.

% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
loop(0,_)->
    ok;
loop(N,I) ->
    io:format(" *************** "),
    io:format(" ~p",[{time()}]),
    io:format(" *************** ~n"),


  %  RunningComputers=iaas:running_computers(),
  %  io:format("RunningComputers  = ~p~n",[RunningComputers]),

  %  AvailableComputers=iaas:available_computers(),
  %  io:format("AvailableComputers  = ~p~n",[AvailableComputers]),

  %  NotAvailableComputers=iaas:not_available_computers(),
  %  io:format("NotAvailableComputers  = ~p~n",[NotAvailableComputers]),

    RunningComputers=iaas:computer_status(running),
 %   io:format("RunningComputers : ~p~n",[RunningComputers]),

    AvailableComputers=iaas:computer_status(available),
 %   io:format("AvailableComputers : ~p~n",[AvailableComputers]),

    NotAvailableComputers=iaas:computer_status(not_available),
 %   io:format( "NotAvailableComputers : ~p~n",[NotAvailableComputers]),

    RunningVms=iaas:vm_status(running),
  %  io:format("RunningVms : ~p~n",[RunningVms]),

    AvailableVms=iaas:vm_status(available),
  %  io:format("AvailableVms : ~p~n",[AvailableVms]),

    NotAvailableVms=iaas:vm_status(not_available),
  %  io:format( "NotAvailableVms : ~p~n",[NotAvailableVms]),

    Candidates10=iaas:get_all_vms(),
    io:format( "Candidates10 : ~p~n",[Candidates10]),  
    GetR10=iaas:get_vm(),
    io:format( "GetR10 : ~p~n",[GetR10]), 
    GetR11=iaas:get_vm(),
    io:format( "GetR11 : ~p~n",[GetR11]), 

    Candidates11=iaas:get_all_vms(),
    io:format( "Candidates11 : ~p~n",[Candidates11]),  

    GetR2=iaas:get_vm(not_from,["sthlm_1","asus"]),
    io:format( "GetR2 : ~p~n",[GetR2]), 
    GetR21=iaas:get_vm(not_from,["sthlm_1"]),
    io:format( "GetR21 : ~p~n",[GetR21]), 
    GetR3=iaas:get_vm(from,["sthlm_1"]),
    io:format( "GetR3 : ~p~n",[GetR3]), 
    Candidates20=iaas:get_all_vms(),
    io:format( "Candidates20 : ~p~n",[Candidates20]),  

    %% Orchistrate
    % Instance 1 
    case iaas:get_vm() of
	{error,[no_vms_running]}->
	    ok;
	{ok,{HostId1,VmId1,Vm1}}->
	    io:format( "{HostId1,VmId1,Vm1} : ~p~n",[{HostId1,VmId1,Vm1}]),
	    % Instance 2
	    case iaas:get_vm(not_from,[HostId1]) of
		{error,[no_vms_running]}->
		    ok;
		{ok,{HostId2,VmId2,Vm2}}->
		    io:format( "{HostId2,VmId2,Vm2} : ~p~n",[{HostId2,VmId2,Vm2}]),
                    % Instance 3
		     case iaas:get_vm(not_from,[HostId1,HostId2]) of
			 {error,Err}->
			     io:format( "{HostId3,VmId3,Vm3} : ~p~n",[ {error,Err}])
		     end
	    end
    end,
  

    timer:sleep(I),
    loop(N-1,I).

    



check_computer_status()->
    ComputerStatus=computer:status_computers(),
    io:format("ComputerStatus  = ~p~n",[{?MODULE,?LINE,ComputerStatus}]),
  %  ?assertEqual([{stopped,"glurk"},
%		  {running,"asus"},
%		  {running,"sthlm_1"}],ComputerStatus),
   
    
  %  ?assertEqual(["asus"],iaas:running_computers()),
  %  ?assertEqual(["sthlm_1"],iaas:available_computers()),
  %  ?assertEqual(60,lists:flatlength(iaas:not_available_computers())),

    ok.
    


% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
