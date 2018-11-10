#!/usr/bin/env bash

NPS_VERSION=1.13.35.2-stable
cd /opt
wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip
unzip v${NPS_VERSION}.zip
rm v${NPS_VERSION}.zip
nps_dir="incubator-pagespeed-ngx-${NPS_VERSION}"
cd /opt/$nps_dir
NPS_RELEASE_NUMBER=${NPS_VERSION/beta/}
NPS_RELEASE_NUMBER=${NPS_VERSION/stable/}
psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
wget ${psol_url}
tar -xzvf $(basename ${psol_url})
rm ${NPS_VERSION}*.tar.gz

NGINX_VERSION=1.15.6
cd /opt
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xvzf nginx-${NGINX_VERSION}.tar.gz
rm nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}
./configure --user=application --group=application --add-module=/opt/incubator-pagespeed-ngx-1.13.35.2-stable/ ${PS_NGX_EXTRA_FLAGS}

make && make install

ln -s /usr/local/nginx/conf/ /etc/nginx
ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx

mkdir -p /var/cache/ngx_pagespeed
mkdir -p /pagespeed_static
mkdir -p /ngx_pagespeed_beacon

chown -R application:application /var/cache/ngx_pagespeed
chown -R application:application /pagespeed_static
chown -R application:application /ngx_pagespeed_beacon

chmod -R 755 /var/cache/ngx_pagespeed
chmod -R 755 /pagespeed_static
chmod -R 755 /ngx_pagespeed_beacon