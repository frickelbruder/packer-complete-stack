#!/bin/bash

ECHOWRAPPER="==============================================\n\n%s\n\n==============================================\n"

#GIT
printf $ECHOWRAPPER "Installing GIT"
apt-get install -y git 

#SVN
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
apt-get install -y apache2 apache2-utils libapache2-mod-php5
a2enmod actions php5 alias rewrite
service apache2 restart


#PHP
printf $ECHOWRAPPER "Installing PHP"
apt-get install -y php5 php5-dev php-pear autoconf automake curl \
                php5-curl php5-gd php5-imagick php5-mysql php5-cli php5-mcrypt \
                php5-xdebug php5-mcrypt

# PHP konfigurieren
printf $ECHOWRAPPER "Configuring PHP"
cd ~
wget https://github.com/frickelbruder/php-ini-setter/releases/download/1.1.1/php-ini-setter.phar
chmod a+x php-ini-setter.phar
./php-ini-setter.phar --name short_open_tags --value On --file /etc/php5/apache2/php.ini
./php-ini-setter.phar --name memory_limit --value 512M --file /etc/php5/apache2/php.ini
./php-ini-setter.phar --name log_errors --value On --file /etc/php5/apache2/php.ini
./php-ini-setter.phar --name error_log --value /var/log/php_errors.log --file /etc/php5/apache2/php.ini
./php-ini-setter.phar --name max_execution_time --value 120 --file /etc/php5/apache2/php.ini

./php-ini-setter.phar --name short_open_tags --value On --file /etc/php5/cli/php.ini
./php-ini-setter.phar --name memory_limit --value 512M --file /etc/php5/cli/php.ini
./php-ini-setter.phar --name log_errors --value On --file /etc/php5/cli/php.ini
./php-ini-setter.phar --name error_log --value /var/log/php_errors.log --file /etc/php5/cli/php.ini
./php-ini-setter.phar --name max_execution_time --value 120 --file /etc/php5/cli/php.ini

touch /var/log/php_errors.log
chmod 0777 /var/log/php_errors.log


   
##PHPDEVELOPMENT

###Phing
pear channel-discover pear.phing.info
pear install --alldeps phing/phing

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

#Jenkins installieren
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list
apt-get update
apt-get -y install jenkins

sed -i 's~<useSecurity>true</useSecurity>~<useSecurity>false</useSecurity>~' /var/lib/jenkins/config.xml
sed -i 's~<version>1.0</version>~<version>2.0</version>~' /var/lib/jenkins/config.xml

touch /var/lib/jenkins/.last_exec_version
echo "2.0" > /var/lib/jenkins/upgraded
chown jenkins.jenkins /var/lib/jenkins/.last_exec_version
chown jenkins.jenkins /var/lib/jenkins/upgraded

sed -i 's~-Djava.awt.headless=true~-Djava.awt.headless=true -Dhudson.diyChunking=false~'/etc/default/jenkins
service jenkins restart
wget http://127.0.0.1:8080/jnlpJars/jenkins-cli.jar
java -jar jenkins-cli.jar -s http://127.0.0.1:8080/ install-plugin phing
java -jar jenkins-cli.jar -s http://127.0.0.1:8080/ install-plugin subversion
service jenkins restart

exit 0;

