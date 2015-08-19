#!/bin/bash
set -e

DRUSH=/home/application/current/vendor/bin/drush
DRUPAL_ROOT_DIR=/home/application/current


if [ -z "$SITE_PROFILE" ]; then
    SITE_PROFILE=standard
fi

if [ -z "$ADMIN_PASSWORD" ]; then
    ADMIN_PASSWORD=admin
fi


if ! $DRUSH status | grep -i 'drupal bootstrap' | grep -i 'successful'; then
     $DRUSH site-install ${SITE_PROFILE} --root=/home/application/current --site-name=${TSURU_APPNAME} --account-pass=${ADMIN_PASSWORD} --db-url=mysql://$MYSQL_USER:$MYSQL_PASSWORD@$MYSQL_HOST:$MYSQL_PORT/$MYSQL_DATABASE_NAME ${EXTRA_OPTS} --yes
fi

if [ ! -f "/shared" ]; then
    ln -s /shared ${DRUPAL_ROOT_DIR}/sites/default/files
fi
