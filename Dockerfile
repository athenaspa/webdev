FROM webdevops/php-nginx:7.3

# Environment variables
ENV APPLICATION_PATH=/var/www/html \
    WEB_DOCUMENT_ROOT=/var/www/html/web \
    ROBO_DRUPAL8_ENV=stage

# Commont tools
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y \
      sudo \
      gettext \
      libfreetype6-dev \
      mysql-client \
      build-essential \
      libpcre3-dev \
      uuid-dev \
      nano

# Reconfigure GD
RUN docker-php-ext-configure gd \
      --with-gd \
      --with-freetype-dir=/usr/include/ \
      --with-png-dir=/usr/include/ \
      --with-jpeg-dir=/usr/include/

# Encrypted Database Connections with Amazon RDS
ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem  /etc/ssl/certs/rds-combined-ca-bundle.pem
RUN chmod 755 /etc/ssl/certs/rds-combined-ca-bundle.pem

# Pagespeed support
RUN apt-get purge nginx nginx-common -y
COPY install_pagespeed.sh /tmp/install_pagespeed.sh
RUN chmod a+rx /tmp/install_pagespeed.sh && ./tmp/install_pagespeed.sh
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
RUN sed -i "1iuser ${APPLICATION_USER};" /usr/local/nginx/conf/nginx.conf

# Add application user to sudoers
RUN usermod -aG sudo ${APPLICATION_USER} \ 
    && echo "${APPLICATION_USER} ALL=(ALL:ALL) NOPASSWD: ALL" >> /etc/sudoers.d/${APPLICATION_USER}

# WIP: bypass https://www.drupal.org/project/redis/issues/3068810 issue
RUN pecl install -f redis-4.3.0

# Finalize installation and clean up
RUN docker-service enable postfix \
    && docker-run-bootstrap \
    && docker-image-cleanup \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Change user
USER ${APPLICATION_USER}

# Composer parallel install plugin
RUN composer global require hirak/prestissimo

# Add bash aliases and terminal conf
RUN { \
      echo ' '; \
      echo '# Add bash aliases.'; \
      echo 'if [ -f $APPLICATION_PATH/.aliases ]; then'; \
      echo '    source $APPLICATION_PATH/.aliases'; \
      echo 'fi'; \
      echo ' '; \
      echo '# Add terminal config.'; \
      echo 'stty rows 80; stty columns 160;'; \
    } >> ~/.bashrc

# Container must start as root user
USER root

# Default work dir
WORKDIR ${APPLICATION_PATH}