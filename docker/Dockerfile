FROM php:8.2-apache

# Install PHP extensions needed by WordPress/WooCommerce
RUN apt-get update \
 && apt-get install -y --no-install-recommends libicu-dev \
 && docker-php-ext-configure intl \
 && docker-php-ext-install intl mysqli pdo_mysql \
 && rm -rf /var/lib/apt/lists/*

# Enable Apache rewrite and allow .htaccess for pretty permalinks
RUN a2enmod rewrite \
 && sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

# Add developer-friendly PHP settings for local use
RUN { \
      echo 'display_errors=On'; \
      echo 'display_startup_errors=On'; \
      echo 'error_reporting=E_ALL'; \
      echo 'memory_limit=512M'; \
      echo 'upload_max_filesize=64M'; \
      echo 'post_max_size=64M'; \
      echo 'max_execution_time=300'; \
   } > /usr/local/etc/php/conf.d/dev.ini

EXPOSE 80
