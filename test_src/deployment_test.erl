%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(deployment_test). 
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").


%%---------------------------------------------------------------------
%% Records for test
%%

%% --------------------------------------------------------------------

-export([start/0]).

%% ====================================================================
%% External functions
%% ====================================================================
setup()->
    

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

    ?debugMsg("Start create_deployment_spec"),
    ?assertEqual(ok,create_deployment_spec()),
    ?debugMsg("End create_deployment_spec"),

    ?debugMsg("Start create_service"),
    ?assertEqual(ok,create_service()),
    ?debugMsg("End create_service"),

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
    
    AppId="calculus",
    AppVsn="1.0.0",
    ServiceList=[{"adder_service","1.0.0",[]},
		 {"multi_service","1.0.0",[]},
		 {"divi_service","1.0.0",[]}],
    control:delete_deployment_spec(AppId,AppVsn),
    ok=control:create_deployment_spec(AppId,AppVsn,ServiceList),
    ?assertEqual([{"calculus","1.0.0",
		   [{"adder_service","1.0.0",[]},
		    {"multi_service","1.0.0",[]},
		    {"divi_service","1.0.0",[]}]}],control:read_deployment_spec(AppId,AppVsn)),

    ok.
% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

create_service()->
    {HostId,VmId}=get_vm(),
    io:format("~p~n",[{?MODULE,?LINE,HostId,VmId}]),
    ServiceId="adder_service",Vsn="1.0.0",
    ok=control:create_service(ServiceId,Vsn,HostId,VmId),
    Vm=list_to_atom(VmId++"@"++HostId),
    ?assertEqual(42,rpc:call(Vm,adder_service,add,[20,22])),
    
    ok=control:delete_service(ServiceId,Vsn,HostId,VmId),
    ?assertMatch({badrpc,_},rpc:call(Vm,adder_service,add,[20,22])),
    
    ok.
			      

get_vm()->
    R=case iaas:get_vm(from,["sthlm_1"]) of
	  {error,[no_vms_running]}->
	      timer:sleep(10*1000),
	      get_vm();
	  {ok,{HostId,VmId,_}} ->
	      {HostId,VmId}
      end,
    R.

% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
