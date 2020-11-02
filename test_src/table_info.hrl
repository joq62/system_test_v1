
[db_computer,"asus","pi","festum01","192.168.0.100",60100,not_available].
[db_computer,"sthlm_1","pi","festum01","192.168.0.110",60110,not_available].
[db_computer,"wrong_hostname","pi","festum01","192.168.0.110",60100,not_available].
[db_computer,"wrong_ipaddr","pi","festum01","25.168.0.110",60100,not_available].
[db_computer,"wrong_port","pi","festum01","192.168.0.110",2323,not_available].
[db_computer,"wrong_userid","glurk","festum01","192.168.0.110",60100,not_available].
[db_computer,"wrong_passwd","pi","glurk","192.168.0.110",60100,not_available].

[db_vm,'10250@asus',"asus","10250",controller,not_available].
[db_vm,'30000@asus',"asus","30000",worker,not_available].
[db_vm,'30001@asus',"asus","30001",worker,not_available].
[db_vm,'30002@asus',"asus","30003",worker,not_available].
[db_vm,'30003@asus',"asus","30003",worker,not_available].
[db_vm,'30004@asus',"asus","30004",worker,not_available].
[db_vm,'30005@asus',"asus","30005",worker,not_available].
[db_vm,'30006@asus',"asus","30006",worker,not_available].
[db_vm,'30007@asus',"asus","30007",worker,not_available].
[db_vm,'30008@asus',"asus","30008",worker,not_available].
[db_vm,'30009@asus',"asus","30009",worker,not_available].

[db_vm,'10250@sthlm_1',"sthlm_1","10250",controller,not_available].
[db_vm,'30000@sthlm_1',"sthlm_1","30000",worker,not_available].
[db_vm,'30001@sthlm_1',"sthlm_1","30001",worker,not_available].
[db_vm,'30002@sthlm_1',"sthlm_1","30003",worker,not_available].
[db_vm,'30003@sthlm_1',"sthlm_1","30003",worker,not_available].
[db_vm,'30004@sthlm_1',"sthlm_1","30004",worker,not_available].
[db_vm,'30005@sthlm_1',"sthlm_1","30005",worker,not_available].
[db_vm,'30006@sthlm_1',"sthlm_1","30006",worker,not_available].
[db_vm,'30007@sthlm_1',"sthlm_1","30007",worker,not_available].
[db_vm,'30008@sthlm_1',"sthlm_1","30008",worker,not_available].
[db_vm,'30009@sthlm_1',"sthlm_1","30009",worker,not_available].

[db_service_def,"adder_service","1.0.0","joq62"].
[db_service_def,"multi_service","1.0.0","joq62"].
[db_service_def,"divi_service","1.0.0","joq62"].


[db_passwd,"joq62","20Qazxsw20"].

[db_deployment_spec,"math","1.0.0",no_restrictions,[{"adder_service","1.0.0"},{"divi_service","1.0.0"}]].



