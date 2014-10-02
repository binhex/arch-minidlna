#!/bin/sh

# if minidlna config file doesnt exist then copy default to host config volume
if [ ! -f "/config/minidlna.conf" ]; then

	# copy over default config
	cp /etc/minidlna.conf /config/
	
	# set permissions for user nobody group users
	chown -R nobody:users /config
	
else

	# copy config from host to docker
	cp /config/minidlna.conf /etc/
	
	# set permissions for user nobody group users
	chown -R nobody:users /etc/minidlna.conf
	
fi