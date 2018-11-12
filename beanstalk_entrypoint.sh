#!/usr/bin/env bash

set -e

APPLICATION_USER=${APPLICATION_USER:-application}
APPLICATION_GROUP=${APPLICATION_GROUP:-application}
APPLICATION_PATH=${APPLICATION_PATH:-/var/www/html}

# Change the files owner otherwise PHP app can not write
sudo chown -R ${APPLICATION_USER}:${APPLICATION_GROUP} ${APPLICATION_PATH}
sudo chmod -R 755 ${APPLICATION_PATH}