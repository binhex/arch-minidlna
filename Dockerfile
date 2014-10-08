FROM binhex/arch-base:2014100603
MAINTAINER binhex

# install application
#####################

# update package databases from the server
RUN pacman -Sy --noconfirm

# run pacman to install application
RUN pacman -S minidlna --noconfirm

# modify default minidlna.conf - defines media, db, and logs
RUN sed -i 's/media_dir=\/opt/media_dir=\/media/g' /etc/minidlna.conf
RUN sed -i 's/#db_dir=\/var\/cache\/minidlna/db_dir=\/config/g' /etc/minidlna.conf
RUN sed -i 's/#log_dir=\/var\/log/log_dir=\/config/g' /etc/minidlna.conf

# add start script - copies custom minidlna.conf file to host
ADD start.sh /run/minidlna/start.sh

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

ADD minidlna.conf /etc/supervisor/conf.d/minidlna.conf

# cleanup
#########

# remove unneeded apps from base-devel group - used for AUR package compilation
RUN pacman -Ru base-devel --noconfirm

# completely empty pacman cache folder
RUN pacman -Scc --noconfirm

# remove temporary files
RUN rm -rf /tmp/*

# run supervisor
################

# run supervisor
CMD ["supervisord", "-c", "/etc/supervisor.conf", "-n"]