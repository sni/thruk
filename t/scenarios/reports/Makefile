include ../_common/Makefile.common

export PLACK_TEST_EXTERNALSERVER_URI = http://127.0.0.3:60080/demo/

wait_start:
	for x in $$(seq $(STARTUPWAIT)); do \
	   if [ $$(docker compose logs | grep "failed=" | grep -v "failed=0" | wc -l) -gt 0 ]; then $(MAKE) wait_start_failed; exit 1; fi; \
	   if [ $$(curl -s http://127.0.0.3:60080/demo/thruk/cgi-bin/login.cgi | grep -c loginuser) -gt 0 ]; then break; else sleep 1; fi; \
	   if [ $$x -eq $(STARTUPWAIT) ]; then $(MAKE) wait_start_failed; exit 1; fi; \
	done

extra_test:
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root omd sudo -iu demo /usr/local/bin/local_test.sh 0 /test/t/local/*.t
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root omd sudo -iu root /usr/local/bin/local_test.sh 0 /test/t/local/*.troot

extra_test_verbose:
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root omd sudo -iu demo /usr/local/bin/local_test.sh 1 /test/t/local/*.t
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root omd sudo -iu root /usr/local/bin/local_test.sh 1 /test/t/local/*.troot

wait_start_failed_extra:
	-curl -kv http://127.0.0.3:60080/demo/thruk/cgi-bin/login.cgi

server:
	@echo -e "\n\n*** no server implemented, access via http://127.0.0.3:60080/demo/\n"

