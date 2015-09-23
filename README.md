# A Vagrant file to fire up a drupal 8 development environment.
 
Clone the vagrant development file 
$ git clone https://github.com/jeffwpetersen/vagrant_drupal8.git

# Hostupdater
Install vagrant-hostupdater extension to automatically update your 
local HOST file to point to your new vagrant ip.

# Vagrant Up
Run Vagrant Up in your host machine bash shell.
$ vagrant up

# Log In
Log into your guest server when provisioning is finished.
$ vagrant ssh

# Edit your vhosts file. 

# FIX: xdebug.max_nesting_level
xdebug.max_nesting_level=256 in your PHP configuration as some pages
in your Drupal site will not work when this setting is too low.
 
$ sudo vi /etc/php5/apache2/php.ini xdebug.max_nesting_level=256
$ sudo service apache2 restart

# Update permisions
update your permisiions on the host and guest systems. 
$ sudo chmod -R 777 html
