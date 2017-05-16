#!/bin/bash

# if minidlna config file doesnt exist then copy default to host config volume
if [ ! -f "/config/minidlna.conf" ]; then

	# copy over customised config
	cp /etc/minidlna.conf /config/

fi

# check if scan on boot is defined, if defined then add flag to scan (-R)
# minidlna is running in background (no -S flag)
if [[ "${SCAN_ON_BOOT}" == "yes" ]]; then
	/usr/bin/minidlnad -R -f /config/minidlna.conf
else
	/usr/bin/minidlnad -f /config/minidlna.conf
fi
