FROM binhex/arch-base:latest
MAINTAINER binhex

# additional files
##################

# add supervisor conf file for app
ADD setup/*.conf /etc/supervisor/conf.d/

# add start script - copies custom minidlna.conf file to host
ADD setup/start.sh /home/nobody/start.sh

# add bash scripts to set uid and gid and then set permissions
ADD setup/init.sh /root/init.sh

# add install bash script
ADD setup/install.sh /root/install.sh

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh /home/nobody/*.sh && \
	/bin/bash /root/install.sh

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /media to host defined media path (used to read/write to media library)
VOLUME /media

# set permissions
#################

# run script to set uid, gid and permissions
CMD ["/bin/bash", "/root/init.sh"]