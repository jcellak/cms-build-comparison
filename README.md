# CMS Build and Profiling
Compare and contrast modern CMS platforms side-by-side.

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
    sudo apt-get install -y php7.0-fpm php7.0-common php7.0-xml php7.0-mcrypt php7.0-mysql php7.0-curl php7.0-gd php7.0-json
    sudo apt-get install -y curl

Git clone this repository into your `/var/www` folder (created after installing Nginx):

    cd /var/www
    git init .
    git remote add origin https://github.com/jcellak/cms-build-comparison.git
    git fetch origin
    git checkout master

Grant read/write/execute permissions and ownership to `www-data` user and group on `/var/www`.

    sudo chmod -R 2775 /var/www
    sudo chown -R www-data:www-data /var/www

Add yourself to the 'www-data' group. You must log out and log back in for the changes to take effect:

    sudo usermod -a -G www-data yourUsernameHere

Install Composer system-wide

    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer

Grant read/write/execute permissions for Composer in your /home/myUsernameHere directory.
Note: Composer uses current user home directory for temporary install files.

    cd ~
    sudo chmod -R 2775 .

Optional but recommended: Install SSH to access your VM via PuTTY (or similar SSH program)

    sudo apt-get install -y openssh-server
    sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.factory-defaults
    sudo chmod a-w /etc/ssh/sshd_config.factory-defaults
    sudo systemctl restart ssh

### Configure Nginx, PHP, and MySQL
Configure Nginx to use php-fpm to serve HTTP requests for PHP pages.

    sudo vim /etc/php/7.0/fpm/php.ini

Find `;cgi.fix_pathinfo=1`. Change to `cgi.fix_pathinfo=0` (i.e. uncomment and change from 1 to 0). Save and exit.

Make a copy of the default Nginx config (for reference) and edit the original:

    cd /etc/nginx/sites-available
    sudo cp default default.old
    sudo vim default

Edit Nginx config. Adjust as necessary, highly recommended to read up on Nginx config here:
http://nginx.org/en/docs/beginners_guide.html#conf_structure
An example is provided as the baseline config for settings up each CMS - they will be based off of the following:

    server {
            listen 80 default_server;
            listen [::]:80 default_server;
    
            root /var/www;
            index index.php;
            server_name _;
    
            location / {
                try_files $uri $uri/ /index.php;
            }
    
            # Nginx with PHP FPM FastCGI support
            location ~ \.php$ {
                include snippets/fastcgi-php.conf;
                fastcgi_pass unix:/run/php/php7.0-fpm.sock;
            }
            
            # Disable all external access to .htaccess (Apache rewrite rules, added by some CMS installations)
            location ~ /\.htaccess {
                deny all;
            }
    }

Initialize MariaDB with a super user (testing values; do not use on production servers):
	
	sudo mysql -u root
    CREATE user 'sqladmin'@'%' identified by 'sqladmin';
    GRANT ALL PRIVILEGES ON *.* TO 'sqladmin'@'%';
    exit

## Drupal 8 Setup
See [drupal/README.md](drupal/README.md)

## Wordpress Setup
See [wordpress/README.md](wordpress/README.md)

## October CMS Setup
See [october/README.md](october/README.md)

## Bolt CMS Setup
See [bolt/README.md](bolt/README.md)

# Switching and Profiling each CMS

## Switching between CMS
Navigate to `/var/www/scripts`. Script names should be self-explanatory; run each when you want to switch the CMS
running on your server. i.e.

    cd /var/www/scripts
    sudo bash switch-to-wordpress.sh
    sudo bash switch-to-drupal.sh
    sudo bash switch-to-october.sh
    sudo bash switch-to-bolt.sh

## Profiling each CMS
Many of these will require you to host your server somewhere externally.

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
  - From creators of Symfony PHP framework (also powers Bolt CMS and October CMS)

# TODO
- Add more CMS platforms for comparison.
- Add more third party libraries for profiling.
- Add more recommendations for profiling.