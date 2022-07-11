#!/usr/bin/dumb-init /bin/bash

# if minidlna config file doesnt exist then copy default to host config volume
if [ ! -f "/config/minidlna.conf" ]; then

	# copy over customised config
	cp /etc/minidlna.conf /config/

fi

pid_file="/home/nobody/.config/minidlna/minidlna.pid"

# if minidlna pid file exist then remove before start (can be left over from previous run)
if [ -f "${pid_file}" ]; then
	echo "[info] PID file from previous run found, deleting file ${pid_file}..."
	rm -f "${pid_file}"
fi

# check if scan on boot is defined, if defined then add flag to scan (-R)
# minidlna is running in background (no -S flag)
if [[ "${SCAN_ON_BOOT}" == "yes" ]]; then
	/usr/bin/minidlnad -R -f /config/minidlna.conf -P "${pid_file}"
else
	/usr/bin/minidlnad -f /config/minidlna.conf -P "${pid_file}"
fi
