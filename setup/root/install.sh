#!/bin/bash

# exit script if return code != 0
set -e

# build scripts
####

# download build scripts from github
curl -o /tmp/scripts-master.zip -L https://github.com/binhex/scripts/archive/master.zip

# unzip build scripts
unzip /tmp/scripts-master.zip -d /tmp

# move shell scripts to /root
find /tmp/scripts-master/ -type f -name '*.sh' -exec mv -i {} /root/  \;

# pacman packages
####

# define pacman packages
pacman_packages="cronie"

# install compiled packages using pacman
if [[ ! -z "${pacman_packages}" ]]; then
	pacman -S --needed $pacman_packages --noconfirm
fi

# aor packages
####

# define arch official repo (aor) packages
aor_packages="minidlna"

# call aor script (arch official repo)
source /root/aor.sh

# aur packages
####

# define aur packages
aur_packages=""

# call aur install script (arch user repo)
source /root/aur.sh

# config
####

# set media to point at /media docker volume
sed -i 's~media_dir=/opt~media_dir=/media~g' /etc/minidlna.conf

# set logs to point at /config docker volume
sed -i 's~#log_dir=/var/log~log_dir=/config~g' /etc/minidlna.conf

# set db to point at /config docker volume
sed -i 's~#db_dir=/var/cache/minidlna~db_dir=/config~g' /etc/minidlna.conf

# set process to run as user nobody
sed -i 's~user=minidlna~user=nobody~g' /etc/minidlna.conf

# set friendly name to MiniDLNA
sed -i 's~#friendly_name=My DLNA Server~friendly_name=MiniDLNA~g' /etc/minidlna.conf

# container perms
####

# create file with contets of here doc
cat <<'EOF' > /tmp/permissions_heredoc
# set permissions inside container
chown -R "${PUID}":"${PGID}" /usr/bin/minidlnad /home/nobody
chmod -R 775 /usr/bin/minidlnad /home/nobody

EOF

# replace permissions placeholder string with contents of file (here doc)
sed -i '/# PERMISSIONS_PLACEHOLDER/{
    s/# PERMISSIONS_PLACEHOLDER//g
    r /tmp/permissions_heredoc
}' /root/init.sh
rm /tmp/permissions_heredoc

# env vars
####

# create file with contets of here doc
cat <<'EOF' > /tmp/envvars_heredoc
export SCAN_ON_BOOT=$(echo "${SCAN_ON_BOOT}" | sed -e 's/^[ \t]*//')
if [[ ! -z "${SCAN_ON_BOOT}" ]]; then
	echo "[info] SCAN_ON_BOOT defined as '${SCAN_ON_BOOT}'" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "[warn] SCAN_ON_BOOT not defined,(via -e SCAN_ON_BOOT), defaulting to 'no'" | ts '%Y-%m-%d %H:%M:%.S'
	export SCAN_ON_BOOT="no"
fi

export SCHEDULE_SCAN_DAYS=$(echo "${SCHEDULE_SCAN_DAYS}" | sed -e 's/^[ \t]*//')
if [[ ! -z "${SCHEDULE_SCAN_DAYS}" ]]; then
	echo "[info] SCHEDULE_SCAN_DAYS defined as '${SCHEDULE_SCAN_DAYS}'" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "[warn] SCHEDULE_SCAN_DAYS not defined,(via -e SCHEDULE_SCAN_DAYS), defaulting to day '06'" | ts '%Y-%m-%d %H:%M:%.S'
	export SCHEDULE_SCAN_DAYS="06"
fi

export SCHEDULE_SCAN_HOURS=$(echo "${SCHEDULE_SCAN_HOURS}" | sed -e 's/^[ \t]*//')
if [[ ! -z "${SCHEDULE_SCAN_HOURS}" ]]; then
	echo "[info] SCHEDULE_SCAN_HOURS defined as '${SCHEDULE_SCAN_HOURS}'" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "[warn] SCHEDULE_SCAN_HOURS not defined,(via -e SCHEDULE_SCAN_HOURS), defaulting to hour '02'" | ts '%Y-%m-%d %H:%M:%.S'
	export SCHEDULE_SCAN_HOURS="02"
fi

EOF

# replace envvars placeholder string with contents of file (here doc)
sed -i '/# ENVVARS_PLACEHOLDER/{
    s/# ENVVARS_PLACEHOLDER//g
    r /tmp/envvars_heredoc
}' /root/init.sh
rm /tmp/envvars_heredoc

# cleanup
yes|pacman -Scc
rm -rf /usr/share/locale/*
rm -rf /usr/share/man/*
rm -rf /tmp/*
