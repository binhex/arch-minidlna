#!/bin/sh

# if minidlna config file doesnt exist then copy default to host config volume
if [ ! -f "/config/minidlna.conf" ]; then

	# copy over customised config
	cp /etc/minidlna.conf /config/
	
	# set permissions for user nobody group users
	chown -R nobody:users /config
		
fi

#run minidlna non daemonized
/usr/bin/minidlnad -d -R -f /config/minidlna.conf