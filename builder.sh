#!/usr/bin/env bash

pacman -S --needed --noconfirm sudo nodejs
useradd builder
passwd -d builder
printf 'builder ALL=(ALL) ALL\n' | tee -a /etc/sudoers
