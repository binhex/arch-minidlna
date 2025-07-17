#!/bin/bash

# exit script if return code != 0
set -e

# app name from buildx arg, used in healthcheck to identify app and monitor correct process
APPNAME="${1}"
shift

# release tag name from buildx arg, stripped of build ver using string manipulation
RELEASETAG="${1}"
shift

# target arch from buildx arg
TARGETARCH="${1}"
shift

if [[ -z "${APPNAME}" ]]; then
	echo "[warn] App name from build arg is empty, exiting script..."
	exit 1
fi

if [[ -z "${RELEASETAG}" ]]; then
	echo "[warn] Release tag name from build arg is empty, exiting script..."
	exit 1
fi

if [[ -z "${TARGETARCH}" ]]; then
	echo "[warn] Target architecture name from build arg is empty, exiting script..."
	exit 1
fi

# write APPNAME and RELEASETAG to file to record the app name and release tag used to build the image
echo -e "export APPNAME=${APPNAME}\nexport IMAGE_RELEASE_TAG=${RELEASETAG}" >> '/etc/image-build-info'

# ensure we have the latest builds scripts
refresh.sh

# pacman packages
####

# call pacman db and package updater script
source upd.sh

# define pacman packages
pacman_packages="cronie minidlna"

# install compiled packages using pacman
if [[ ! -z "${pacman_packages}" ]]; then
	pacman -S --needed $pacman_packages --noconfirm
fi

# aur packages
####

# define aur packages
aur_packages=""

# call aur install script (arch user repo)
source aur.sh

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

# define comma separated list of paths
install_paths="/home/nobody"

# split comma separated string into list for install paths
IFS=',' read -ra install_paths_list <<< "${install_paths}"

# process install paths in the list
for i in "${install_paths_list[@]}"; do

	# confirm path(s) exist, if not then exit
	if [[ ! -d "${i}" ]]; then
		echo "[crit] Path '${i}' does not exist, exiting build process..." ; exit 1
	fi

done

# convert comma separated string of install paths to space separated, required for chmod/chown processing
install_paths=$(echo "${install_paths}" | tr ',' ' ')

# set permissions for container during build - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
chmod -R 775 ${install_paths}

# create file with contents of here doc, note EOF is NOT quoted to allow us to expand current variable 'install_paths'
# we use escaping to prevent variable expansion for PUID and PGID, as we want these expanded at runtime of init.sh
cat <<EOF > /tmp/permissions_heredoc

# get previous puid/pgid (if first run then will be empty string)
previous_puid=\$(cat "/root/puid" 2>/dev/null || true)
previous_pgid=\$(cat "/root/pgid" 2>/dev/null || true)

# if first run (no puid or pgid files in /tmp) or the PUID or PGID env vars are different
# from the previous run then re-apply chown with current PUID and PGID values.
if [[ ! -f "/root/puid" || ! -f "/root/pgid" || "\${previous_puid}" != "\${PUID}" || "\${previous_pgid}" != "\${PGID}" ]]; then

	# set permissions inside container - Do NOT double quote variable for install_paths otherwise this will wrap space separated paths as a single string
	chown -R "\${PUID}":"\${PGID}" ${install_paths}

fi

# write out current PUID and PGID to files in /root (used to compare on next run)
echo "\${PUID}" > /root/puid
echo "\${PGID}" > /root/pgid

EOF

# replace permissions placeholder string with contents of file (here doc)
sed -i '/# PERMISSIONS_PLACEHOLDER/{
    s/# PERMISSIONS_PLACEHOLDER//g
    r /tmp/permissions_heredoc
}' /usr/bin/init.sh
rm /tmp/permissions_heredoc

# env vars
####

# create file with contets of here doc
cat <<'EOF' > /tmp/envvars_heredoc
export SCAN_ON_BOOT=$(echo "${SCAN_ON_BOOT}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
if [[ ! -z "${SCAN_ON_BOOT}" ]]; then
	echo "[info] SCAN_ON_BOOT defined as '${SCAN_ON_BOOT}'" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "[warn] SCAN_ON_BOOT not defined,(via -e SCAN_ON_BOOT), defaulting to 'no'" | ts '%Y-%m-%d %H:%M:%.S'
	export SCAN_ON_BOOT="no"
fi

export SCHEDULE_SCAN_DAYS=$(echo "${SCHEDULE_SCAN_DAYS}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
if [[ ! -z "${SCHEDULE_SCAN_DAYS}" ]]; then
	echo "[info] SCHEDULE_SCAN_DAYS defined as '${SCHEDULE_SCAN_DAYS}'" | ts '%Y-%m-%d %H:%M:%.S'
else
	echo "[warn] SCHEDULE_SCAN_DAYS not defined,(via -e SCHEDULE_SCAN_DAYS), defaulting to day '06'" | ts '%Y-%m-%d %H:%M:%.S'
	export SCHEDULE_SCAN_DAYS="06"
fi

export SCHEDULE_SCAN_HOURS=$(echo "${SCHEDULE_SCAN_HOURS}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')
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
}' /usr/bin/init.sh
rm /tmp/envvars_heredoc

# cleanup
cleanup.sh
