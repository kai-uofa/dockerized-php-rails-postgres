# Credit: https://medium.com/@jasonterando/debugging-with-visual-studio-code-xdebug-and-docker-on-windows-b63a10b0dec
# Credit: https://dev.to/jonesrussell/install-composer-in-custom-docker-image-3f71
# Credit: https://stackoverflow.com/questions/41274829/php-error-the-zip-extension-and-unzip-command-are-both-missing-skipping
FROM php:7.0-apache

# Install Composer
COPY --from=composer /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Install unzip utility and libs needed by zip PHP extension 
RUN apt-get update && apt-get install -y zlib1g-dev libzip-dev unzip git \
    && docker-php-ext-install zip \
    && pecl install -f xdebug-2.7.2 \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini