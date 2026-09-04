# Docs scenario

This scenario runs the documentation tests (`t/095-doc_*.t`) that validate the
generated Thruk documentation against a real monitoring backend.

## What these tests do

The `make docs` target in the repository root regenerates the documentation from
live data, and therefore needs a running monitoring core (naemon, icinga, ...)
which is reachable over a livestatus socket and which has a full set of objects
(hosts, hostgroups, contacts, contactgroups, services, servicegroups, ...) to
query metadata for.

This scenario builds a complete OMD environment (naemon backend) in a container,
forwards the naemon TCP livestatus socket and the Thruk web ports to the host,
and then runs the three doc tests on the **host** against that backend:

  - `t/095-doc_coverage.t`         - every config key in `thruk.conf` must be documented
  - `t/095-doc_rest.t`             - regenerate the REST API docs and diff against the committed docs
  - `t/095-doc_roles_coverage.t`   - every possible role must be documented

## Quick start

    %> cd t/scenarios/docs
    %> make clean
    %> make prepare
    %> make test

`make prepare` may take a few minutes the first time (it builds the base OMD
image). Subsequent runs are fast.

## Regenerating the documentation (`make docs`)

The scenario container can also serve as the backend for the repository root
`make docs` target, which regenerates the docs from a live monitoring core:

    %> cd t/scenarios/docs
    %> make prepare          # starts the container and installs the repo-root
                             # thruk_local.d/docs-scenario.conf peer config
    %> cd $REPO_ROOT
    %> PERL5LIB=lib make docs
    %> cd t/scenarios/docs && make clean    # teardown when done

`make docs` regenerates the REST API docs (`rest.asciidoc`,
`rest_commands.asciidoc`, `commands.html`, `cmd.pm`, `docs.pm`), the man pages,
`livestatus_docs.pm` and `check_thruk_rest.asciidoc`. Only
`script/thruk_update_docs_rest.pl` needs the backend; the other steps
(`thruk_update_docs.sh` man pages, `thruk_update_livestatus_docs.pl` which
fetches the naemon columns JSON from the web, and `docs_check_thruk_rest`)
do not.

## The one design decision that explains everything

