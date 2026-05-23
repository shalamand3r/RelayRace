#!/bin/sh
set -eu

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
SRC="$ROOT/tools/source"
OUT="$ROOT/tools/macprep/relayrace-ct-bypass-mac"
BUILD="$SRC/.build"
ARCH=$(uname -m)

if [ -z "${OPENSSL_PREFIX:-}" ]; then
    if [ "$ARCH" = "arm64" ]; then
        OPENSSL_PREFIX=/opt/homebrew/opt/openssl@3
    else
        OPENSSL_PREFIX=/usr/local/opt/openssl@3
    fi
fi

if [ ! -d "$OPENSSL_PREFIX" ]; then
    echo "OpenSSL not found at: $OPENSSL_PREFIX" >&2
    echo "Set OPENSSL_PREFIX=/path/to/openssl@3 and try again." >&2
    exit 1
fi

rm -rf "$BUILD"
mkdir -p "$BUILD/include"
ln -s "$SRC/choma/src" "$BUILD/include/choma"

clang \
    -arch "$ARCH" \
    -mmacosx-version-min=10.13 \
    -Wall \
    -Wno-pointer-to-int-cast \
    -Wno-unused-command-line-argument \
    -Wno-deprecated-declarations \
    -Wno-incompatible-pointer-types \
    -I"$BUILD/include" \
    -I"$OPENSSL_PREFIX/include" \
    "$ROOT/tools/ct_bypass_cli.c" \
    "$SRC/choma/tests/ct_bypass/main.c" \
    "$SRC"/choma/src/*.c \
    "$OPENSSL_PREFIX/lib/libcrypto.a" \
    -framework CoreFoundation \
    -o "$OUT"

echo "built $OUT"
lipo -info "$OUT" 2>/dev/null || file "$OUT"
