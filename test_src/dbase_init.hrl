{tables,
 [{computer,[{attributes,[host_id,ssh_uid,ssh_passwd, ip_addr,port]},
	    {disc_copies,['mnesia@sthlm_1']}]},
  {service_def,[{attributes,[id,vsn,git_user_id]},
		{disc_copies,['mnesia@sthlm_1']}]},
  {deployment_spec,[{attributes,[id,vsn,sevices]},
		    {disc_copies,['mnesia@sthlm_1']}]},
  {deployment,[{attributes,[id,vsn,service_id,service_vsn,vm]},
	       {disc_copies,['mnesia@sthlm_1']}]},
  {service_discovery,[{attributes,[id,vm]},
		      {disc_copies,['mnesia@sthlm_1']},
		      {type,bag}]},
  {passwd,[{attributes,[user_id,passwd]},
		      {disc_copies,['mnesia@sthlm_1']},
		      {type,bag}]}
 ]
}.

{computer,"asus","pi","festum01","192.168.0.100",60100}.
{computer,"sthlm_1","pi","festum01","192.168.0.110",60110}.

{passwd,"joq62","20Qazxsw20"}.

{service_def,"dbase_service","1.0.0","joq62"}.
{service_def,"node_service","1.0.0","joq62"}.
{service_def,"log_service","1.0.0","joq62"}.
{service_def,"catalog_service","1.0.0","joq62"}.
{service_def,"orchistrate_service","1.0.0","joq62"}.
{service_def,"adder_service","1.0.0","joq62"}.
{service_def,"adder_service","1.0.0","joq62"}.
{service_def,"multi_service","1.0.0","joq62"}.
{service_def,"divi_service","1.0.0","joq62"}.

{service_discovery,"dbase_service",'mnesia@asus'}.


{deployment_spec,"math","1.0.0",[{"adder_service","1.0.0",[any]}]}.



