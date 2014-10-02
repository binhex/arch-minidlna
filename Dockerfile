FROM binhex/arch-base:2014091500
MAINTAINER binhex

# install application
#####################

# update package databases from the server
RUN pacman -Sy --noconfirm

# run pacman to install application
RUN pacman -S minidlna --noconfirm

# add custom minidlna config file - defines media, db, and logs
ADD minidlna.conf /etc/minidlna.conf

# docker settings
#################

# map /config to host defined config path (used to store configuration from app)
VOLUME /config

# map /media to host defined media path (used to read/write to media library)
VOLUME /media

# set permissions
#################

# change owner
RUN chown -R nobody:users /run/minidlna/ /usr/bin/minidlnad

# set permissions
RUN chmod -R 775 /run/minidlna/ /usr/bin/minidlnad

# add conf file
###############

ADD svr-minidlna.conf /etc/supervisor/conf.d/svr-minidlna.conf

# cleanup
#########

# completely empty pacman cache folder
RUN pacman -Scc --noconfirm

# remove temporary files
RUN rm -rf /tmp/*

# run supervisor
################

# run supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]