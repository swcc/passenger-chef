FROM phusion/passenger-ruby20:latest
# Set correct environment variables.
ENV HOME /root
# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]


RUN apt-get -y update

# Install Chef
RUN apt-get -y install curl build-essential libxml2-dev libxslt-dev git wget lsb-release
RUN curl -L https://www.opscode.com/chef/install.sh | bash
RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc

# Install Berkshelf with chef's own ruby
# But first install gecode from binaries (compilation fails when installed by the gem)
# Install libgecode-dev version 3
# see: https://github.com/berkshelf/berkshelf/issues/1138#issuecomment-42423440
RUN cd /tmp; wget fr.archive.ubuntu.com/ubuntu/pool/universe/g/gecode/libgecodeflatzinc32_3.7.3-1_amd64.deb
RUN cd /tmp; wget fr.archive.ubuntu.com/ubuntu/pool/universe/g/gecode/libgecodegist32_3.7.3-1_amd64.deb
RUN cd /tmp; wget fr.archive.ubuntu.com/ubuntu/pool/universe/g/gecode/libgecode32_3.7.3-1_amd64.deb
RUN cd /tmp; wget fr.archive.ubuntu.com/ubuntu/pool/universe/g/gecode/libgecode-dev_3.7.3-1_amd64.deb

RUN apt-get install -y libqtcore4 libqtgui4 libqt4-dev libboost-dev
RUN cd /tmp; dpkg -i libgecode32_3.7.3-1_amd64.deb
RUN cd /tmp; dpkg -i libgecodegist32_3.7.3-1_amd64.deb
RUN cd /tmp; dpkg -i libgecodeflatzinc32_3.7.3-1_amd64.deb
RUN cd /tmp; dpkg -i libgecode-dev_3.7.3-1_amd64.deb

RUN USE_SYSTEM_GECODE=1 /opt/chef/embedded/bin/gem install berkshelf

# Enable startup script
RUN mkdir -p /etc/my_init.d
RUN ln -s /home/app/startup.sh /etc/my_init.d/startup.sh

# Enable passenger+nginx
RUN rm -f /etc/service/nginx/down


# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

