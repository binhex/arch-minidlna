FROM binhex/arch-base:latest
LABEL org.opencontainers.image.authors = "binhex"
LABEL org.opencontainers.image.source = "https://github.com/binhex/arch-minidlna"

# additional files
##################

# add supervisor conf file for app
ADD build/*.conf /etc/supervisor/conf.d/

# add build bash script
ADD build/root/*.sh /root/

# get release tag name from build arg
ARG release_tag_name

# add run bash script
ADD run/root/*.sh /root/

# add run bash script
ADD run/nobody/*.sh /home/nobody/

# install app
#############

# make executable and run bash scripts to install app
RUN chmod +x /root/*.sh /home/nobody/*.sh && \
	/bin/bash /root/install.sh "${release_tag_name}"

# docker settings
#################

# set permissions
#################

# run script to set uid, gid and permissions
CMD ["/bin/bash", "/usr/local/bin/init.sh"]