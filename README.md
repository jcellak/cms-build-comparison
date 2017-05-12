# CMS Build and Profiling
Compare and contrast CMS platforms Drupal and Wordpress side-by-side.

The intent is to install roughly similar setups on both platforms (plugins, libraries, assets) and run them through 
rigorous testing suites and profiling software.

The LEMP stack (Linux, Nginx, MariaDB, PHP7) will be exactly the same, and run on the same server.

Everything here should be accessible free of charge (unless you decide to use VMWare Workstation Pro).

## VM Setup
Tested using Ubuntu 16.04 LTS 64-bit Server edition on VMWare Workstation Pro 12.5.5 for Windows 10.

Ubuntu 16 download links:
- http://releases.ubuntu.com/16.04/ubuntu-16.04.2-server-amd64.iso.torrent
- http://mirror.pnl.gov/releases/xenial/ubuntu-16.04.2-server-amd64.iso

VMWare Workstation download links (Workstation is free if Pro is not an option):
- https://my.vmware.com/en/web/vmware/free#desktop_end_user_computing/vmware_workstation_player/12_0
- https://my.vmware.com/en/web/vmware/info/slug/desktop_end_user_computing/vmware_workstation_pro/12_0

Once VMWare Workstation is installed, create a new Virtual Machine using the Ubuntu image. Follow through all of the
Easy Install steps, create a user, and get to the command line.

Note: Double check to make sure `VM -> Settings -> Network Adapter` is set to `NAT` to share the host's IP address.

## Linux, Nginx, MariaDB (MySQL), PHP - LEMP Stack setup
Install latest updates, install git (for pulling remote repositories), and vim (simple file edits)

    sudo apt-get update
    sudo apt-get upgrade -y
    sudo apt-get dist-upgrade -y
    sudo apt-get install -y git vim

Install Nginx, MariaDB, PHP7, PHP mods, and CURL

    sudo apt-get install -y nginx
    sudo apt-get install -y mariadb-server
    sudo apt-get install -y php7.0-fpm php7.0-xml php7.0-mcrypt php7.0-mysql php7.0-curl php7.0-gd php7.0-json
    sudo apt-get install -y curl

Optional but recommended: Install SSH to access your VM via PuTTY (or similar SSH program)

    sudo apt-get install -y openssh-server
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.factory-defaults
    sudo chmod a-w /etc/ssh/sshd_config.factory-defaults
    sudo systemctl restart ssh

### Configure Nginx and PHP
Configure Nginx to use php-fpm to server HTTP requests for PHP pages.

    sudo vim /etc/php/7.0/fpm/php.ini

Find `#cgi.fix_pathinfo=1`. Change to `cgi.fix_pathinfo=0` (uncomment and change from 1 to 0). Save and exit.

Make a copy of the default Nginx config (for reference) and edit the original:

    cd /etc/nginx/sites-available
    sudo cp default default.old
    sudo vim default

Edit contents to match the following (adjust as necessary - recommend reading up on Nginx config):
        
    server {
            listen 80 default_server;
            listen [::]:80 default_server;
    
            root /var/www;
            index index.php;
            server_name _;
    
            location / {
                    try_files $uri $uri/ /index.php;
            }
    
            location ~ \.php$ {
                    include snippets/fastcgi-php.conf;
                    fastcgi_pass unix:/run/php/php7.0-fpm.sock;
            }
    }

## Drupal 8 Setup
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
    CREATE USER 'drupal' IDENTIFIED BY 'drupal';
    GRANT ALL ON drupal.* TO 'drupal';
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

## Wordpress Setup
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
    GRANT ALL PRIVILEGES ON *.* TO 'wuser'@'%';
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

Restart PHP, Nginx, and MySQL (MariaDB) services

    sudo service php7.0-fpm restart
    sudo service nginx restart
    sudo service mysql restart

In a browser, navigate to `http://server.ip.address.here/`. It should take you 
to `http://server.ip.address.here/wp-admin/install.php` automatically. Follow along to complete the installation.

## Switching, Customizing, and Profiling each CMS
Git clone this repository into your `/var/www` folder.

    cd /var/www
    git init .
    git remote add origin https://github.com/jcellak/cms-build-comparison.git
    git fetch origin
    git checkout master

### Switching
Navigate to `/var/www/scripts`. Script names should be self-explanatory; run each when you want to switch the CMS
running on your server. i.e.

    cd /var/www/scripts
    sudo bash switch-to-wordpress.sh
    sudo bash switch-to-drupal.sh

### Profiling
Some of these will require you to host your server somewhere more accessible.

- https://developers.google.com/speed/pagespeed/insights/
  - Free
  - It's Google
  - Compares Mobile vs. Desktop
  - Provides helpful suggestions to fix outstanding issues
- https://gtmetrix.com/
  - Free
  - Aggregates Google PageSpeed and Yahoo YSlow scores
  - Waterfall charts
  - History
- https://blackfire.io/
  - Free trial available
  - Great for PHP performance
  - Publicly sharable results

# TODO
- Add more CMS platforms for comparison.
- Add more third party libraries for profiling.
- Add more recommendations for profiling.