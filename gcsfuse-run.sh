#!/bin/bash

MAGENTO_HOME=${MAGENTO_HOME:-/var/www/html/magento2}
BK_FRONT=${BK_FRONT:-admin_magento}
DB_HOST=${DB_HOST:-127.0.0.1}
DB_NAME=${DB_NAME:-magento}
DB_USER=${DB_USER:-magento}
DB_PASSWD=${DB_PASSWD:-password}
SESSION_SAVE=${SESSION_SAVE:-db}
MAGENTO_BASEURL=${MAGENTO_BASEURL:-magento.dev}
#MEDIABUCKET=
GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS:-/etc/bucketaccess.json}
USERID=$(id -u www-data)
GRPID=$(id -g www-data)
yes | $MAGENTO_HOME/bin/magento setup:config:set \
--backend-frontname="$BK_FRONT" \
--db-host="$DB_HOST" \
--db-name="$DB_NAME" \
--db-user="$DB_USER" \
--db-password="$DB_PASSWD" \
--session-save="$SESSION_SAVE"
chmod -R 777 /var/www/html/magento2 

sed -i "s/magento_servername/$HOSTNAME/g" /etc/nginx/sites-available/default

/usr/sbin/nginx -t

if [ $? -eq 0 ] && [ -f "$GOOGLE_APPLICATION_CREDENTIALS" ];
then
	/usr/bin/gcsfuse --uid $(id -u www-data) --gid $(id -g www-data) --dir-mode="777" --file-mode="777" -o allow_other -o nonempty $MEDIABUCKET $MAGENTO_HOME/pub/media
	/etc/init.d/php7.0-fpm start && nginx -g 'daemon off;'
else 
	echo "Error in nginx configurations";
fi
