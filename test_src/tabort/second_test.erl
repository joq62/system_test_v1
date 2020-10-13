%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(second_test). 
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").
-include_lib("stdlib/include/qlc.hrl").

%%---------------------------------------------------------------------
%% Records for test
%%
-record(computer,
	{
	  host_id,
	  ssh_uid,
	  ssh_passwd,
	  ip_addr,
	  port
	}).

-define(TABLE,computer).
-define(RECORD,computer).
-define(TEXTFILE,"./test_src/dbase_init.hrl").
%% --------------------------------------------------------------------

-export([start/0]).

%% ====================================================================
%% External functions
%% ====================================================================
check_init()->
    HostId=net_adm:localhost(),
    MnesiaVm=list_to_atom("mnesia@"++HostId),
    rpc:call(MnesiaVm,dbase_service,load_textfile,[?TEXTFILE]),
    ok.

% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    %initiate table 
    ?assertEqual(ok,check_init()),

    ok.

create(Record) ->
    F = fun() -> mnesia:write(Record) end,
    mnesia:transaction(F).


read_all() ->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE)])),
    [{HostId,SshUid,SshPassWd,IpAddr,Port}||{?RECORD,HostId,SshUid,SshPassWd,IpAddr,Port}<-Z].



read(HostId) ->
    Z=do(qlc:q([X || X <- mnesia:table(?TABLE),
		     X#?RECORD.host_id==HostId])),
    [{HId,SshUid,SshPassWd,IpAddr,Port}||{?RECORD,HId,SshUid,SshPassWd,IpAddr,Port}<-Z].


update(HostId,SshId,SshPwd,IpAddr,Port)->
    F = fun() ->
		Oid = {?TABLE, HostId},
		mnesia:delete(Oid),
		Record = #?RECORD{host_id=HostId,ssh_uid=SshId,ssh_passwd=SshPwd,
				  ip_addr=IpAddr,port=Port},
		mnesia:write(Record)
	end,
    mnesia:transaction(F).

delete(HostId) ->
    Oid = {?TABLE, HostId},
    F = fun() -> mnesia:delete(Oid) end,
  mnesia:transaction(F).


do(Q) ->
  F = fun() -> qlc:e(Q) end,
  {atomic, Val} = mnesia:transaction(F),
  Val.


