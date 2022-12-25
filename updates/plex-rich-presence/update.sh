#!/usr/bin/env bash

CURRENT_VER=$(grep "pkgver=" "$PKG_ROOT/PKGBUILD" | sed -r 's/pkgver=//')
GITHUB_API="https://api.github.com/repos/Ombrelin/plex-rich-presence/releases/latest"
RELEASE_JSON=$(curl -H "Accept: application/vnd.github+json" "$GITHUB_API")

VERSION=$(echo "$RELEASE_JSON" | jq -r ".tag_name" | sed -e 's/v//')
LATEST_URL=$(\
    echo "$RELEASE_JSON" \
    | jq -r ".assets" \
    | grep -E 'browser_download_url.*.deb' \
    | sed -r 's/.*(https.*deb).*/\1/' \
)

echo "Current version: $CURRENT_VER"
echo "Upstream version: $VERSION"

[ -z "$VERSION" ] && exit 1

if [ "$CURRENT_VER" != "$VERSION" ]; then
    curl -L "$LATEST_URL" > "$TMP/plex-rich-presence.deb"
    SHA256SUM=$(sha256sum "$TMP/plex-rich-presence.deb" | awk '{ print $1 }')

    sed -i "s|source=.*|source=('$LATEST_URL')|" "$PKG_ROOT/PKGBUILD"
    update_package_version "$PKG_ROOT" "$VERSION" "$SHA256SUM"
fi

