#!/usr/bin/zsh
set -o verbose
systemctl start reflector
pacman --noconfirm --sync --refresh --refresh --sysupgrade
