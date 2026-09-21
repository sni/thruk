#!/usr/bin/make -f

server: .thruk_org
	docker compose up --build

.thruk_org:
	git clone --depth=1 https://github.com/sni/thruk_org .thruk_org

clean:
	docker compose down --rmi all
	docker compose kill -s INT
	docker compose kill
	docker compose rm -f
	rm -rf .thruk_org
