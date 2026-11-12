# Maintain the documentation

This directory holds the Markdown sources for Thruk's documentation.
The public website lives in the separate `thruk_org` repository.
Preview and build commands reuse that repository's VitePress setup. This directory has no separate website configuration or npm dependencies.

## Preview the docs

Use Node.js 20 or later, npm, Git and Make. From this directory, run:

```sh
export THRUK_ORG_SRC=/src/thruk_org
make server
```

The Makefile delegates to the website's Makefile, sets `THRUK_SOURCE` to this Thruk checkout and lets the website install dependencies.
Open the local address printed by VitePress. The preview includes the full public website.
For a production build and local preview, run:

```sh
make build
make preview
```

If `THRUK_ORG_SRC` is unset, Make clones `https://github.com/sni/thruk_org.git` into `${TMPDIR:-/tmp}/thruk-org-$UID`.
It reuses an existing cached checkout without pulling or replacing local changes.
Update that checkout yourself when needed. An existing checkout must contain the VitePress website.
Until the migration is available upstream, use the local migrated checkout explicitly.

The build writes static files to `$THRUK_ORG_SRC/.vitepress/dist/`, not this directory.
Do not commit dependencies, caches or generated site output. Restart `make server` after changing canonical docs to stage them again.

## Edit a page

1. Edit the relevant Markdown file under `guides/`, `documentation/` or `development/`.
2. Keep commands, identifiers and example data exact.
3. Use STE80 prose: short sentences, active voice, plain words and one topic per paragraph.
4. Use fenced code blocks for commands, configuration, templates and output.
5. Use relative Markdown links and descriptive image text.
6. Preserve explicit heading IDs when you change headings. Existing links can depend on them.

Keep the website's navigation in sync when you add a new topic.
All theme, navigation and VitePress configuration belongs in the website repository.

## Validate changes

```sh
make test
make check
make build
```

These targets delegate to the website Makefile. `make check` validates canonical Markdown with the website's checker and renderer.
`make build` runs the public website's production build and generated-link checks.
`make test` also runs all website tests, including the Markdown checker regression tests.
The JavaScript checker and its tests belong to `thruk_org`; Thruk's Perl tests remain under `t/`.
The checks reject old source formats, Liquid syntax, unclosed code fences and broken local links or anchors.
They also require a page title and flag leftover AsciiDoc captions, duplicate heading text and loose configuration examples.
VitePress also checks links during the build. Do not disable those checks to hide a broken link.

For website-only resources, such as the generated Perl API reference, link to the public URL.
Do not add Jekyll includes or AsciiDoc source files.

## Generated references

The REST reference, external-command list and plugin help include generated content.
Update their source or generator before regenerating them.
Do not remove the generator markers in the Markdown files.

Run the pure Markdown-generator tests from the project root:

```sh
prove -Ilib t/095-doc_markdown.t t/095-doc_manpages.t
```

The man-page tests use stub converters and do not need Pandoc.
The full REST generator requires a configured test backend and writes test monitoring data.
Do not run it against production to check formatting.
The Livestatus sample generator also queries a backend. Use a test installation and review its output before committing it.

## Man pages

`manpages/thruk8.md` is the authored source for `manpages/thruk.8`.
The `.3` files come from the scripts' Perl documentation.
To regenerate the distributed man pages, install Pandoc and run `script/thruk_update_docs.sh` from the project root.
