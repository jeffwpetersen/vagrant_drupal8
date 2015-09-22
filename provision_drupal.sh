#!/bin/bash

# Provision a VM for Drupal development using nginx, php-fpm and mysql.
#
# Shamelessly snarfed from Jurgen Verhasselt - https://github.com/sjugge

##### VARIABLES #####

# Throughout this script, some variables are used, these are defined first.
# These variables can be altered to fit your specific needs or preferences.

# Server name
HOSTNAME="drup8"

# MySQL password
MYSQL_ROOT_PASSWORD="root" # can be altered, though storing passwords in a script is a bad idea!

# Locale
LOCALE_LANGUAGE="en_US" # can be altered to your prefered locale, see http://docs.moodle.org/dev/Table_of_locales
LOCALE_CODESET="en_US.UTF-8"

# Timezone
TIMEZONE="America/Chicago" # can be altered to your specific timezone, see http://manpages.ubuntu.com/manpages/jaunty/man3/DateTime::TimeZone::Catalog.3pm.html

# Site information
SOURCE_DIR_NAME=$HOSTNAME # this is a subdirectory under /var/www
BEHAT_DIR_NAME=${SOURCE_DIR_NAME}_behat
DOCROOT="/var/www/$HOSTNAME/htdocs"
# Only set one of these (svn or git)
# SVN_URL=""
# GIT_URL=""
SITE_NAME=$HOSTNAME
DB_NAME=$HOSTNAME
DB_USER=$HOSTNAME
DB_PASSWORD=$HOSTNAME

##### Provision check ######

# The provision check is intented to not run the full provision script when a box has already been provisioned.
# At the end of this script, a file is created on the vagrant box, we'll check if it exists now.
echo "[vagrant provisioning] Checking if the box was already provisioned..."

if [ -e "/home/vagrant/.provision_check" ]
then
  # Skipping provisioning if the box is already provisioned
  echo "[vagrant provisioning] The box is already provisioned..."
  exit
fi

##### Ensure packages are up to date #####

echo "[vagrant provisioning] Updating packages..."
apt-get update
apt-get dist-upgrade -y

##### System settings #####

# Set Locale, see https://help.ubuntu.com/community/Locale#Changing_settings_permanently
echo "[vagrant provisioning] Setting locale..."
locale-gen $LOCALE_LANGUAGE $LOCALE_CODESET

# Set timezone, for unattended info see https://help.ubuntu.com/community/UbuntuTime#Using_the_Command_Line_.28unattended.29
echo "[vagrant provisioning] Setting timezone..."
echo $TIMEZONE | tee /etc/timezone
dpkg-reconfigure --frontend noninteractive tzdata

echo "[vagrant provisioning] Installing mysql-server and mysql-client..."
# Set MySQL root password and install MySQL. Info on unattended install: http://serverfault.com/questions/19367
echo mysql-server mysql-server/root_password select $MYSQL_ROOT_PASSWORD | debconf-set-selections
echo mysql-server mysql-server/root_password_again select $MYSQL_ROOT_PASSWORD | debconf-set-selections
apt-get install -y mysql-server mysql-client
service mysql restart

echo "[vagrant provisioning] Installing common packages..."
apt-get install -y mg apache2 mysql-server php5 libapache2-mod-php5 php5-mysql php5-gd php5-curl php5-mcrypt php5-cli php-pear php-apc php-codecoverage phpunit-mock-object keychain zsh subversion git curl nfs-kernel-server zip unzip exuberant-ctags

#Enable mod_rewrite
sudo a2enmod rewrite
sudo service apache2 reload

echo "[vagrant provisioning] Securing MySQL..."
mysql -uroot -p$MYSQL_ROOT_PASSWORD mysql <<EOF
drop user ''@'localhost';
drop user ''@'vagrant-ubuntu-precise-64';
drop user 'root'@'vagrant-ubuntu-precise-64';
delete from db where db like 'test%';
drop database test;
create database '$HOSTNAME';
flush privileges;
EOF

echo "[vagrant provisioning] Installing rvm and ruby..."
curl -L https://get.rvm.io | bash -s stable --ruby
source /usr/local/rvm/scripts/rvm
usermod -a -G rvm vagrant

echo "[vagrant provisioning] Installing common ruby gems..."
gem install bundler
gem install rake

echo "[vagrant provisioning] Installing ssmtp..."
apt-get install -y ssmtp

if [ ! -z "$GMAIL_ADDRESS" ]
then
  cat <<EOF >/etc/ssmtp/ssmtp.conf
root=$GMAIL_ADDRESS
mailhub=smtp.gmail.com:587
rewriteDomain=$GMAIL_DOMAIN
hostname=$GMAIL_USER
UseSTARTTLS=YES
AuthUser=$GMAIL_USER
AuthPass=$GMAIL_PASSWORD
FromLineOverride=YES
EOF

    chmod 640 /etc/ssmtp/ssmtp.conf
    adduser www-data mail
fi

echo "[vagrant provisioning] Installing composer..."
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer


echo "[vagrant provisioning] Installing java..."
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
apt-get -y install oracle-java7-installer

echo "[vagrant provisioning] Installing selenium..."
mkdir /usr/local/selenium
wget -P /usr/local/selenium http://selenium.googlecode.com/files/selenium-server-standalone-2.39.0.jar

echo "[vagrant provisioning] Creating /var/www..."
mkdir -p /var/www
chmod 777 /var/www

# vagrant-hostupdater alternitive.
#  cp /var/www/html/hosts/ /etc/apache2/sites-available/d7.subdomain.example.org.conf
#  sudo a2ensite d7.subdomain.example.org
#  sudo service apache2 restart
#  sudo service apache2 reload


##### Provision check #####

# Create .provision_check for the script to check on during a next vargant up.
echo "[vagrant provisioning] Creating .provision_check file..."
touch .provision_check
