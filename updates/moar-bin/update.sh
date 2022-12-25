#!/usr/bin/env bash

CURRENT_VER=$(grep "pkgver=" "$PKG_ROOT/PKGBUILD" | sed -r 's/pkgver=//')
GITHUB_API="https://api.github.com/repos/walles/moar/releases/latest"
VERSION=$(curl -H "Accept: application/vnd.github+json" "$GITHUB_API" | jq -r ".tag_name" | sed -e 's/v//')

echo "Current version: $CURRENT_VER"
echo "Upstream version: $VERSION"

[ -z "$VERSION" ] && exit 1

if [ "$CURRENT_VER" != "$VERSION" ]; then
    curl -L "https://github.com/walles/moar/archive/refs/tags/v${VERSION}.tar.gz" > "$TMP/moar.tar.gz"
    SHA256SUM=$(sha256sum "$TMP/moar.tar.gz" | awk '{ print $1 }')

    sed -i "s/pkgver=.*/pkgver=$VERSION/" "$PKG_ROOT/PKGBUILD"
    sed -i "s/sha256sums=('[^']*')/sha256sums=('$SHA256SUM')/" "$PKG_ROOT/PKGBUILD"

    pushd "$PKG_ROOT" &>/dev/null || exit 1
    update_srcinfo
    popd &>/dev/null || exit 1
fi
