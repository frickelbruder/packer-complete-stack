#!/bin/bash

ECHOWRAPPER="==============================================\n\n%s\n\n==============================================\n"

#GIT
printf $ECHOWRAPPER "Installing GIT"
apt-get install -y git 

#GIT
printf $ECHOWRAPPER "Installing Subversion"
apt-get install -y subversion 

#MySQL-Database - percona flavor
printf $ECHOWRAPPER "Installing Percona Mysql"
wget https://repo.percona.com/apt/percona-release_0.1-3.$(lsb_release -sc)_all.deb
dpkg -i percona-release_0.1-3.$(lsb_release -sc)_all.deb
apt-get update
apt-get install -y percona-server-server

#Apache2
printf $ECHOWRAPPER "Installing Apache"
apt-get install -y apache2 apache2-utils libapache2-mod-fastcgi
a2enmod actions fastcgi alias rewrite
service apache2 restart


#PHP
printf $ECHOWRAPPER "Installing PHP"
apt-get install -y php5 php5-dev php-pear autoconf automake curl \
                php5-curl php5-gd php5-imagick php5-mysql php5-cli php5-mcrypt \
                php5-xdebug

   
##PHPDEVELOPMENT
###PHPUNIT
printf $ECHOWRAPPER "Installing Phpunit"
wget https://phar.phpunit.de/phpunit-old.phar
mv phpunit-old.phar /usr/local/bin/phpunit.phar
chmod a+x /usr/local/bin/phpunit.phar
ln -s /usr/local/bin/phpunit.phar /usr/local/bin/phpunit

###COMPOSER
printf $ECHOWRAPPER "Installing Composer"
php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer.phar
ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

###PHPAB
printf $ECHOWRAPPER "Installing phpab"
wget https://github.com/theseer/Autoload/releases/download/1.21.0/phpab-1.21.0.phar
mv phpab-1.21.0.phar /usr/local/bin/phpab.phar
chmod a+x /usr/local/bin/phpab.phar
ln -s /usr/local/bin/phpab.phar /usr/local/bin/phpab

#phpmyadmin
printf $ECHOWRAPPER "Installing PHPMyAdmin"
printf $ECHOWRAPPER "Setting PHPMyAdmin debconf settings"
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-install boolean false '
debconf-set-selections <<< 'phpmyadmin phpmyadmin/dbconfig-reinstall boolean false '
debconf-set-selections <<< 'phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2'
debconf-set-selections <<< 'phpmyadmin phpmyadmin/internal/skip-preseed boolean true '
printf $ECHOWRAPPER "Doing the install"
apt-get install -y phpmyadmin
sed -i 's~ //\(.*AllowNoPassword.*\)~\1~1' /etc/phpmyadmin/config.inc.php
sed -i "s~'cookie';~'config';~1" /etc/phpmyadmin/config.inc.php
sed -i "s~= \$dbuser;~= 'root';~1" /etc/phpmyadmin/config.inc.php
sed -i "s~= \$dbpass;~= '';~1" /etc/phpmyadmin/config.inc.php
sed -i "s~= \$dbserver;~= '127.0.0.1';~1" /etc/phpmyadmin/config.inc.php


#Ruby (required for compass)
printf $ECHOWRAPPER "Installing Ruby"
gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source /etc/profile.d/rvm.sh
rvm requirements
rvm install ruby-head
rvm use ruby-head --default 

#Compass
printf $ECHOWRAPPER "Installing Compass"
gem install compass

#NodeJS/NPM
printf $ECHOWRAPPER "Installing Node/NPM"
curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
apt-get install -y nodejs

#Bower
printf $ECHOWRAPPER "Installing Bower"
npm install -g bower