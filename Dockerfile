FROM webdevops/php-nginx-dev:7.2

# Environment variables
ENV APPLICATION_USER=www-data \
    APPLICATION_GROUP=www-data \
    APPLICATION_PATH=/var/www/html \
    APPLICATION_UID=1000 \
    APPLICATION_GID=1000 \
    WEB_DOCUMENT_ROOT=/var/www/html/web \
    ROBO_DRUPAL8_ENV=local

# User and group permission
RUN usermod --non-unique --uid 1000 www-data \
    && groupmod --non-unique --gid 1000 www-data \
    && chown -R www-data:www-data /var/www

# Commont tools
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y \
      gettext \
      libpng16-16 \
      libjpeg62-turbo-dev \
      libfreetype6-dev \
      mysql-client \
      nano

# Reconfigure GD
RUN docker-php-ext-configure gd \
      --with-gd \
      --with-freetype-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/

# Install pecl-php-uploadprogress
RUN git clone https://github.com/php/pecl-php-uploadprogress /tmp/php-uploadprogress && \
      cd /tmp/php-uploadprogress && \
      phpize && \
      ./configure --prefix=/usr && \
      make && \
      make install && \
      rm -rf /tmp/*

# Let's keep the house clean
RUN docker-image-cleanup \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add bash aliases and terminal conf
RUN { \
      echo ' '; \
      echo '# Add bash aliases.'; \
      echo 'if [ -f /var/www/html/.aliases ]; then'; \
      echo '    source /var/www/html/.aliases'; \
      echo 'fi'; \
      echo ' '; \
      echo '# Add terminal config.'; \
      echo 'stty rows 80; stty columns 160;'; \
    } | tee -a /var/www/.bashrc /root/.bashrc

# Exposing ports
EXPOSE 80 443 9000

# Default work dir
WORKDIR "/var/www/html"

##########################################
#       Specific configurations
##########################################

# Set custom PHP.ini settings
RUN {  \
      echo ';;;;;;;;;; General ;;;;;;;;;;'; \
      echo 'memory_limit = 2048M'; \
      echo 'max_input_vars = 5000'; \
      echo 'upload_max_filesize = 64M'; \
      echo 'post_max_size = 64M'; \
      echo 'max_execution_time = 6000'; \
      echo 'date.timezone = Europe/Rome'; \
      echo 'extension = uploadprogress.so'; \
      echo ' '; \
      echo ';;;;;;;;;; Sendmail ;;;;;;;;;;'; \
      echo 'sendmail_path = /usr/sbin/sendmail -S mail:1025'; \
  } >> /opt/docker/etc/php/php.ini

# Check ownership and permission
RUN { \
      echo '# Check ssh_keys ownership and home dir permission'; \
      echo ' '; \      
      echo 'chown www-data:www-data /var/www && chmod 755 /var/www'; \
      echo ' '; \
      echo 'if [[ -f /var/www/.ssh/id_rsa ]]; then'; \
      echo '    chown www-data:www-data /var/www/.ssh/id_rsa'; \
      echo '    chmod 600 /var/www/.ssh/id_rsa'; \
      echo 'fi'; \
      echo 'if [[ -f /var/www/.ssh/id_rsa.pub ]]; then'; \
      echo '    chown www-data:www-data /var/www/.ssh/id_rsa.pub'; \
      echo '    chmod 600 /var/www/.ssh/id_rsa.pub'; \
      echo 'fi'; \
      echo 'if [[ -f /var/www/.ssh/authorized_keys ]]; then'; \
      echo '    chown www-data:www-data /var/www/.ssh/authorized_keys'; \
      echo '    chmod 600 /var/www/.ssh/authorized_keys'; \
      echo 'fi'; \
} >> /opt/docker/provision/entrypoint.d/05-ssh_keys.sh
