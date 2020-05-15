FROM centos:7
WORKDIR /vmail
ENV MIAL_DOMAIN=web.me
COPY ./install.sh /vmail/install.sh
COPY ./start.sh /vmail/start.sh
COPY ./soft /vmail/soft
RUN yum clean all && rm -rf /var/cache/yum && \
yum update -y && yum install git curl wget vim nano net-tools openssh-server openssh-client -y && \
sh install.sh $MIAL_DOMAIN && \
yum erase git -y && yum clean all && rm -rf /var/cache/yum && rm -rf /vmail/install.sh && rm -rf /vmail/soft && \
touch /var/log/secure /etc/sysconfig/network && \
systemctl mask getty@tty1.service
STOPSIGNAL SIGRTMIN+4
CMD  ["/usr/sbin/init"]
