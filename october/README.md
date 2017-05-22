# October Setup
https://octobercms.com/docs/setup/installation

Install additional PHP extensions/modules required:

    sudo apt-get install -y php7.0-mbstring
    sudo apt-get install -y php7.0-zip

Install October via Composer

    composer create-project october/october /var/www/october

Grant read/write/execute permissions and ownership to `www-data` user and group on `/var/www/october`:

    sudo chmod -R 2775 /var/www/october
    sudo chown -R www-data:www-data /var/www/october

Initialize October database and admin user (testing values; do not use on production servers):

    sudo mysql -u root
    CREATE DATABASE october;
    CREATE USER 'october' IDENTIFIED BY 'october';
    GRANT ALL ON october.* TO 'october';
    exit

Since we did a Console installation via Composer (http://octobercms.com/docs/console/commands#console-install), we
must run the `php artisan october:install` command to setup database config, application URL, encryption keys, and
administrator details.

    cd /var/www/october
    sudo php artisan october:install

- For `Database type`: choose `MySQL` for our installation of MariaDB.
- For `MySQL Host`: hit enter to keep the default for `localhost`. Editable later to utilize an external database.
- For `Database Name`/`MySQL Login`/`MySQL Password`: Enter the same credentials we used to initialize above.

Open/Edit the OctoberCMS config file:

    cd /var/www/october/config
    sudo vim cms.php
    
Take note of all the settings available.
- Enable the `disableCoreUpdates` setting, as this will be managed by Composer instead.

Initialize Nginx config for October by copying and editing the Nginx config file we created earlier, and removing
the currently enabled symlink configs in `sites-enabled`:

    cd /etc/nginx/sites-available
    sudo cp default october
    sudo rm /etc/nginx/sites-enabled/*
    sudo ln -s /etc/nginx/sites-available/october /etc/nginx/sites-enabled/october
    sudo vim /etc/nginx/sites-available/october
    
The Nginx config for October needs some additional rewrite rules:
http://octobercms.com/docs/setup/configuration#nginx-configuration

    ...
    
    root /var/www/october;

    location / {
        try_files $uri /index.php$is_args$args;
    }
    
    rewrite ^themes/.*/(layouts|pages|partials)/.*.htm /index.php break;
    rewrite ^bootstrap/.* /index.php break;
    rewrite ^config/.* /index.php break;
    rewrite ^vendor/.* /index.php break;
    rewrite ^storage/cms/.* /index.php break;
    rewrite ^storage/logs/.* /index.php break;
    rewrite ^storage/framework/.* /index.php break;
    rewrite ^storage/temp/protected/.* /index.php break;
    rewrite ^storage/app/uploads/protected/.* /index.php break;
    
    ...

Enter `sudo nginx -t` to test your Nginx config for errors.

Restart PHP, Nginx, and MySQL (MariaDB) services

    sudo service php7.0-fpm restart
    sudo service nginx restart
    sudo service mysql restart

In a browser, navigate to `http://server.ip.address.here/`. You'll get the October CMS demo theme to explore.

Note: by default, the OctoberCMS Demo Theme does not have a back-end administrative panel. But there are free Themes
to download with tools already implemented.

The licenses are such that you can customize them at will. Similar to the twentysixteen/seventeen/eighteen Themes
in WordPress.