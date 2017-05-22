# Wordpress Setup
Download WordPress 4.7.4 into your user's home directory and unzip it.

    cd
    wget https://wordpress.org/wordpress-4.7.4.tar.gz
    tar -xvzf wordpress-4.7.4.tar.gz

Alternatively, downloading the latest version is also recommended, but not tested for these steps:

    cd
    wget https://wordpress.org/latest.tar.gz
    tar -xvzf latest.tar.gz

Move unzipped WordPress contents to `/var/www`:

    sudo mv wordpress /var/www/

Initialize WordPress database (testing values; do not use on production servers):
	
	sudo mysql -u root
    CREATE user 'wuser'@'%' identified by 'wuserPWD';
    CREATE DATABASE wordpress;
    GRANT ALL PRIVILEGES ON wordpress.* TO 'wuser'@'%';
    exit

Copy and edit WordPress config:

    cd /var/www/wordpress
    sudo cp wp-config-sample.php wp-config.php
    sudo vim wp-config.php

Edit values for `DB_NAME`, `DB_USER`, and `DB_PASSWORD` to match WordPress DB init step. Save and exit.

Grant read/write/execute permissions and ownership to `www-data` user and group on `/var/www/wordpress`:

    sudo chmod -R 775 /var/www/wordpress
    sudo chown -R www-data:www-data /var/www/wordpress

Initialize Nginx config for WordPress by copying and editing the Nginx config file we created earlier, and removing
the currently enabled symlink configs in `sites-enabled`:

    cd /etc/nginx/sites-available
    sudo cp default wordpress
    sudo rm /etc/nginx/sites-enabled/*
    sudo ln -s /etc/nginx/sites-available/wordpress /etc/nginx/sites-enabled/wordpress
    sudo vim /etc/nginx/sites-available/wordpress
    
Change `root /var/www` to `root /var/www/wordpress`. Save and exit.

Enter `sudo nginx -t` to test your Nginx config for errors.
l
Restart PHP, Nginx, and MySQL (MariaDB) services

    sudo service php7.0-fpm restart
    sudo service nginx restart
    sudo service mysql restart

In a browser, navigate to `http://server.ip.address.here/`. It should take you 
to `http://server.ip.address.here/wp-admin/install.php` automatically. Follow along to complete the installation.