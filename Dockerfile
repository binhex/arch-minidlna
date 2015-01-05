FROM binhex/arch-base:2015010500
MAINTAINER binhex

# additional files
##################

# add start script - copies custom minidlna.conf file to host
ADD start.sh /run/minidlna/start.sh

# add supervisor conf file for app
ADD minidlna.conf /etc/supervisor/conf.d/minidlna.conf

# install app
#############

# install install app using pacman, set perms, cleanup
RUN pacman -Sy --noconfirm && \
	pacman -S minidlna --noconfirm && \
	sed -i 's/media_dir=\/opt/media_dir=\/media/g' /etc/minidlna.conf && \
	sed -i 's/#db_dir=\/var\/cache\/minidlna/db_dir=\/config/g' /etc/minidlna.conf && \
	sed -i 's/#log_dir=\/var\/log/log_dir=\/config/g' /etc/minidlna.conf && \	
	chown -R nobody:users /run/minidlna/ /usr/bin/minidlnad && \
	chmod -R 775 /run/minidlna/ /usr/bin/minidlnad && \	
	yes|pacman -Scc && \	
	rm -rf /usr/share/locale/* && \
	rm -rf /usr/share/man/* && \
	rm -rf /root/* && \
	rm -rf /tmp/*

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /media to host defined media path (used to read/write to media library)
VOLUME /media

# run supervisor
################

# run supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]