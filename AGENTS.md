# Thruk Monitoring WebUI

This is a web interface written in perl (using the Plack framework not Catalyst).

- It can be installed standalone but mostly used in an OMD site.
- Supports Naemon, Nagios compatible monitoring cores via the livestatus API.
- Documentation is in the `docs` folder and is merged into the thruk.org page.
- Test files are in the `t` folder and there are end-to-end tests in `t/scenarios/`.
- Perl code is in `lib/Thruk` (controllers in `lib/Thruk/Controller`, views in `lib/Thruk/Views`).
- Static assets live in `root` (web root), `themes` (styles), `templates` (HTML) and `ssi` (SSI includes).
- Plugins follow the same layout and are located in `plugins`
- Follows standard perl module layout, requires `perl Makefile.PL` to build `Makefile`.
- Then uses make targets for all tasks.
- Most tests require a configured backend in a `thruk_local.conf`.
- After changes in the `themes` folder, update css and themes with `make themes`.

## Rules

- Do not create additional Markdown files unless explicitly requested.
- Do not add additional dependencies unless really required.
- Keep comments short. Do not comment the obvious; only comment exceptional non-obvious things.
- Avoid duplicate code.
- Do not add unnecessary tests.
- Follow clean code principles; avoid bad practices like `goto`.
- Documentation, comments and general text must follow STE80 style (80% of the way to ASD-STE100).
- `make quicktest` validates successful changes.
- Do not invent Fake packages for Tests. That's usually not required.
- Keep code style to match existing files.
