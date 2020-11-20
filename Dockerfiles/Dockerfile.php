FROM php:7.0-apache

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Install unzip utility and libs needed by zip PHP extension 
RUN apt-get update && apt-get install -y zlib1g-dev libzip-dev unzip git \
    && docker-php-ext-install zip \
    && pecl install -f xdebug-2.7.2 \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini