# Bolt CMS Setup

Install Bolt via Composer (replace `yourProjectNameGoesHere`; `bolt` for `/var/www/bolt` as project root):

    cd /var/www
    sudo -s -u www-data
    composer create-project bolt/composer-install:^3.2 yourProjectNameGoesHere --prefer-dist

Grant read/write/execute permissions and ownership to `www-data` user and group on `/var/www/bolt`:

    sudo chmod -R 2775 /var/www/bolt
    sudo chown -R www-data:www-data /var/www/bolt

Initialize Bolt database and admin user (testing values; do not use on production servers):

    sudo mysql -u root
    CREATE DATABASE bolt;
    CREATE USER 'bolt' IDENTIFIED BY 'password';
    GRANT ALL ON bolt.* TO 'bolt';
    exit

SQLite as the Bolt Database driver is enabled by default. Change it to MySQL in `/var/www/bolt/app/config/config.yml`.

    cd /var/www/bolt/app/config
    vim config.yml

Note: With .yml (Yaml) files, indentation is very important. Ensure leading spaces match other values.

    database:
      driver: mysql
      username: bolt
      password: password
      databasename: bolt

Initialize Nginx config for Bolt:

    cd /etc/nginx/sites-available
    sudo cp default bolt
    sudo rm /etc/nginx/sites-enabled/*
    sudo ln -s /etc/nginx/sites-available/bolt /etc/nginx/sites-enabled/bolt
    sudo vim /etc/nginx/sites-available/bolt
    
Change `root` from `/var/www` to `/var/www/bolt/public`. Save and exit.

Enter `sudo nginx -t` to test your Nginx config for errors.

Restart PHP, Nginx, and MySQL (MariaDB) services

    sudo service php7.0-fpm restart
    sudo service nginx restart
    sudo service mysql restart

In a browser, navigate to `http://server.ip.address.here/`. It should ask you to initialize the first user in your
database.