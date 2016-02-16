#!/bin/bash

# exit script if return code != 0
set -e

# define pacman packages
pacman_packages="minidlna"

# install pre-reqs
pacman -Syu --ignore filesystem --noconfirm
pacman -S --needed $pacman_packages --noconfirm

# set media to point at /media docker volume
sed -i 's/media_dir=\/opt/media_dir=\/media/g' /etc/minidlna.conf

# set logs to point at /config docker volume
sed -i 's/#log_dir=\/var\/log/log_dir=\/config/g' /etc/minidlna.conf

# set db to point at /config docker volume
sed -i 's/#db_dir=\/var\/cache\/minidlna/db_dir=\/config/g' /etc/minidlna.conf

# set process to run as user nobody
sed -i 's/user=minidlna/user=nobody/g' /etc/minidlna.conf

# set friendly name to MiniDLNA
sed -i 's/#friendly_name=My DLNA Server/friendly_name=MiniDLNA/g' /etc/minidlna.conf

# cleanup
yes|pacman -Scc
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /tmp/*
