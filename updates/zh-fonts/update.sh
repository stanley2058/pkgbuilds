#!/usr/bin/env bash

source "$PKG_ROOT/PKGBUILD"

GITHUB_REPO=(
    "ButTaiwan/genyo-font"
    "ButTaiwan/genwan-font"
    "ButTaiwan/genseki-font"
    "ButTaiwan/gensen-font"
    "ButTaiwan/genyog-font"
)

declare -A GITHUB_REPO_SOURCE_MAPPING
GITHUB_REPO_SOURCE_MAPPING['genyo']="https://github.com/ButTaiwan/genyo-font/releases/download/#VERSION/GenKiMin2-ttc.zip"
GITHUB_REPO_SOURCE_MAPPING['genwan']="https://github.com/ButTaiwan/genwan-font/releases/download/#VERSION/GenWanMin2-ttc.zip"
GITHUB_REPO_SOURCE_MAPPING['genseki']="https://github.com/ButTaiwan/genseki-font/releases/download/#VERSION/GenSekiGothic2-ttc.zip"
GITHUB_REPO_SOURCE_MAPPING['gensen']="https://github.com/ButTaiwan/gensen-font/releases/download/#VERSION/GenSenRounded2-ttc.zip"
GITHUB_REPO_SOURCE_MAPPING['genyog']="https://github.com/ButTaiwan/genyog-font/releases/download/#VERSION/GenKiGothic2-ttc.zip"

current_pkgver=$pkgver
target_version=

declare -A NEW_VERSIONS
MISMATCHED=()
for ((i = 0; i < ${#GITHUB_REPO[@]}; i++)); do
    url="https://api.github.com/repos/${GITHUB_REPO[$i]}/releases/latest"
    current_source_ver=$(echo "${source[$i]}" | sed -r 's/.*download\/v([0-9.]*).*/\1/')
    ver=$(curl -fsSL -H "Accept: application/vnd.github+json" "$url" | jq -r '.tag_name | ltrimstr("v")')

    if [[ -z "$ver" || "$ver" == "null" ]]; then
        echo "Failed to fetch release version from $url" >&2
        exit 1
    fi

    if [[ -z "$target_version" ]]; then
        target_version=$ver
    elif [[ "$target_version" != "$ver" ]]; then
        echo "Mismatched upstream versions: expected $target_version but got $ver from ${GITHUB_REPO[$i]}" >&2
        exit 1
    fi

    if [[ "$current_source_ver" != "$ver" ]]; then
        MISMATCHED+=("${_fonts[$i]}")
    fi

    NEW_VERSIONS["${_fonts[$i]}"]=$ver
done

declare -A updated_shasum
declare -A updated_src
for ((i = 0; i < ${#_fonts[@]}; i++)); do
    id=${_fonts[$i]}
    updated_shasum[$id]=${sha256sums[$i]}
    updated_src[$id]=${source[$i]}
done

echo "Current package version: $current_pkgver"
echo "Upstream version: $target_version"
echo "Mismatched:" "${MISMATCHED[@]}"
echo "New versions:" "${NEW_VERSIONS[@]}"

if [[ "$current_pkgver" != "$target_version" || "${#MISMATCHED[@]}" -gt 0 ]]; then
    new_version=$target_version

    for id in "${_fonts[@]}"; do
        ver="${NEW_VERSIONS[$id]}"
        src_url=${GITHUB_REPO_SOURCE_MAPPING[$id]}
        fname="$(echo "$src_url" | sed -r "s/.*#VERSION\/(.*)/\1/")"
        src=$(echo "$src_url" | sed -r "s/#VERSION/v$ver/")
        curl -fsSL "$src" >"$TMP/$fname"
        updated_shasum[$id]=$(sha256sum "$TMP/$fname" | awk '{ print $1 }')
        updated_src[$id]="${id}-${new_version}.zip::$src"
    done

    src="source=("
    shasum="sha256sums=("
    for id in "${_fonts[@]}"; do
        src+="\n    \"${updated_src[$id]}\""
        shasum+="\n    \"${updated_shasum[$id]}\""
    done
    src+="\n)"
    shasum+="\n)"

    # update version
    sed -i "s/pkgver=.*/pkgver=$new_version/" "$PKG_ROOT/PKGBUILD"
    sed -i 's/pkgrel=.*/pkgrel=1/' "$PKG_ROOT/PKGBUILD"

    # update src & sum
    sed -zr "s|source=\([^)]*\)|$src|g" -i "$PKG_ROOT/PKGBUILD"
    sed -zr "s|sha256sums=\([^)]*\)|$shasum|g" -i "$PKG_ROOT/PKGBUILD"

    pushd "$PKG_ROOT" &>/dev/null || exit 1
    update_srcinfo
    popd &>/dev/null || exit 1
fi
