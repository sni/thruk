include ../_common/Makefile.common

export THRUK_TEST_AUTH               = omdadmin:omd
export PLACK_TEST_EXTERNALSERVER_URI = https://127.0.0.3:60443/demo/
export PERL_LWP_SSL_VERIFY_HOSTNAME  = 0

wait_start:
	for x in $$(seq $(STARTUPWAIT)); do \
	   if [ $$(docker compose logs | grep "failed=" | grep -v "failed=0" | wc -l) -gt 0 ]; then $(MAKE) wait_start_failed; exit 1; fi; \
	   docker compose exec $(DOCKER_COMPOSE_TTY) --user root umbrella_a sudo -iu demo thruk cluster ping >/dev/null 2>&1; \
	   if curl --fail -q http://127.0.0.3:60080/demo/thruk/cgi-bin/remote.cgi?lb_ping >/dev/null 2>&1 && [ $$(docker compose exec $(DOCKER_COMPOSE_TTY) --user root umbrella_a sudo -iu demo thruk cluster status | grep -c OK) -eq 2 ]; then break; else sleep 1; fi; \
	   if [ $$x -eq $(STARTUPWAIT) ]; then $(MAKE) wait_start_failed; exit 1; fi; \
	done
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root umbrella_a sudo -iu demo thruk cluster ping
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root umbrella_a sudo -iu demo thruk cluster status
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root umbrella_a sudo -iu demo thruk r -m POST /thruk/cluster/heartbeat
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root umbrella_b sudo -iu demo thruk r -m POST /thruk/cluster/heartbeat


wait_start_failed_extra:
	-curl -kv http://127.0.0.3:60080/demo/thruk/cgi-bin/login.cgi

extra_clean:
	-docker volume rm umbrella_e2e_shared

extra_test:
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root umbrella_a       sudo -iu demo /usr/local/bin/local_test.sh 0 /test/t/local/umbrella/*.t
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root umbrella_backend sudo -iu demo /usr/local/bin/local_test.sh 0 /test/t/local/umbrella_backend/*.t

extra_test_verbose:
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root umbrella_a       sudo -iu demo /usr/local/bin/local_test.sh 1 /test/t/local/umbrella/*.t
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root umbrella_backend sudo -iu demo /usr/local/bin/local_test.sh 1 /test/t/local/umbrella_backend/*.t

server:
	@echo -e "\n\n*** no server implemented, access via https://127.0.0.3:60443/demo/\n"

