FROM webdevops/php-nginx:7.2

# Environment variables
ENV APPLICATION_PATH=/var/www/html \
    WEB_DOCUMENT_ROOT=/var/www/html/web \
    ROBO_DRUPAL8_ENV=stage

# Commont tools
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y \
      gettext \
      libpng16-16 \
      libjpeg62-turbo-dev \
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

# The executable for post deploy operations
COPY beanstalk_entrypoint.sh /usr/local/bin/beanstalk_entrypoint
RUN chmod a+rx /usr/local/bin/beanstalk_entrypoint

# Encrypted Drupal Database Connections with Amazon RDS
ADD https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem  /etc/ssl/certs/rds-combined-ca-bundle.pem
RUN chmod 755 /etc/ssl/certs/rds-combined-ca-bundle.pem

# Pagespeed
RUN apt-get purge nginx -y
COPY install_pagespeed.sh /tmp/install_pagespeed.sh
RUN chmod a+rx /tmp/install_pagespeed.sh && ./tmp/install_pagespeed.sh

# Let's keep the house clean
RUN docker-image-cleanup \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Change user
USER application

# Composer parallel install plugin
RUN composer global require hirak/prestissimo

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
    } >> ~/.bashrc

# Default work dir
WORKDIR "/var/www/html"