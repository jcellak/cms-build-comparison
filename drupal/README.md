# Drupal 8 Setup
Download Drupal 8 into your user's home directory and unzip it (tested using version `8.3.2` specifically):

    cd
    wget https://ftp.drupal.org/files/projects/drupal-8.3.2.tar.gz
    tar -xvzf drupal-8.3.2.tar.gz

Move unzipped Drupal contents to `/var/www`:

    sudo mv drupal-8.3.2 /var/www/drupal

Initialize Drupal's settings.php file:

    cd /var/www/drupal/sites/default && sudo cp default.settings.php settings.php

Grant read/write/execute permissions and ownership to `www-data` user and group on `/var/www/drupal`:

    sudo chmod -R 775 /var/www/drupal
    sudo chown -R www-data:www-data /var/www/drupal

Initialize Drupal database and admin user (testing values; do not use on production servers):

    sudo mysql -u root
    CREATE DATABASE drupal;
    CREATE USER 'drupal'@'%' IDENTIFIED BY 'drupal';
    GRANT ALL ON drupal.* TO 'drupal'@'%';
    exit

Initialize Nginx config for WordPress by copying and editing the Nginx config file we created earlier, and removing
the currently enabled symlink configs in `sites-enabled`:

    cd /etc/nginx/sites-available
    sudo cp default drupal
    sudo rm /etc/nginx/sites-enabled/*
    sudo ln -s /etc/nginx/sites-available/drupal /etc/nginx/sites-enabled/drupal
    sudo vim /etc/nginx/sites-available/drupal
    
Change `root /var/www` to `root /var/www/drupal`. Save and exit.

Enter `sudo nginx -t` to test your Nginx config for errors.

Restart PHP, Nginx, and MySQL (MariaDB) services

    sudo service php7.0-fpm restart
    sudo service nginx restart
    sudo service mysql restart

In a browser, navigate to `http://server.ip.address.here/core/install.php`. Follow along to complete the installation.