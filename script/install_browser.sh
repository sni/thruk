#!/bin/bash
#
# usage: ./install_browser.sh [<dest>] [<version>]
#
# makes sure there is a chromium browser which can be used to render PDFs and
# grafana graphs. If none is found, chrome-headless-shell is downloaded into
# /var/lib/thruk/browser. The last step is always a rendering test.
#
# see https://www.thruk.org/documentation/faq.html#chromium
#

###########################################################
# chrome-headless-shell version this thruk release has been tested with
BROWSER_VERSION=147.0.7727.117

###########################################################
DIR=$(cd "$(dirname "$BASH_SOURCE")" && pwd)
DEFAULT_DEST=/var/lib/thruk/browser
DEST=${1:-$DEFAULT_DEST}
VERSION=${2:-$BROWSER_VERSION}
URL="https://storage.googleapis.com/chrome-for-testing-public/$VERSION/linux64/chrome-headless-shell-linux64.zip"
FAQ="https://www.thruk.org/documentation/faq.html#chromium"
STAGE=""

fail() {
    echo "ERROR: $*" >&2
    [ -n "$STAGE" ] && rm -rf "$STAGE"
    exit 1
}

# run the rendering test with the given browser, it has to use exactly this one
selftest() {
    local browser=$1
    local out rc used
    echo "running rendering test with $browser"
    out=$(THRUK_BROWSER="$browser" "$DIR/html2pdf.sh" --selftest 2>&1)
    rc=$?
    echo "$out"
    if [ $rc -ne 0 ]; then
        fail "rendering test failed, see output above and $FAQ"
    fi
    used=$(echo "$out" | sed -n 's/^browser: //p' | head -n 1)
    if [ "$used" != "$browser" ]; then
        fail "rendering test used $used instead of $browser. THRUK_BROWSER is set in one of the rc files (/etc/thruk/thruk.env, ~/etc/thruk/thruk.env, ~/.thruk, ~/.profile) and overrides it."
    fi
}

###########################################################
# 1. is there a usable browser already?
FOUND=$("$DIR/html2pdf.sh" --find-browser 2>&1)
if [ $? -ne 0 ]; then
    case "$FOUND" in
        THRUK_BROWSER*) fail "$FOUND. Fix or remove this setting first." ;;
    esac
    if [ -n "$THRUK_BROWSER" ]; then
        fail "THRUK_BROWSER is set to $THRUK_BROWSER, but: $FOUND"
    fi
    FOUND=""
fi
case "$FOUND" in
    "")        ;;
    "$DEST"/*) echo "replacing browser in $DEST" ;;
    *)
        echo "using existing browser $FOUND, nothing to download"
        selftest "$FOUND"
        echo ""
        echo "browser $FOUND works, nothing installed"
        exit 0
        ;;
esac

###########################################################
# 2. requirements
ARCH=$(uname -m)
if [ "$ARCH" != "x86_64" ]; then
    fail "there is no chrome-headless-shell download for $ARCH. Please install the chromium package of your distribution (ex.: chromium or chromium-browser) and run this script again."
fi
type curl >/dev/null 2>&1 || fail "curl is required to download the browser, please install the package: curl"
type unzip >/dev/null 2>&1 || fail "unzip is required to unpack the browser, please install the package: unzip"

mkdir -p "$DEST" 2>/dev/null
if [ ! -d "$DEST" ] || [ ! -w "$DEST" ]; then
    fail "no permission to write into $DEST (run this script as root or choose another folder)"
fi

###########################################################
# 3. download into a staging folder, an existing installation stays in place until the new one works
STAGE=$(mktemp -d "$DEST/.staging.XXXXXX") || fail "cannot create staging folder in $DEST"
trap 'rm -rf "$STAGE"' EXIT
echo "downloading $URL"
if ! curl -fL -sS -o "$STAGE/browser.zip" "$URL"; then
    fail "download failed: $URL"
fi
if ! unzip -q "$STAGE/browser.zip" -d "$STAGE"; then
    fail "cannot unpack download from $URL"
fi
BINARY="$STAGE/chrome-headless-shell-linux64/chrome-headless-shell"
if [ ! -x "$BINARY" ]; then
    fail "download from $URL does not contain chrome-headless-shell-linux64/chrome-headless-shell"
fi
chmod -R a+rX "$STAGE/chrome-headless-shell-linux64"

###########################################################
# 4. missing libraries, they are not installed by this script
MISSING=$(ldd "$BINARY" 2>/dev/null | grep "not found")
if [ -n "$MISSING" ]; then
    echo "the browser requires some more libraries:"
    echo "$MISSING"
    echo ""
    echo "install them with:"
    if type dnf >/dev/null 2>&1; then
        echo "  dnf install alsa-lib atk at-spi2-atk at-spi2-core cups-libs libdrm libXcomposite libXdamage libxkbcommon libXrandr mesa-libgbm nss pango cairo"
    elif type yum >/dev/null 2>&1; then
        echo "  yum install alsa-lib atk at-spi2-atk at-spi2-core libdrm libXcomposite libXdamage libxkbcommon libXrandr mesa-libgbm nss cups-libs pango cairo"
    elif type zypper >/dev/null 2>&1; then
        echo "  zypper install libasound2 libatk-1_0-0 libatk-bridge-2_0-0 libatspi0 libcups2 libdrm2 libXcomposite1 libXdamage1 libxkbcommon0 libXrandr2 libgbm1 mozilla-nss libpango-1_0-0 libcairo2"
    elif type apt-get >/dev/null 2>&1; then
        ASOUND=libasound2
        if apt-cache show libasound2t64 >/dev/null 2>&1; then
            ASOUND=libasound2t64
        fi
        echo "  apt-get install libatk1.0-0 libatk-bridge2.0-0 libatspi2.0-0 libgbm1 libnspr4 libnss3 libxcomposite1 libxdamage1 libxfixes3 libxkbcommon0 libxrandr2 libpango-1.0-0 $ASOUND"
    else
        echo "  the package manager of your distribution"
    fi
    echo "and run this script again."
    fail "libraries are missing"
fi

###########################################################
# 5. rendering test with the downloaded browser
selftest "$BINARY"

###########################################################
# 6. put it in place
rm -rf "$DEST/chrome-headless-shell.old"
if [ -e "$DEST/chrome-headless-shell" ]; then
    mv "$DEST/chrome-headless-shell" "$DEST/chrome-headless-shell.old" || fail "cannot replace $DEST/chrome-headless-shell"
fi
if ! mv "$STAGE/chrome-headless-shell-linux64" "$DEST/chrome-headless-shell"; then
    [ -e "$DEST/chrome-headless-shell.old" ] && mv "$DEST/chrome-headless-shell.old" "$DEST/chrome-headless-shell"
    fail "cannot move browser to $DEST/chrome-headless-shell"
fi
rm -rf "$DEST/chrome-headless-shell.old"

echo ""
echo "chrome-headless-shell $VERSION successfully installed in $DEST/chrome-headless-shell"
if [ "$DEST" != "$DEFAULT_DEST" ]; then
    echo "this is not the default folder, add this line to /etc/thruk/thruk.env:"
    echo "THRUK_BROWSER=$DEST/chrome-headless-shell/chrome-headless-shell"
fi
exit 0
