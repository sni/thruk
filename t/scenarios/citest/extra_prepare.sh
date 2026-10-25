#!/bin/bash

set -ex

mkdir -p /var/lib/naemon/thruk
rsync -a --delete --chown=naemon:naemon /thruk/. /var/lib/naemon/thruk/.
ln -sfn $(realpath /thruk/support/thruk_templates.cfg) /etc/naemon/conf.d/thruk_templates.cfg
sudo su naemon -c -- bash -c 'cd ~/thruk && ./.ci/install_deps.sh'
#/thruk/script/install_puppeteer.sh
sed -i /etc/naemon/naemon.cfg -e 's/.*check_workers=.*/check_workers=2/'
service naemon start
service mysql start
sh -c 'rm -rf /var/lib/naemon/thruk/thruk_local.d/* /var/lib/naemon/thruk/thruk_local.conf /var/lib/naemon/thruk/tmp/* /var/lib/naemon/thruk/var/*'
cp /thruk/t/ci/thruk_local.conf /var/lib/naemon/thruk/thruk_local.conf
chown naemon: /var/lib/naemon/thruk/thruk_local.conf
sudo su naemon -c -- bash -c 'cd ~/thruk && perl Makefile.PL'

echo "CREATE USER IF NOT EXISTS 'naemon'@'%' IDENTIFIED BY 'naemon';" | mysql
echo "GRANT ALL PRIVILEGES ON *.* TO 'naemon'@'%';" | mysql
chmod g+rx /var/run/mysqld
adduser naemon mysql
