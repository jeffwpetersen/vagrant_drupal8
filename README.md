# vagrant_drupal8

I have not gotten this to run on windows7 pro.

# Clone the vagrant development file

$ git clone https://github.com/jeffwpetersen/vagrant_drupal8.git

# Install vagrant-hostupdater to automatically update your local host file
# to point to your new vagrant ip.

# Run Vagrant Up in your host machine bash shell.
$ vagrant up
# Log into your guest server when provisioning is finished.
$ vagrant ssh

# edit your vhosts file as I have not got this in my provision script.

    <Directory "/var/www/html/drupal8/">
        Options Indexes FollowSymlinks
        AllowOverride All
        Require all granted
    </Directory>

# FIX: xdebug.max_nesting_level is set to 100. Set
# xdebug.max_nesting_level=256 in your PHP configuration as some pages in
# your Drupal site will not work when this setting is too low.

# ? also in cli or you will get an error.? no
$ sudo vi /etc/php5/apache2/php.ini
xdebug.max_nesting_level=256

$ sudo service apache2 restart

update your permisiions on the host and guest systems.
$ sudo chmod -R 777 html
