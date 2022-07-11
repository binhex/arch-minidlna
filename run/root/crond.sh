#!/usr/bin/dumb-init /bin/bash

# add in cron job to rescan media
cat <<EOF > /etc/cron.d/rescan_media_cron
# scheduled task to rescan media library
00 "${SCHEDULE_SCAN_HOURS}" * * "${SCHEDULE_SCAN_DAYS}" \
pkill -f minidlnad ; \
rm -f /home/nobody/.config/minidlna/minidlna.pid ; \
/usr/bin/minidlnad -R -f /config/minidlna.conf -P /home/nobody/.config/minidlna/minidlna.pid

EOF

# give execution rights on the cron job
chmod 0644 /etc/cron.d/rescan_media_cron

# run crond in foreground mode (minidlna running as daemon)
crond -n
