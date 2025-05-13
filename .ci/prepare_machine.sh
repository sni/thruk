#/bin/bash

set -ex

export DEBIAN_FRONTEND="noninteractive"

apt-get -y update
apt-get -y install \
    apache2 \
    apache2-utils \
    apt-transport-https \
    chrpath \
    coreutils \
    cpanminus \
    curl \
    debhelper \
    git \
    libclass-inspector-perl \
    libconfig-general-perl \
    libcpanel-json-xs-perl \
    libcrypt-rijndael-perl \
    libdate-calc-perl \
    libdate-manip-perl \
    libdatetime-perl \
    libdatetime-timezone-perl \
    libdbd-mysql-perl \
    libdbi-perl \
    libdevel-cycle-perl \
    libexcel-template-perl \
    libextutils-config-perl \
    libextutils-helpers-perl \
    libextutils-installpaths-perl \
    libfcgi-perl \
    libfile-bom-perl \
    libfile-slurp-perl \
    libgd-perl \
    libhtml-lint-perl \
    libhttp-message-perl \
    libio-socket-ip-perl \
    libio-string-perl \
    libjpeg62-dev \
    liblog-log4perl-perl \
    libmariadb-dev \
    libmime-lite-perl \
    libmodule-build-tiny-perl \
    libmodule-install-perl \
    libnet-http-perl \
    libpadwalker-perl \
    libperl-critic-perl \
    libperl-dev \
    libplack-perl \
    libpng-dev \
    libsocket-perl \
    libsub-uplevel-perl \
    libtemplate-perl \
    libtest-cmd-perl \
    libtest-perl-critic-perl \
    libtest-pod-coverage-perl \
    libtest-pod-perl \
    libtest-requires-perl \
    libtest-simple-perl \
    libwww-mechanize-perl \
    lsb-release \
    npm \
    perl \
    perl-doc \
    poppler-utils \
    rsync \
    tofrodos \
    wget \
    zlib1g-dev \

# list of mirrors: https://mirrors.opensuse.org/
#echo "deb [signed-by=/etc/apt/trusted.gpg.d/naemon.asc] http://download.opensuse.org/repositories/home:/naemon:/daily/xUbuntu_$(lsb_release -rs)/ ./" >> /etc/apt/sources.list
echo "deb [signed-by=/etc/apt/trusted.gpg.d/naemon.asc] https://slc-mirror.opensuse.org/repositories/home:/naemon:/daily/xUbuntu_$(lsb_release -rs)/ ./" >> /etc/apt/sources.list
curl -s "https://build.opensuse.org/projects/home:naemon/signing_keys/download?kind=gpg" \
    -o /etc/apt/trusted.gpg.d/naemon.asc
apt-get -y update
apt-get -y install naemon-core naemon-livestatus
chsh -s /bin/bash naemon
! grep docker /etc/group >/dev/null || gpasswd -a naemon docker
/etc/init.d/naemon start
chmod 660 /var/cache/naemon/live
touch /etc/naemon/conf.d/thruk_bp_generated.cfg
chmod 666 /etc/naemon/conf.d/thruk_bp_generated.cfg
chmod 777 /var/cache/naemon/checkresults
if [ -e support/thruk_templates.cfg ]; then
    install -m 644 support/thruk_templates.cfg /etc/naemon/conf.d/thruk_templates.cfg
else
    :
fi

# ensure we have a test database in place for tests
/etc/init.d/mysql start
mysql -e "create database IF NOT EXISTS test;" -uroot -proot

chown -R naemon: .

# free some disk space again
apt-get clean
df -h
