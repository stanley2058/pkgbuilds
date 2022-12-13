#!/usr/bin/env bash

PKG_ROOT=$(pwd)
TMP="$PKG_ROOT/tmp"

update_srcinfo() {
  chown -R builder: .
  sudo -u builder makepkg --printsrcinfo | tee .SRCINFO &> /dev/null
  chown -R root:root .
}
export -f update_srcinfo
export TMP

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
