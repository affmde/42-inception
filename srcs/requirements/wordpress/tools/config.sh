#!/bin/bash

# create directory to use in nginx container later and also to setup the wordpress conf
mkdir /var/www/
mkdir /var/www/html

cd /var/www/html

# remove all the wordpress files if there is something from the volumes to install it again
rm -rf *

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar 

chmod +x wp-cli.phar 

mv wp-cli.phar /usr/local/bin/wp

wp core download --allow-root

mv /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

sed -i -r "s/db/$MYSQL_NAME/1"   wp-config.php
sed -i -r "s/user/$MYSQL_USER/1"  wp-config.php
sed -i -r "s/db_passwd/$MYSQL_PSW/1"    wp-config.php
sed -i -r "s/localhost/mariadb/1"    wp-config.php

wp core install --url=$DOMAIN_NAME/ --title=$WP_TITLE --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASSWORD --admin_email=$WP_ADMIN_EMAIL --skip-email --allow-root


wp user create $WP_USER $WP_EMAIL --role=author --user_pass=$WP_USER_PASSWORD --allow-root

wp theme install astra --activate --allow-root

sed -i 's/listen = \/run\/php\/php7.3-fpm.sock/listen = 9000/g' /etc/php/7.3/fpm/pool.d/www.conf

mkdir /run/php

/usr/sbin/php-fpm7.3 -F