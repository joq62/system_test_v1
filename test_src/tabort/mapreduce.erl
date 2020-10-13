%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : dbase using dets 
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(mapreduce).  
   
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-import(lists,[foreach/2]).

%%---------------------------------------------------------------------
%% Records for test
%%

%% --------------------------------------------------------------------

-export([start/4]).

-export([test/0]).

%% ====================================================================
%% External functions
%% ====================================================================

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
start(F1,F2,Acc0,L)->
    S=self(),
    Pid=spawn(fun()->
		      reduce(S,F1,F2,Acc0,L) end),
    receive
	{Pid,Result}->
	    Result
    end.

reduce(Parent,F1,F2,Acc0,L)->
    process_flag(trap_exit,true),
    ReducePid=self(),
    foreach(fun(X)->
		    spawn_link(fun()->
				       do_job(ReducePid,F1,X) end)
	    end, L),
    N=length(L),
 %   io:format("~p~n",[{?MODULE,?LINE,N}]),
    Dict0=dict:new(),
    Dict1=collect_replies(N,Dict0),
 %   io:format("~p~n",[{?MODULE,?LINE,Dict1}]),
    Acc = dict:fold(F2, Acc0,Dict1),
    Parent!{self(),Acc}.

collect_replies(0,Dict)->
    Dict;
collect_replies(N,Dict) ->
    receive
	{Key,Value}->
	    io:format("~p~n",[{?MODULE,?LINE,Key,Value}]),
	    case dict:is_key(Key,Dict) of
		true->
		    Dict1=dict:append(Key,Value,Dict),
		    collect_replies(N,Dict1);
		false ->
		    Dict1=dict:store(Key,[Value],Dict),
		    collect_replies(N,Dict1)
		end;
	{'EXIT',_,_Why} ->
	    collect_replies(N-1,Dict)
    end.
	    
do_job(ReducePid, F, X)->
%    io:format("~p~n",[{?MODULE,?LINE,F,X}]),
    F(ReducePid,X).


% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------


test()->
    F1=fun add/2,
    F2 = fun summary/3,
    TestVector=[{1,2},{3,4},{5,6},{7,8},{9,10},{11,12},{13,14}],
 %   TestVector=[{1,2},{3,4}],
    Result=mapreduce:start(F1,F2,[],TestVector),
    io:format("~p~n",[Result]),
    Result.

add(Pid,{A,B})->
    io:format("~p~n",[{?MODULE,?LINE,Pid,A,B}]),
    Pid!{add,A+B}.

summary(Key,Vals,[])->
    io:format("~p~n",[{?MODULE,?LINE,Key,Vals}]),
    summary(Vals,0).

summary([],N)->
    N;
summary([X|T],Acc) ->
    io:format("~p~n",[{?MODULE,?LINE,X,Acc}]),
    summary(T,Acc+X).
