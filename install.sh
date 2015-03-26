#!/bin/bash

# define pacman packages
pacman_packages="minidlna"

# install pre-reqs
pacman -Sy --noconfirm
pacman -S --needed $pacman_packages --noconfirm

# set config to point at docker volumes
sed -i 's/media_dir=\/opt/media_dir=\/media/g' /etc/minidlna.conf
sed -i 's/#log_dir=\/var\/log/log_dir=\/config/g' /etc/minidlna.conf	

# set permissions
chown -R nobody:users /home/nobody/ /usr/bin/minidlnad
chmod -R 775 /home/nobody/ /usr/bin/minidlnad

# cleanup
yes|pacman -Scc
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /tmp/*
