%%% -------------------------------------------------------------------
%%% @author : joqerlang
%%% @doc : ets dbase for master service to manage app info , catalog  
%%%
%%% -------------------------------------------------------------------
-module(sys_test_deployment). 
 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
%% --------------------------------------------------------------------
%% Definition
-define(Cookie,"abc").
%% --------------------------------------------------------------------


%-compile(export_all).
-export([load_app_specs/3,
	 read_app_specs/0,
	 read_app_spec/1,
	 load_service_specs/3,
	 read_service_specs/0,
	 read_service_spec/1,

	 get_wanted_service_info/1,

	 missing_apps/0,
	 depricated_apps/0,

	 create_application/1,
	 delete_application/1,
	 random_host/0
	 
	]).

%% ====================================================================
%% External functions
%% ====================================================================

   % Vm=case {HostId,VmId} of
%	   {host_any, vm_id_any}->
%	       vm_any;
%	   {HostId,VmId}->
%	       list_to_atom(VmId++"@"++HostId)
 %      end,
   
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
create_application(AppSpec)->
    Result=case db_app_spec:read(AppSpec) of
	       [{AppSpec,AppVsn,Directive,ServiceSpecs}]->
		   case directive_info(AppSpec,Directive) of
		       [{ok,HostId},{ok,VmId},{ok,VmDir}]->
			   case sys_test_vm:create(HostId,VmId,VmDir,?Cookie) of
			       {error,Reason}->
				   {error,Reason};
			       {ok,Vm}->
				   CreateResult=[sys_test_service:create(ServiceSpecId,VmDir,Vm)||ServiceSpecId<-ServiceSpecs],
				   CheckAllStarted=[{R,ServiceId,ServiceVsn}||{R,ServiceId,ServiceVsn}<-CreateResult,
									      R/=ok],
				   case CheckAllStarted of
				       []->
					   [{db_sd:create(XServiceId,XServiceVsn,AppSpec,AppVsn,HostId,VmId,VmDir,Vm),XServiceId,XServiceVsn,Vm}||{ok,XServiceId,XServiceVsn}<-CreateResult],
				     {ok,AppSpec,HostId,VmId,Vm};
					   
				       _->
					   {error,[create_application,CheckAllStarted,?MODULE,?LINE]}
				   end
			   end;
		       Reason->
			   {error,Reason}
		   end;
	       Reason->
		   {error,Reason}
	   end,	    
    Result.

random_host()->
    Result= case db_server:status(running) of
		[]->
		    {error,[no_running_hosts_available]};
		RunningHosts->
		   % io:format("RunningHosts ~p~n",[RunningHosts]),
		    NumHosts=lists:flatlength(RunningHosts),
		  %  io:format("NumHosts ~p~n",[NumHosts]),
		    Position=rand:uniform(NumHosts),
		    {HostId,running}=lists:nth(Position,RunningHosts),
		  %  io:format("HostId ~p~n",[HostId]),
		    {ok,HostId}
	    end,
    Result.

directive_info(AppSpec,Directive)->
    VmIdResult=case lists:keyfind(vm_id,1,Directive) of
		   {vm_id,any}->
		       [Name1,"app_spec"]=string:split(AppSpec,["."]),
		       {ok,Name1};
		   {vm_id,VmId}->
		       {ok,VmId}
	       end,
    VmDirResult=case lists:keyfind(vm_dir,1,Directive) of
		    {vm_dir,any}->
			[Name2,"app_spec"]=string:split(AppSpec,["."]),
			{ok,Name2};
		    {vm_dir,VmDir}->
			{ok,VmDir}
		end,
    HostIdResult=case lists:keyfind(host,1,Directive) of
		     {host,any}->
			 random_host();
		     {host,HostId}->
			 {ok, HostId}
		 end,
    io:format("HostIdResult,VmIdResult,VmDirResult ~p~n",[{HostIdResult,VmIdResult,VmDirResult}]),
    [HostIdResult,VmIdResult,VmDirResult].
    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
delete_application(AppSpec)->
    Result=case db_sd:app_spec(AppSpec) of
	       []->
		   {error,[eexists,AppSpec]};
	       ServicesList->
		   [X|_]=ServicesList,
		   io:format("{ServiceId,ServiceVsn,AppSpec,AppVsn,HostId,VmId,Vm} ~p~n",[{X,?MODULE,?LINE}]),
		   [{_ServiceId,_ServiceVsn,AppSpec,_AppVsn,_HostId,_VmId,VmDir,Vm}|_]=ServicesList,
		   
		   % rm vm dir
		   io:format("file,del_dir_r,[VmDir] ~p~n",[{rpc:call(Vm,file,del_dir_r,[VmDir],2000),VmDir,?MODULE,?LINE}]),
		% Stop the vm
		   R=rpc:call(Vm,init,stop,[],2000),  
		   io:format("Vm,init,stop ~p~n",[{R,Vm,?MODULE,?LINE}]),
		 
	       % Remove from sd discovery	       
	       [db_sd:delete(ServiceId,ServiceVsn,XVm)||
		   {ServiceId,ServiceVsn,_,_,_,_,XVm}<-ServicesList],
	       ok
       end,
    Result.

