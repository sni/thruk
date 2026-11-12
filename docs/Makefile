#!/usr/bin/make -f

# Reuse the website checkout rather than maintain a second VitePress app.
SHELL := bash
.DEFAULT_GOAL := build
THRUK_ORG_CACHE := $(if $(TMPDIR),$(TMPDIR),/tmp)/thruk-org-$(shell id -u)
THRUK_ORG_SRC ?= $(THRUK_ORG_CACHE)
export THRUK_ORG_SRC

build server preview check test: website
	$(MAKE) -C "$(THRUK_ORG_SRC)" THRUK_SOURCE="$(abspath ..)" $@

website:
	@if [[ "$(THRUK_ORG_SRC)" == "$(THRUK_ORG_CACHE)" && ( -L "$(THRUK_ORG_SRC)" || ( -e "$(THRUK_ORG_SRC)" && ! -O "$(THRUK_ORG_SRC)" ) ) ]]; then echo 'Unsafe temporary website checkout. Set THRUK_ORG_SRC to your checkout.' >&2; exit 1; fi
	@if [[ ! -e "$(THRUK_ORG_SRC)" && ! -L "$(THRUK_ORG_SRC)" ]]; then git clone --depth 1 https://github.com/sni/thruk_org.git "$(THRUK_ORG_SRC)"; fi
	@if [[ ! -f "$(THRUK_ORG_SRC)/Makefile" || ! -f "$(THRUK_ORG_SRC)/.vitepress/config.mts" ]]; then echo 'THRUK_ORG_SRC must be a website checkout with the VitePress migration.' >&2; exit 1; fi

.PHONY: build server preview check test website
