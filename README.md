MiniDLNA
=========

MiniDLNA - http://minidlna.sourceforge.net/

Latest stable MiniDLNA release for Arch Linux.

**Pull image**

```
docker pull binhex/arch-minidlna
```

**Run container**

```
docker run -d --net="host" --name=<container name> -v <path for config files>:/config -v /etc/localtime:/etc/localtime:ro binhex/arch-minidlna
```

Please replace all user variables in the above command defined by <> with the correct values.

**Access application**

```
No webui, cli only - please configure minidlna via the minidlna.conf file located in your defined /config path from the above run command.
```

Note: You cannot specify the port the docker container uses, it requires full access to the hosts nic and thus the -p flag is ignored.