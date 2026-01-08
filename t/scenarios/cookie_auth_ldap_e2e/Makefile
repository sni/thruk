include ../_common/Makefile.common

extra_wait_start:
	for x in $$(seq 200); do \
	   if [ $$($(THRUK) -l 2>&1 | grep -c ERROR) -eq 0 ]; then break; else sleep 1; fi; \
	   if [ $$x -eq 200 ]; then exit 1; fi; \
	done
	for x in $$(seq 200); do \
	   curl -ks https://127.0.0.3:60443 >/dev/null 2>&1 && break; \
	   if [ $$x -eq 200 ]; then exit 1; fi; \
	   sleep 1; \
	done

test_local:
	$(THRUK) -l
	$(THRUK) cache clean
	docker compose exec $(DOCKER_COMPOSE_TTY) --user root omd bash -ci /root/test.sh

test: wait_start test_local
	cd ../../.. && PERL_DL_NONLAZY=1 /usr/bin/env perl "-MExtUtils::Command::MM" "-e" "test_harness(0)" $(shell pwd)/../_common/t/999*.t

test_verbose: wait_start test_local
	cd ../../.. && PERL_DL_NONLAZY=1 /usr/bin/env perl "-MExtUtils::Command::MM" "-e" "test_harness(1)" $(shell pwd)/../_common/t/999*.t
