**Application**

[MiniDLNA](http://minidlna.sourceforge.net/)

**Application description**

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
	binhex/arch-minidlna
```

**Notes**

You cannot specify the port the docker container uses, it requires full access to the hosts nic and thus the -p flag is not used.
Additional configuration for this application can be done by modifying the /config/minidlna.conf file.

[Support forum](http://lime-technology.com/forum/index.php?topic=38055.0)