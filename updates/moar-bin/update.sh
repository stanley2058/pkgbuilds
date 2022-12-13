#!/usr/bin/env bash

GITHUB_API="https://api.github.com/repos/walles/moar/releases/latest"
VERSION=$(curl -sH "Accept: application/vnd.github+json" "$GITHUB_API" | jq -r ".tag_name" | sed -e 's/v//')

curl -sL "https://github.com/walles/moar/archive/refs/tags/v${VERSION}.tar.gz" > "$TMP/moar.tar.gz"
SHA256SUM=$(sha256sum "$TMP/moar.tar.gz" | awk '{ print $1 }')

sed -i "s/pkgver=.*/pkgver=$VERSION/" "$PKG_ROOT/PKGBUILD"
sed -i "s/sha256sums=('[^']*')/sha256sums=('$SHA256SUM')/" "$PKG_ROOT/PKGBUILD"

pushd "$PKG_ROOT" &>/dev/null || exit 1
makepkg --printsrcinfo > .SRCINFO
popd &>/dev/null || exit 1