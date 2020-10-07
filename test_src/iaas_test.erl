%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(iaas_test). 
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include_lib("eunit/include/eunit.hrl").


%%---------------------------------------------------------------------
%% Records for test
%%

%% --------------------------------------------------------------------

-export([start/0]).

-define(TimeOut,3000).

%% ====================================================================
%% External functions
%% ====================================================================
setup()->
    ssh:start(),
    {atomic,ok}=db_computer:delete("glurk"),
    {atomic,ok}=db_computer:delete("glurk2"),

    {atomic,ok}=db_computer:create({computer,"wrong_hostname","pi","festum01","192.168.0.110",60100}),
    {atomic,ok}=db_computer:create({computer,"wrong_ipaddr","pi","festum01","25.168.0.110",60100}),
    {atomic,ok}=db_computer:create({computer,"wrong_port","pi","festum01","192.168.0.110",2323}),
    {atomic,ok}=db_computer:create({computer,"wrong_userid","glurk","festum01","192.168.0.110",60100}),
    {atomic,ok}=db_computer:create({computer,"wrong_passwd","pi","glurk","192.168.0.110",60100}),
    ?assertEqual(ok,application:start(iaas)),
   
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
    ?assertEqual(ok,setup()),

    ?debugMsg("check_computer_status"),
    ?assertEqual(ok,check_computer_status()),
    
    
 
    ?assertEqual(ok,cleanup()),

    ok.


check_computer_status()->
    ComputerStatus=computer:check_computers(),
%    ?assertEqual([{stopped,"glurk"},
%		  {running,"asus"},
%		  {running,"sthlm_1"}],ComputerStatus),

    ?assertEqual(["asus"],iaas:running_computers()),
    ?assertEqual(["sthlm_1"],iaas:available_computers()),
    ?assertEqual(60,lists:flatlength(iaas:not_available_computers())),

    ok.
    
