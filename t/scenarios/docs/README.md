## Docs scenario

The `make docs` target in the repository root regenerates the documentation from live data, and therefore needs a running monitoring core (naemon, icinga, ...)
which is reachable over a livestatus socket and which has a full set of objects (hosts, hostgroups, contacts, contactgroups, services, servicegroups, ...) to query metadata for.

This scenario builds a complete OMD environment (naemon backend) in a container, forwards the naemon TCP livestatus socket and the Thruk web ports to the host, and then runs the three doc tests on the **host** against that backend:

  - `t/095-doc_coverage.t`         - every config key in `thruk.conf` must be documented
  - `t/095-doc_rest.t`             - regenerate the REST API docs and diff against the committed docs
  - `t/095-doc_roles_coverage.t`   - every possible role must be documented

## Quick Start

    %> cd t/scenarios/docs
    %> make clean
    %> make prepare
    %> make test

## Regenerating the documentation (`make docs`)

The scenario container can also serve as the backend for the repository root `make docs` target, which regenerates the docs from a live monitoring core:

    %> cd t/scenarios/docs
    %> make prepare          # starts the container and installs the repo-root thruk_local.d/docs-scenario.conf peer config
    %> cd $REPO_ROOT
    %> PERL5LIB=lib perl Makefile.PL # generates the Makefile
    %> PERL5LIB=lib make docs
    %> cd t/scenarios/docs && make clean
