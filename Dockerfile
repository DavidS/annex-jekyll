from ruby:2.7

ENV DEBIAN_FRONTEND noninteractive

RUN echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list.d/backports.list \
    && apt-get update \
    && apt-get install -y systemd initscripts locales locales-all wget apt-transport-https \
       build-essential pkg-config libmagickcore-6.q16-dev libssl-dev \
    && apt-get install -y -t buster-backports git-annex \
    && rm -f /lib/systemd/system/multi-user.target.wants/* \
      /etc/systemd/system/*.wants/* \
      /lib/systemd/system/local-fs.target.wants/* \
      /lib/systemd/system/sockets.target.wants/*udev* \
      /lib/systemd/system/sockets.target.wants/*initctl* \
      /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* \
      /lib/systemd/system/systemd-update-utmp* \
    && echo installing ssh after systemd to have it actually start up \
    && apt-get install -y openssh-server openssh-client \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && mkdir -p /var/run/sshd \
    && sed -ri -e "s/^#?UseDNS .*/UseDNS no/" /etc/ssh/sshd_config \
    && git config --system --replace-all core.hooksPath /usr/local/hooks \
    && mkdir -p /etc/ssh/sshd_config.d /srv/secrets/ssh /usr/local/hooks

COPY post-receive.sh /usr/local/hooks/post-receive

VOLUME [ "/sys/fs/cgroup" ]

STOPSIGNAL SIGRTMIN+3

CMD ["bash", "-evx", "-c", "for u in $USERS; do id ${u%:*} || adduser --uid ${u#*:} --disabled-password ${u%:*} ; done; cp -av /srv/secrets/ssh/ssh_host_* /etc/ssh/; echo -e \"Port $SSH_PORT\" >> /etc/ssh/sshd_config; echo starting systemd; exec /lib/systemd/systemd"]