The doc tests run on the **host**, not inside the container. The common
`Makefile.common` runs them via:

    cd ../../.. && perl -MExtUtils::Command::MM -e "test_harness(0)" $PWD/t/*.t

so every test process has **CWD = the repository root**, and the docs scenario
additionally exports:

  - `THRUK_CONFIG := $(abspath ../../..)`  (repo root) - see `Makefile`
  - `PERL5LIB := $(abspath ../../../lib):$(PERL5LIB)`

Two consequences follow from `CWD == THRUK_CONFIG == repo root`:

  1. `etc_path` equals the test CWD. The doc generation script
     (`script/thruk_update_docs_rest.pl`) writes sample `bp/` and `panorama/`
     files into the CWD, and the BP/Panorama plugins read them from
     `etc_path/bp` / `etc_path/panorama`. Only when these match do the
     `/thruk/bp` and `/thruk/panorama` REST endpoints return data.
  2. Relative paths in the host `thruk_local.conf` resolve against the repo
     root, which is where `extra_prepare` places the naemon configuration copy
     (see below).

This mirrors how `make docs` and the CI (`citest`) run: from the repository
root with a `thruk_local.conf` in the CWD.

## Files in this scenario

    Makefile              - scenario overrides (pre_prepare, extra_prepare, ...)
    docker-compose.yml    - container definition, port forwarding, mounts
    thruk_local.conf      - HOST-side thruk config template (backend + configtool)
    omd/Dockerfile        - OMD container image
    omd/playbook.yml      - ansible provisioning of the OMD site
    omd/test.cfg          - naemon host/service definitions
    omd/testuser.cfg      - naemon contact/contactgroup definitions
    t/095-doc_*.t         - symlinks to the three doc tests

### Host-side `thruk_local.conf`

Installed by `pre_prepare` as `thruk_local.d/docs-scenario.conf` (relative
paths resolve against the test CWD = repo root). The file carries a header
comment explaining its origin; edit the template here, not the generated copy:

    <Component Thruk::Backend>
        <peer>
            name    = naemon
            id      = abcd
            type    = livestatus
            <options>
                peer = 127.0.0.3:60557     <- docker-forwarded livestatus TCP socket
            </options>
            <configtool>
                core_conf = var/tmp/naemon/naemon.cfg   <- relative to repo root
            </configtool>
        </peer>
    </Component>

    <Component Thruk::Plugin::ConfigTool>
        thruk    = ./thruk_local.conf
        cgi.cfg  = ./cgi.cfg
    </Component>

    <Component Thruk::Plugin::BP>
        objects_save_file      = ./var/tmp/thruk_bp_generated.cfg
        objects_templates_file = ./var/tmp/thruk_templates.cfg
    </Component>

The peer `<configtool>` section is the critical piece for the `/config/*`
REST endpoints: `_set_object_model()` only builds the object model for backends
that have a `<configtool>` section with a readable `core_conf`.

## Cold start walkthrough

### 1. `make clean`

The common `clean` target (`Makefile.common`) tears the container down and
clears the thruk cache. The scenario `extra_clean` removes the files that
`prepare` drops into the repository root:

  - `thruk_local.d/docs-scenario.conf`
  - `var/tmp/naemon/`
  - the marker `thruk_local.conf` (only if it was created by this scenario)

and restores any repo-root `thruk_local.conf` that `pre_prepare` had moved
aside (see below), so the repository root is back to its original state.

### 2. `make prepare`

`Makefile.common` `prepare` runs these steps in order:

  1. `base_images` - builds `local/thruk-labs-rocky:nightly` from
     `t/scenarios/_common` if not already built.
  2. `pre_prepare` - installs the scenario `thruk_local.conf` into the
     repository root as `thruk_local.d/docs-scenario.conf`. If the repository
     root already has a non-empty `thruk_local.conf` (e.g. a developer config,
     or the one `make citest` copies from `t/ci/thruk_local.conf`), it is moved
     aside to `thruk_local.conf.docs-backup` so no other backend peers interfere
     with the tests; a minimal marker `thruk_local.conf` is then created (the
     doc_rest test gates on `-s 'thruk_local.conf'`). The backup is restored by
     `extra_clean`. At this point `var/tmp/naemon` does not exist yet; the
     config only references its future location.
  3. `docker compose build` - builds the `omd` image.
  4. `mkdir -p var/tmp && chmod 777` - creates the shared writable directory.
  5. `docker compose up -d` - starts the container. On boot, ansible runs
     `omd/playbook.yml`, which:
        - sets `APACHE_MODE=own`, `PNP4NAGIOS=off`, `LIVESTATUS_TCP=on`
        - copies `omd/test.cfg` and `omd/testuser.cfg` into the site's
          `etc/naemon/conf.d/`
        - copies the naemon `example.cfg` and creates the thruk `secret.key`
  6. waits until the log shows `Starting Apache web server`.
  7. `extra_prepare`:

         docker compose exec ... omd sh -c \
             'rm -rf /var/tmp/naemon && cp -a /omd/sites/demo/etc/naemon /var/tmp/naemon && chmod -R a+rwX /var/tmp/naemon'
         printf 'cfg_dir=conf.d\nresource_file=resource.cfg\n' > ../../../var/tmp/naemon/naemon.cfg
         $(MAKE) pre_prepare

     This copies the container's naemon configuration through the shared
     `var/tmp` mount (repo `var/tmp` <-> container `/var/tmp`) into
     **`<repo>/var/tmp/naemon`**, making it readable and writable on the host.
     The OMD-generated `naemon.cfg` (which references `/omd/sites/demo`) is
     replaced with a minimal one whose `cfg_dir`/`resource_file` resolve
     relative to the copy's own directory, so thruk's parser can follow them on
     the host. Finally `pre_prepare` is re-run to refresh
     `thruk_local.d/docs-scenario.conf`.

After `make prepare` the following exist on the host:

  - `thruk_local.d/docs-scenario.conf` at the repository root (plus a minimal
    marker `thruk_local.conf` only if there was none before)
  - `var/tmp/naemon/` (`conf.d/`, `resource.cfg`, `naemon.cfg`)
  - the `docs-omd-1` container, forwarding
    `127.0.0.3:60080 -> 80` (Thruk web) and `127.0.0.3:60557 -> 6557`
    (naemon livestatus over TCP)

### 3. `make test`

  1. `wait_start` (scenario override) clears the cache, then polls until both
     the login page responds (`curl 127.0.0.3:60080/...`) **and**
     `./script/thruk -l | grep OK` reports the backend - i.e. the livestatus
     TCP socket at `127.0.0.3:60557` is answering.
  2. `disable_watcher_from_tests` suppresses container-side thruk restarts.
  3. `test_harness` runs the three doc tests on the host (CWD = repo root).
  4. `extra_test` is a no-op here (there are no container-side local tests).
  5. `enable_watcher_from_tests`, then the shared `test_docker_logs` runs the
     `999-docker-logs.t` / `999-perl-zombies.t` checks.

## How the three tests get their data

### livestatus livedata (all tests)

The host scripts and the in-process Thruk use `THRUK_CONFIG` = repo root, so
they load `thruk_local.d/docs-scenario.conf` (merged with any repo-root
`thruk_local.conf`) and connect to the backend peer
`127.0.0.1:60557`. `docker-compose.yml` forwards that port to the container's
naemon livestatus TCP port (enabled via `LIVESTATUS_TCP=on`). That is the data
path for every livestatus query.

### configtool data (`095-doc_rest.t` only)

The doc generation script probes `/config/files`, `/config/diff` and
`/config/precheck`. Those endpoints build a `Monitoring::Config` object model
from the peer `<configtool> core_conf`. `core_conf` points at
`var/tmp/naemon/naemon.cfg` (relative to the test CWD = repo root), which is
why the naemon configuration must be copied to the host in `extra_prepare`.
The `/config/diff` endpoint additionally needs at least one changed file; the
script creates one up front via `POST /r/config/objects` (host
`docs-update-test` in a new `docs-update-test.cfg`) and reverts it afterwards.

### bp / panorama data (`095-doc_rest.t` only)

The script drops `bp/9999.tbp` and `panorama/9999.tab` into the CWD (= repo
root). Because `THRUK_CONFIG` is the repo root, `etc_path` equals the CWD, so
the BP and Panorama plugins find these files and `/thruk/bp` and
`/thruk/panorama` return data.

## What `095-doc_rest.t` actually checks

It runs, in order:

    ./script/thruk bp all >/dev/null
    ./script/thruk_update_docs_rest.pl
    diff -Bbwu docs/documentation/rest.asciidoc        docs/documentation/rest.asciidoc.tst
    diff -Bbwu docs/documentation/rest_commands.asciidoc docs/documentation/rest_commands.asciidoc.tst
    diff -Bbwu docs/documentation/commands.html        docs/documentation/commands.html.tst
    diff -Bbwu lib/Thruk/Controller/Rest/V1/cmd.pm     cmd.pm.tst

`thruk_update_docs_rest.pl` regenerates the REST API documentation from the
live backend and writes `*.tst` files (in `TEST_MODE`). The diffs fail whenever
the committed docs are out of date relative to the code - which is exactly what
you want when e.g. merging changes that add new REST attributes (such as the
`business_process_*` columns under `/thruk/stats`).

If a diff fails, the committed documentation is stale and must be regenerated
with the non-test mode of the same script:

    %> cd $REPO_ROOT
    %> PERL5LIB=lib ./script/thruk_update_docs_rest.pl

which updates `docs/documentation/rest.asciidoc`,
`docs/documentation/rest_commands.asciidoc`, `docs/documentation/commands.html`,
`lib/Thruk/Controller/Rest/V1/cmd.pm` and `lib/Thruk/Controller/Rest/V1/docs.pm`.

## Notes

  - `thruk_local.d/`, `var/tmp/naemon` and the marker `thruk_local.conf` are
    git-ignored and removed by `make clean` (`extra_clean`). Any existing
    repo-root `thruk_local.conf` (developer config or the one copied by
    `make citest`) is moved aside to `thruk_local.conf.docs-backup` during the
    run so only the scenario backend is active, and is restored again by
    `extra_clean`. In the unlikely event of a crash before `make clean`, the
    backup file is left behind (harmless and git-ignored).
  - `core_conf` uses a relative path on purpose: all test processes run with
    CWD = repo root, so the scenario works from any checkout location.
  - The scenario does not export `PLACK_TEST_EXTERNALSERVER_URI` on purpose:
    `095-doc_rest.t` skips when it is set (it is a *local* test, unlike the
    `rest_api` scenario tests).
