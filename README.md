# docker-drupal-php
Docker image to simplify hosting Drupal sites on Docker

The goal is a simple Docker container with Apache all set up to run PHP and to be suitable for Drupal websites.  It is derived from `php:7.1-apache`, which makes it a Debian-based container.

To use:

```yaml
version: '3'

services:
    db:
        image: "mysql/mysql-server:5.7"
        container_name: db
        command: [ "mysqld",
                    "--character-set-server=utf8mb4",
                    "--collation-server=utf8mb4_unicode_ci",
                    "--bind-address=0.0.0.0",
                    "--innodb_large_prefix=true",
                    "--innodb_file_format=barracuda",
                    "--innodb_file_per_table=true" ]
        networks:
           - drupalnet
        volumes:
           - /PATH/TO/db:/var/lib/mysql
        restart: always
        environment:
           MYSQL_ROOT_PASSWORD: "w0rdw0rd"
           MYSQL_USER: DRUPAL-USER-NAME
           MYSQL_PASSWORD: DRUPAL-PASSWORD
           MYSQL_DATABASE: DRUPAL-DATABASE-NAME


    drupal:
        image: "robogeek/drupal-php-7.1"
        container_name: drupal
        networks:
            - drupalnet
        ports:
            - "80:80"
        restart: always
        volumes:
            - /PATH/TO/SITE-NAME.com:/var/www/html:rw
            - /PATH/TO/SECOND-SITE-NAME.com:/var/www/SECOND-SITE:rw
            - /PATH/TO/sites-enabled:/etc/apache2/sites-enabled:rw
```

Substitute for `/PATH/TO` the actual location of these directories.  The `SITE-NAME.com` directory is meant to be the _docroot_ of a website, such as a built Drupal site.  This shows that for a second, or third, site simply mount the directories into the container.

In the `sites-enabled` directory add one configuration file for each site to host.

```
<VirtualHost *:80>
	ServerName SITE-NAME.com

	ServerAdmin webmaster@SITE-NAME.com
	DocumentRoot /var/www/html

	# Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
	# error, crit, alert, emerg.
	# It is also possible to configure the loglevel for particular
	# modules, e.g.
	#LogLevel info ssl:warn

	ErrorLog ${APACHE_LOG_DIR}/SITE-error.log
	CustomLog ${APACHE_LOG_DIR}/SITE-access.log combined

	<Directory "/var/www/html">
	 AllowOverride All
	</Directory>

</VirtualHost>
```

That's a trivial configuration file, but of course being Apache you can do a lot more.

 