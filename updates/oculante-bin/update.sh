#!/usr/bin/env bash

CURRENT_VER=$(grep "pkgver=" "$PKG_ROOT/PKGBUILD" | sed -r 's/pkgver=//')
GITHUB_API="https://api.github.com/repos/woelper/oculante/releases/latest"
VERSION=$(curl -sH "Accept: application/vnd.github+json" "$GITHUB_API" | jq -r ".tag_name" | sed -e 's/v//')

echo "Current version: $CURRENT_VER"
echo "Upstream version: $VERSION"

[ -z "$VERSION" ] && exit 1

if [ "$CURRENT_VER" != "$VERSION" ]; then
    curl -sL "https://github.com/woelper/oculante/releases/download/$VERSION/oculante_linux" >"$TMP/oculante_linux"
    SHA256SUM=$(sha256sum "$TMP/oculante_linux" | awk '{ print $1 }')

    update_package_version "$PKG_ROOT" "$VERSION" "$SHA256SUM"
fi
