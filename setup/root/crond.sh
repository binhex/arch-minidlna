#!/bin/bash

# add in cron job to rescan media
cat <<EOF > /etc/cron.d/rescan_media_cron
# scheduled task to rescan media library
00 "${SCHEDULE_SCAN_HOURS}" * * "${SCHEDULE_SCAN_DAYS}" /usr/bin/minidlnad -R

EOF

# give execution rights on the cron job
RUN chmod 0644 /etc/cron.d/rescan_media_cron
 
# run crond in foreground mode (minidlna running as daemon)
crond -n
