#!/usr/bin/env bash

set -e

# Change the files owner otherwise Drupal can not write
chown -R application:application /var/www/html
chmod -R 755 /var/www/html