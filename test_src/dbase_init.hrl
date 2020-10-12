{tables,
 [{computer,[{attributes,[host_id,ssh_uid,ssh_passwd, ip_addr,port]},
	    {disc_copies,['10250@asus']}]},
  {service_def,[{attributes,[id,vsn,git_user_id]},
		{disc_copies,['10250@asus']}]},
  {deployment_spec,[{attributes,[id,vsn,sevices]},
		    {disc_copies,['10250@asus']}]},
  {deployment,[{attributes,[id,vsn,service_id,service_vsn,vm]},
	       {disc_copies,['10250@asus']}]},
  {service_discovery,[{attributes,[id,vm]},
		      {disc_copies,['10250@asus']},
		      {type,bag}]},
  {passwd,[{attributes,[user_id,passwd]},
		      {disc_copies,['10250@asus']},
		      {type,bag}]}
 ]
}.

{computer,"asus","pi","festum01","192.168.0.100",60100}.
{computer,"sthlm_1","pi","festum01","192.168.0.110",60110}.
{computer,"wrong_hostname","pi","festum01","192.168.0.110",60100}.
{computer,"wrong_ipaddr","pi","festum01","25.168.0.110",60100}.
{computer,"wrong_port","pi","festum01","192.168.0.110",2323}.
{computer,"wrong_userid","glurk","festum01","192.168.0.110",60100}.
{computer,"wrong_passwd","pi","glurk","192.168.0.110",60100}.

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

{service_discovery,"dbase_service",'10250@asus'}.


{deployment_spec,"math","1.0.0",[{"adder_service","1.0.0",[any]}]}.



