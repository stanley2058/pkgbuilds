#!/usr/bin/env bash

PKG_ROOT=$(pwd)
TMP="$PKG_ROOT/tmp"

update_srcinfo() {
    ID=$(id -u)
    if [ "$ID" == "0" ]; then
        chown -R builder: .
        sudo -u builder makepkg --printsrcinfo | tee .SRCINFO &> /dev/null
        chown -R root:root .
    else 
        makepkg --printsrcinfo | tee .SRCINFO &> /dev/null
    fi
}

update_package_version() {
    local pkg_root=$1
    local version=$2
    local sha256_sum=$3

    sed -i "s/pkgver=.*/pkgver=$version/" "$pkg_root/PKGBUILD"
    sed -i "s/sha256sums=('[^']*')/sha256sums=('$sha256_sum')/" "$pkg_root/PKGBUILD"

    pushd "$pkg_root" &>/dev/null || exit 1
    update_srcinfo
    popd &>/dev/null || exit 1
}

export -f update_srcinfo
export -f update_package_version
export TMP

git config --global --add safe.directory "$PKG_ROOT"
mkdir -p "$TMP"

# Runs all the scripts in the `updates` directory
pushd updates &>/dev/null || exit
for d in *; do
    echo Updating: "$d"

    pushd "$d" &>/dev/null || exit
    PKG_ROOT="$PKG_ROOT/$d" bash "update.sh"
    popd &>/dev/null || exit  
done
popd &>/dev/null || exit

rm -rf "$TMP"
