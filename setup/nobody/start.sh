#!/bin/sh

# if minidlna config file doesnt exist then copy default to host config volume
if [ ! -f "/config/minidlna.conf" ]; then

	# copy over customised config
	cp /etc/minidlna.conf /config/

fi

# set permissions for user nobody
chmod -R 775 /config/
chown -R nobody:users /config/
