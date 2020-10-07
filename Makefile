all:
	rm -rf *@asus include *~ */*~ */*/*~;
	rm -rf ebin/* test_ebin/*;
	rm -rf *.beam erl_crash.dump */erl_crash.dump */*/erl_crash.dump;
	erlc -o test_ebin test_src/*.erl,
	rm -rf ebin/* test_ebin/*;
doc_gen:
	rm -rf  node_config logfiles doc/*;
	erlc ../doc_gen.erl;
	erl -s doc_gen start -sname doc
test:
	rm -rf  include configs *_service  erl_crasch.dump;
#	include
#	git clone https://github.com/joq62/include.git;

#	iaas
	cp ../iaas/src/*.app ebin;
	erlc -o ebin ../iaas/src/*.erl;
#	dbase_service
	cp ../dbase_service/src/*.app ebin;
	erlc -o ebin ../dbase_service/src/*.erl;
#	test
	erlc -o test_ebin test_src/*.erl;

	erl -pa ebin -pa test_ebin -s system_tests start -sname 10250 -setcookie abc
