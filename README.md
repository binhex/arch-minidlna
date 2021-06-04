**Application**

[MiniDLNA](http://minidlna.sourceforge.net/)

**Description**

ReadyMedia (formerly known as MiniDLNA) is a simple media server software, with the aim of being fully compliant with DLNA/UPnP-AV clients. It is developed by a NETGEAR employee for the ReadyNAS product line.

**Build notes**

Latest stable release of MiniDLNA.

**Usage**
```
docker run -d \
    --net="host" \
    --name=<container name> \
    -v <path for media files>:/media \
    -v <path for config files>:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e SCHEDULE_SCAN=<yes|no> \
    -e SCHEDULE_SCAN_DAYS=<00-06> \
    -e SCHEDULE_SCAN_HOURS=<00-23> \
    -e SCAN_ON_BOOT=<yes|no> \
    -e UMASK=<umask for created files> \
    -e PUID=<uid for user> \
    -e PGID=<gid for user> \
    binhex/arch-minidlna
```

Please replace all user variables in the above command defined by <> with the correct values.

**Access application**

N/A, CLI only.

**Example**
```
docker run -d \
    --net="host" \
    --name=minidlna \
    -v /media/pictures:/media \
    -v /apps/docker/minidlna:/config \
    -v /etc/localtime:/etc/localtime:ro \
    -e SCHEDULE_SCAN=yes \
    -e SCHEDULE_SCAN_DAYS=06 \
    -e SCHEDULE_SCAN_HOURS=02 \
    -e SCAN_ON_BOOT=no \
    -e UMASK=000 \
    -e PUID=0 \
    -e PGID=0 \
    binhex/arch-minidlna
```

**Notes**

User ID (PUID) and Group ID (PGID) can be found by issuing the following command for the user you want to run the container as:-

```
id <username>
```

You cannot specify the port the docker container uses, it requires full access to the hosts nic and thus the -p flag is not used. Additional configuration for this application can be done by modifying the /config/minidlna.conf file.
___
If you appreciate my work, then please consider buying me a beer  :D

[![PayPal donation](https://www.paypal.com/en_US/i/btn/btn_donate_SM.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=MM5E27UX6AUU4)

[Documentation](https://github.com/binhex/documentation) | [Support forum](http://lime-technology.com/forum/index.php?topic=45841.0)