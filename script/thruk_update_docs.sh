#!/bin/bash
set -e

if ! command -v pandoc >/dev/null 2>&1; then
    echo "please install the pandoc package" >&2
    exit 1
fi

cd docs/manpages || { echo "please run from the project root dir" >&2; exit 1; }
tmp=''
trap 'test -z "$tmp" || rm -f -- "$tmp"' EXIT

if [ thruk8.md -nt thruk.8 ]; then
    tmp=$(mktemp ./thruk.8.XXXXXX)
    pandoc -s --to man thruk8.md -o "$tmp"
    chmod 644 "$tmp"
    mv "$tmp" thruk.8
fi

for file in thruk naglint nagexp nagimp; do
    if [ ! -e "$file.3" ] || [ "../../script/$file" -nt "$file.3" ]; then
        tmp=$(mktemp "./$file.3.XXXXXX")
        pod2man -s 3 -n "$file" "../../script/$file" > "$tmp"
        chmod 644 "$tmp"
        mv "$tmp" "$file.3"
    fi
done
