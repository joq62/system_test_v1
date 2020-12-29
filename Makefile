all:
	rm -rf  *Mnesia erl_cra*;
	rm -rf  *~ */*~;
	rm -rf ebin/* test_ebin/* *.beam test_src/*.beam;
	rm -rf common dbase server control iaas;
	rm -rf cluster* app_specs service_specs
doc_gen:
	rm -rf  node_config logfiles doc/*;
	erlc ../doc_gen.erl;
	erl -s doc_gen start -sname doc
test:
	rm -rf  *Mnesia erl_cra*;
	rm -rf  *~ */*~;
	rm -rf ebin/* test_ebin/* *.beam test_src/*.beam;
	rm -rf common dbase server control iaas;
	rm -rf cluster* app_specs service_specs;
#	control local test
	mkdir control;
	mkdir control/ebin;
	cp ../control/src/*.app control/ebin;
	erlc -o control/ebin ../control/src/*.erl;
	erlc -o test_ebin test_src/*.erl;
	erl -pa test_ebin\
	    -pa control/ebin\
	    -s system_tests start -sname system_test -setcookie abc
