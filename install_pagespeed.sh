#!/usr/bin/env bash

OPENSSL_VERSION=1.1.1
cd /opt
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
tar -xzvf openssl-${OPENSSL_VERSION}.tar.gz
rm openssl-${OPENSSL_VERSION}.tar.gz

PCRE_VERSION=8.42
cd /opt
wget https://ftp.pcre.org/pub/pcre/pcre-${PCRE_VERSION}.tar.gz 
tar xzvf pcre-${PCRE_VERSION}.tar.gz
rm pcre-${PCRE_VERSION}.tar.gz

ZLIB_VERSION=1.2.11
cd /opt
wget http://www.zlib.net/zlib-${ZLIB_VERSION}.tar.gz
tar xzvf zlib-${ZLIB_VERSION}.tar.gz
rm zlib-${ZLIB_VERSION}.tar.gz

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

NGINX_VERSION=1.15.6
cd /opt
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xvzf nginx-${NGINX_VERSION}.tar.gz
rm nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}
./configure \
--user=${APPLICATION_USER} \
--group=${APPLICATION_GROUP} \
--with-debug \
--with-pcre-jit \
--with-ipv6 \
--with-http_ssl_module \
--with-http_stub_status_module \
--with-http_realip_module \
--with-http_auth_request_module \
--with-http_v2_module \
--with-http_dav_module \
--with-http_slice_module \
--with-threads \
--with-http_addition_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_sub_module \
--with-stream_ssl_module \
--with-mail_ssl_module \
--with-openssl=/opt/openssl-${OPENSSL_VERSION} \
--with-pcre=/opt/pcre-${PCRE_VERSION} \
--with-zlib=/opt/zlib-${ZLIB_VERSION} \
--add-module=/opt/incubator-pagespeed-ngx-${NPS_VERSION}/ ${PS_NGX_EXTRA_FLAGS}

make && make install

ln -s /usr/local/nginx/conf/ /etc/nginx
ln -s /usr/local/nginx/sbin/nginx /usr/sbin/nginx

mkdir -p /var/cache/ngx_pagespeed
mkdir -p /pagespeed_static
mkdir -p /ngx_pagespeed_beacon

chown -R ${APPLICATION_USER}:${APPLICATION_GROUP} /var/cache/ngx_pagespeed  && \
chown -R ${APPLICATION_USER}:${APPLICATION_GROUP} /pagespeed_static && \
chown -R ${APPLICATION_USER}:${APPLICATION_GROUP} /ngx_pagespeed_beacon && \

chmod -R 755 /var/cache/ngx_pagespeed
chmod -R 755 /pagespeed_static
chmod -R 755 /ngx_pagespeed_beacon