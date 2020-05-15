# +----------------------------------------------------------------------
# | Mail
# +----------------------------------------------------------------------
# | Copyright (c) 2016 http://ewomail.com All rights reserved.
# +----------------------------------------------------------------------
# | Licensed ( http://ewomail.com/license.html)
# +----------------------------------------------------------------------
# | Author: oscode <1290026290@qq.com>
# sh ./start.sh $1
# +----------------------------------------------------------------------
#!/bin/bash
cur_dir=`pwd`
domain=$1
set -o pipefail
stty erase ^h
setenforce 0

dovecot_install(){
    rpm -ivh $cur_dir/soft/centos7-dovecot-2.2.33.2-el6.x86_64.rpm
}

spf_install(){
    cp -f $cur_dir/soft/postfix-policyd-spf-perl /usr/libexec/postfix/
    chmod -R 755 /usr/libexec/postfix/postfix-policyd-spf-perl
}

amavis_install(){
    yum -y install amavisd-new
    # yum -y install clamav-server clamav-server-systemd iptables-services iptables
    # freshclam

    # cp -f $cur_dir/soft/clamd.amavisd /etc/sysconfig/clamd.amavisd
    # cp -f $cur_dir/soft/clamd.amavisd.conf /etc/tmpfiles.d/clamd.amavisd.conf
    # cp -f $cur_dir/soft/clamd@.service /usr/lib/systemd/system/clamd@.service
}

epel_install(){
    rpm -ivh $cur_dir/soft/epel-release-latest-7.noarch.rpm
    # rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
}

config_file(){
    
    mkdir -p /etc/ssl/certs
    mkdir -p /etc/ssl/private
    
    cd /usr/local/dovecot/share/doc/dovecot
    sed -i "s/web.me/$domain/g" dovecot-openssl.cnf
    sh mkcert.sh
}

check_install(){
    
    if ! rpm -qa | grep postfix > /dev/null;then
        echo "postfix Installation failed"
        exit 1
    fi
    
    if ! rpm -qa | grep dovecot > /dev/null;then
        echo "dovecot Installation failed"
        exit 1
    fi
    
    if ! rpm -qa | grep amavisd-new > /dev/null;then
        echo "amavisd Installation failed"
        exit 1
    fi
    
    # if ! rpm -qa | grep clamav > /dev/null;then
    #     echo "clamav Installation failed"
    #     exit 1
    # fi
    
    if ! rpm -qa | grep spamassassin > /dev/null;then
        echo "spamassassin Installation failed"
        exit 1
    fi
    
}


init(){
    # sh ./start.sh $1
    if [ -z $domain ];then
        echo "Missing domain parameter"
        exit 1
    fi

    if rpm -qa | grep dovecot > /dev/null;then
        echo "installation failed,dovecot is installed"
        exit 1
    fi
    mv -f /vmail/start.sh /etc/rc.d/rc.local
    chmod +x /etc/rc.d/rc.local
    
    yum remove sendmail
    epel_install
    yum -y install postfix perl-DBI perl-JSON-XS perl-NetAddr-IP perl-Mail-SPF perl-Sys-Hostname-Long libtool-ltdl freetype* libpng* libjpeg* fail2ban

    
    cd $cur_dir
    
    dovecot_install
    amavis_install
    spf_install
    config_file
    check_install
    
    groupadd -g 5000 vmail
    useradd -M -u 5000 -g vmail -s /sbin/nologin vmail
    
    
    chown -R vmail:vmail /vmail/mail
    chmod -R 700 /vmail/mail
    
    mkdir -p /vmail/dkim
    chown -R amavis:amavis /vmail/dkim
    amavisd genrsa /vmail/dkim/mail.pem
    chown -R amavis:amavis /vmail/dkim
    
    # cd $cur_dir
    # chmod -R 700 ./init.php
    # /usr/local/php/bin/php ./init.php $domain > init_php.log
    
    # chmod -R 440 /vmail/config.ini


    systemctl stop firewalld.service 
    systemctl disable firewalld.service

    service iptables status
    iptables -F
    iptables save
    service   iptables stop
    chkconfig   iptables off
    
    
    # systemctl enable postfix dovecot amavisd spamassassin fail2ban clamd@amavisd iptables
    systemctl enable postfix dovecot spamassassin fail2ban amavisd

    # systemctl restart clamd@amavisd
    systemctl restart spamassassin postfix dovecot fail2ban

    systemctl restart amavisd
    # rm -rf /usr/lib/systemd/system/amavisd.service
    # systemctl daemon-reload
    # /usr/sbin/amavisd -u amavis -c /etc/amavisd/amavisd.conf
    # /usr/sbin/amavisd -u amavis -c /etc/amavisd/amavisd.conf reload
    # /usr/sbin/amavisd -u amavis -c /etc/amavisd/amavisd.conf stop

    
    # systemctl mask firewalld.service
    # systemctl stop firewalld.service
    # systemctl restart iptables

    
    echo "Complete installation"
}

init