%% -------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
missing_apps()->
    %1.check if appspecs is presente in some of the services Simple algorithm 
    ActiveServicesApps=db_sd:active_apps(),
    WantedApps=db_app_spec:all_app_specs(),
    [XAppSpec||XAppSpec<-WantedApps,
	       false==lists:member(XAppSpec,ActiveServicesApps)].

%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------    
depricated_apps()->
    %1.check if appspecs is presente in some of the services Simple algorithm 
    ActiveServicesApps=db_sd:active_apps(),
    WantedApps=db_app_spec:all_app_specs(),
    DepricatedDoublets=[XAppSpec||XAppSpec<-ActiveServicesApps,
		       false==lists:member(XAppSpec,WantedApps)],
    filter_doublets(DepricatedDoublets,[]).

filter_doublets([],FilteredList)->
    FilteredList;
filter_doublets([X|T],Acc)->
    NewAcc=case lists:member(X,Acc) of
	       false->
		   [X|Acc];
	       true ->
		   Acc
	   end,
    filter_doublets(T,NewAcc).

%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
get_wanted_service_info(AppSpec)->
    Result=case db_app_spec:read(AppSpec) of
	       [{AppSpec,AppVsn,Directive,ServiceSpecs}]->
		   get_wanted_service_info(AppSpec,AppVsn,Directive,ServiceSpecs);
	       [] ->
		   {error,[eexists,AppSpec]};
	       Reason ->
		   {error,[Reason,AppSpec]}
	   end,
    Result.


get_wanted_service_info(AppSpec,_AppVsn,Directive,ServiceSpecs)->
    HostId=case lists:keyfind(host,1,Directive) of
	       false->
		   host_any;
	       {host,XHost}->
		   XHost
	   end,
    VmId=case lists:keyfind(vm_id,1,Directive) of
	       false->
		   vm_id_any;
	       {vm_id,XVmId}->
		   XVmId
	   end,
    Vm=case {HostId,VmId} of
	   {host_any, vm_id_any}->
	       vm_any;
	   {HostId,VmId}->
	       list_to_atom(VmId++"@"++HostId)
       end,
   % io:format("ServiceSpecs ~p~n",[ServicSpecs]),
    
    ServiceInfo=lists:append([db_service_def:read(ServiceSpec)||ServiceSpec<-ServiceSpecs]),
    [{ServiceId,ServiceVsn,AppSpec,HostId,VmId,Vm}||{_ServiceSpec,ServiceId,ServiceVsn,_StartCmd,_GitPath}<-ServiceInfo].

%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

read_app_spec(AppId)->
    db_app_spec:read(AppId).
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

read_app_specs()->
    db_app_spec:read_all().
    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

load_app_specs(AppSpecDir,GitUser,GitPassWd)->
     %% Get initial configuration
    os:cmd("rm -rf "++AppSpecDir),
    GitCmd="git clone https://"++GitUser++":"++GitPassWd++"@github.com/"++GitUser++"/"++AppSpecDir++".git",
    os:cmd(GitCmd),
    Result=case file:list_dir(AppSpecDir) of
	       {ok,FileNames}->
		   SpecFileNames=[filename:join(AppSpecDir,FileName)||FileName<-FileNames,
					       ".app_spec"==filename:extension(FileName)],
		   L1=[file:consult(FileName)||FileName<-SpecFileNames],
		   L2=[Info||{ok,[Info]}<-L1],
		   DbaseResult=[R||R<-dbase:init_table_info(L2),
				   R/={atomic,ok}],
		   case DbaseResult of
			[]->
			   ok;
		       Reason->
			   {error,Reason}
		   end;
	       {error,Reason} ->
		   {error,Reason}
	   end, 
    Result.
    

%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

read_service_spec(Id)->
    db_service_def:read(Id).
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

read_service_specs()->
    db_service_def:read_all().
    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------

load_service_specs(SpecDir,GitUser,GitPassWd)->
     %% Get initial configuration
    os:cmd("rm -rf "++SpecDir),
    GitCmd="git clone https://"++GitUser++":"++GitPassWd++"@github.com/"++GitUser++"/"++SpecDir++".git",
    os:cmd(GitCmd),
    Result=case file:list_dir(SpecDir) of
	       {ok,FileNames}->
		   SpecFileNames=[filename:join(SpecDir,FileName)||FileName<-FileNames,
								   ".service_spec"==filename:extension(FileName)],
		   L1=[file:consult(FileName)||FileName<-SpecFileNames],
		   L2=[Info||{ok,[Info]}<-L1],
		   L3=dbase:init_table_info(L2),
		   DbaseResult=[R||R<-L3,
				   R/={atomic,ok}],
		   
		   case DbaseResult of
			[]->
			   ok;
		       Reason->
			   {error,Reason}
		   end;
	       {error,Reason} ->
		   {error,Reason}
	   end, 
    Result.
    
%% --------------------------------------------------------------------
%% Function:create(ServiceId,Vsn,HostId,VmId)
%% Description: Starts vm and deploys services 
%% Returns: ok |{error,Err}
%% --------------------------------------------------------------------
