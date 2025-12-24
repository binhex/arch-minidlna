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
echo -e "export APPNAME=${APPNAME}\nexport IMAGE_RELEASE_TAG=${RELEASETAG}\n" >> '/etc/image-build-info'

# ensure we have the latest builds scripts
refresh.sh

# pacman packages
####

# call pacman db and package updater script
source upd.sh

# define pacman packages
pacman_packages="cronie minidlna"

# install compiled packages using pacman
if [[ -n "${pacman_packages}" ]]; then
	# arm64 currently targetting aor not archive, so we need to update the system first
	if [[ "${TARGETARCH}" == "arm64" ]]; then
		pacman -Syu --noconfirm
	fi
	pacman -S --needed $pacman_packages --noconfirm
fi

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

# In install.sh heredoc, replace the chown section:
cat <<EOF > /tmp/permissions_heredoc
install_paths="${install_paths}"
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
