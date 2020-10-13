%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(mapreduce_test). 
   
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


% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
start()->
    %initiate table 
    ?assertEqual(ok,adder()),

    ok.

adder()->
    F1=fun add/2,
    F2 = fun summary/3,
 %   TestVector=[{1,2},{3,4},{5,6},{7,8},{9,10},{11,12},{13,14}],
    TestVector=[{1,2},{3,4}],
    [Result]=map_reduce:start(F1,F2,[],TestVector),
    io:format("~p~n",[Result]).

add(Pid,{A,B})->
    io:format("~p~n",[{?MODULE,?LINE,Pid,A,B}]),
    Pid!{add,A+B}.

summary(Key,Vals,[])->
    io:format("~p~n",[{?MODULE,?LINE,Key,Vals}]),
    summary(Vals,0).

summary([],N)->
    [N];
summary([X|T],Acc) ->
    io:format("~p~n",[{?MODULE,?LINE,X,Acc}]),
    summary(T,Acc+X).

