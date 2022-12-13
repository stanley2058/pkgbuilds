#!/usr/bin/env bash

pacman -S --needed --noconfirm sudo
useradd builder
passwd -d builder
printf 'builder ALL=(ALL) ALL\n' | tee -a /etc/sudoers

chown -R builder: .
chown -R builder: .*
chown -R builder: ./*