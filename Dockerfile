FROM webdevops/php-apache-dev:7.1

# User and group permission
ENV APPLICATION_USER=www-data \
    APPLICATION_GROUP=www-data \
    APPLICATION_PATH=/var/www/html \
    APPLICATION_UID=1000 \
    APPLICATION_GID=1000
RUN usermod --non-unique --uid 1000 www-data
RUN groupmod --non-unique --gid 1000 www-data

# Commont tool
RUN apt-get update && apt-get install -y nano \
    spell \
    mysql-client \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# Install pecl-php-uploadprogress
RUN git clone https://github.com/php/pecl-php-uploadprogress /tmp/php-uploadprogress && \
  cd /tmp/php-uploadprogress && \
  phpize && \
  ./configure --prefix=/usr && \
  make && \
  make install && \
  rm -rf /tmp/*

# Let's keep the house clean
RUN docker-image-cleanup

# Set recommended PHP.ini settings
RUN {  \
  echo 'memory_limit = 2048M'; \
  echo 'max_input_vars = 5000'; \
  echo 'upload_max_filesize = 64M'; \
  echo 'post_max_size = 64M'; \
  echo 'max_execution_time = 600'; \
  echo 'session.cache_limiter = nocache'; \
  echo 'session.auto_start = 0'; \
  echo 'expose_php = Off'; \
  echo 'magic_quotes_gpc = Off'; \
  echo 'register_globals = Off'; \
  echo 'display_errors = Off'; \
  echo 'date.timezone = Europe/Rome'; \
  echo 'extension = uploadprogress.so'; \
  } >> /opt/docker/etc/php/php.ini

# Apache conf
ENV WEB_DOCUMENT_ROOT=/var/www/html/web
RUN a2dismod autoindex -f
RUN rm /var/www/html/index.html

# We hold public files in mounted devices
VOLUME ["/var/www/html/web/sites/shared/files"]

# Exposing ports
EXPOSE 80 443 9000

# Default work dir
WORKDIR "/var/www/html"
