%%% -------------------------------------------------------------------
%%% @author : joqerlang
%%% @doc : ets dbase for master service to manage app info , catalog  
%%%
%%% -------------------------------------------------------------------
-module(sys_test_service).
 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%-compile(export_all).
-export([create/3
	]).

create(ServiceSpecId,VmDir,Vm)->
    Result=case db_service_def:read(ServiceSpecId) of
	       []->
		   {error,[eexists,ServiceSpecId]};
	       [{ServiceSpecId,ServiceId,ServiceVsn,StartCmd,GitPath}]->
		   create(ServiceId,ServiceVsn,Vm,VmDir,StartCmd,GitPath)
	   end,
    Result.

create(ServiceId,ServiceVsn,Vm,VmDir,{application,start,A},GitPath)->
    ServiceDir=string:concat(ServiceId,misc_cmn:vsn_to_string(ServiceVsn)),
    GitDest=filename:join(VmDir,ServiceDir),
    CodePath=filename:join([VmDir,ServiceDir,"ebin"]),
    [ServiceModule]=A,
 %   io:format("ServiceId,ServiceVsn,Vm,VmDir ~p~n",[{ServiceId,ServiceVsn,Vm,VmDir,?MODULE,?LINE}]),
  %  io:format("ServiceDir,GitDest,CodePath ~p~n",[{ServiceDir,GitDest,CodePath,?MODULE,?LINE}]),
    true=vm:vm_started(Vm),
    rpc:call(Vm,file,del_dir_r,[GitDest],3000),
    rpc:call(Vm,os,cmd,["git clone "++GitPath++" "++GitDest],10*1000),
    true=rpc:call(Vm,filelib,is_dir,[CodePath],2000),
    true=rpc:call(Vm,code,add_patha,[CodePath],3000),
    Result=case rpc:call(Vm,application,start,A,3000) of
	       ok->
		   case rpc:call(Vm,ServiceModule,ping,[],3000) of
		       {pong,_,ServiceModule}->
			   {ok,ServiceId,ServiceVsn};
		       Reason->
			   {error,[Reason,?MODULE,?LINE]}
		   end;
	       Reason->
		   {error,[Reason,?MODULE,?LINE]}
	   end,
    Result.


check_clone(0,_T,_Vm,_CodePath,Msg)->
    Msg;
check_clone(N,T,Vm,CodePath,Msg)->
    io:format("check_clone(N,T,Vm,CodePath,Msg) ~p~n",[{N,T,Vm,CodePath,Msg,?MODULE,?LINE}]),
    case rpc:call(Vm,filelib,is_dir,[CodePath],2000) of
	{badrpc,Reason}->
	    NewMsg={badrpc,Reason},
	    NewN=0;
	false ->
	    timer:sleep(T),
	    NewMsg=Msg,
	    NewN=N-1;
	true->
	    NewMsg=glurk,
	    NewN=0
    end,
    check_clone(NewN,T,Vm,CodePath,NewMsg).
	    
%% ====================================================================
%% External functions
%% ====================================================================


%% --------------------------------------------------------------------
%% 
%%
%% --------------------------------------------------------------------
