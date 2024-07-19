ARG PHP_VERSION=""
FROM php:${PHP_VERSION:+${PHP_VERSION}-}apache

# Docker image to host Drupal 7 on PHP 7.1 with Apache
# I developed this for my own needs as I have two Drupal 7 sites that
# I've tested to work on PHP 7.1 but no later.
#
# The goal is a simple Docker container with Apache all set up 
# to run PHP and to be suitable for Drupal websites.

# Derived from: https://github.com/erpushpinderrana/dockerize-existing-drupal-project/blob/master/php/Dockerfile
# That Dockerfile is based on php:VERSION-fpm-alpine hence is
# running Alpine.  But this Dockerfile aims to use a built-in Apache.
# Since the php base image does not have a php:VERSION-apache-alpine,
# we had to translate from the Alpine packages to Debian packages.
# But, at the end of this you'll see a list of packages for which
# I could not find a Debian equivalent.

RUN apt-get update && apt-get upgrade -y

# Install gd library extension
# The original Dockerfile used zlib-dev, and the Lua package
# is the closest which could be found.
RUN apt-get install -y \
        libpng-dev libjpeg62-turbo-dev libwebp-dev lua-zlib-dev \
        libxpm-dev libgd-dev wget \
    && docker-php-ext-install gd    

# Install MySql
RUN docker-php-ext-install mysqli pdo pdo_mysql

# To support Drupal, install Drush.
# This is targeting Drupal 7, hence it is using Drush 8.4.1.
# See the info at: https://docs.drush.org/en/8.x/install/
#
# According to the drush.org compatibility chart, we use
# Drush 8.x with Drupal 7.x.  Drush 8.x is there but unsupported.
#
# The `drush.phar` file is directly executable, so all we do is
# plop it in /usr/bin and make it executable.

RUN wget https://github.com/drush-ops/drush/releases/download/8.4.12/drush.phar \
         --output-document=/usr/local/bin/drush && \
    chmod +x /usr/local/bin/drush

COPY apache2-reload /usr/local/bin
RUN chmod +x /usr/local/bin/apache2-reload

# This installs some of the packages used by the original Dockerfile.
# The lua-rex-pcre package is installed because the original Dockerfile
# installed a package named pcre, and the closest was this Lua package.
# Is it needed?  Haven't the foggiest.
# The mariadb-client package is here to supply the MySQL CLI tool
RUN apt-get install -y \
        ca-certificates \
        openssh-client \
        rsync \
        git \
        curl \
        wget \
        gzip \
        tar \
        patch \
        perl \
        imagemagick \
        mariadb-client \
        autoconf \
        libtool


        # lua-rex-pcre lua-rex-pcre-dev 
        
RUN pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

# For some reason the php:apache module doesn't enable these Apache modules
# Wouldn't they be universally required?  There are some additional modules
# that can be enabled but they didn't seem required.
RUN a2enmod rewrite
RUN a2enmod ssl

# Install some useful tools
RUN apt-get install -y net-tools procps vim

# Override the work directory
WORKDIR /var/www

# These are packages installed in the original Dockerfile that is 
# running Alpine Linux.  I was not able to find the equivalent packages
# to use on Debian.
#
# libressl
# imap
# build-base
# php7-dev
# pcre-dev 
# imagemagick-dev 
#        php7 \
#        php7-fpm \
#        php7-opcache \
#        php7-session \
#        php7-dom \
#        php7-xml \
#        php7-xmlreader \
#        php7-ctype \
#        php7-ftp \
#        php7-gd \
#        php7-json \
#        php7-posix \
#        php7-curl \
#        php7-pdo \
#        php7-pdo_mysql \
#        php7-sockets \
#        php7-zlib \
#        php7-mcrypt \
#        php7-mysqli \
#        php7-sqlite3 \
#        php7-bz2 \
#        php7-phar \
#        php7-openssl \
#        php7-posix \
#        php7-zip \
#        php7-calendar \
#        php7-iconv \
#        php7-imap \
#        php7-soap \
#        php7-dev \
#        php7-pear \
#        php7-redis \
#        php7-mbstring \
#        php7-xdebug \
#        php7-exif \
#        php7-xsl \
#        php7-ldap \
#        php7-bcmath \
#        php7-memcached \
#        php7-oauth \
#        php7-apcu
