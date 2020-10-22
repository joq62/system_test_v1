-record(computer,
	{
	  host_id,
	  ssh_uid,
	  ssh_passwd,
	  ip_addr,
	  port
	}).


-record(service_def,
	{
	  id,
	  vsn,
	  source
	}).

-record(deployment_spec,
	{
	  id,   %"etcd_0"
	  vsn,  %"1.0.0"
	  services % [{service_id,vsn,num,options}]
	}).
-record(deployment,
	{
	  id,
	  vsn,
	  service_id,
	  service_vsn,
	  vm
	}).
-record(service_discovery,
	{
	  id,
          vsn,
	  vm
	}).
