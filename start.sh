#!/bin/bash
# THIS FILE IS ADDED FOR COMPATIBILITY PURPOSES
#
# It is highly advisable to create own systemd services or udev rules
# to run scripts during boot instead of using this file.
#
# In contrast to previous versions due to parallel execution during boot
# this script will NOT be run after all other services.
#
# Please note that you must run 'chmod +x /etc/rc.d/rc.local' to ensure
# that this script will be executed during boot.
touch /var/lock/subsys/local
#==========================================
    
chown -R vmail:vmail /vmail/mail
chmod -R 700 /vmail/mail

mkdir -p /vmail/dkim
chown -R amavis:amavis /vmail/dkim

chown -R amavis:amavis /vmail/dkim

chmod 644 /etc/amavisd/amavisd.conf

# systemctl restart clamd@amavisd
systemctl restart spamassassin postfix dovecot fail2ban amavisd

systemctl restart amavisd
# /usr/sbin/amavisd -u amavis -c /etc/amavisd/amavisd.conf
# /usr/sbin/amavisd -u amavis -c /etc/amavisd/amavisd.conf reload
# /usr/sbin/amavisd -u amavis -c /etc/amavisd/amavisd.conf stop

# systemctl mask firewalld.service
# systemctl stop firewalld.service
# systemctl restart iptables

# tail -fn 0 /vmail/start.sh
