#!/usr/bin/env bash

# install dependencies not included in archlinux:base-devel
pacman -Sy --needed --noconfirm \
  jq