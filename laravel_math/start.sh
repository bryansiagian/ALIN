#!/bin/bash
cd /var/www/html

cat > .env << EOF
APP_NAME=${APP_NAME:-ALIN}
APP_ENV=${APP_ENV}
APP_KEY=${APP_KEY}
APP_DEBUG=${APP_DEBUG}
APP_URL=${APP_URL}

LOG_CHANNEL=stderr

DB_CONNECTION=${DB_CONNECTION}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
EOF

php artisan config:clear
php artisan route:clear
php artisan cache:clear

mysql -h ${DB_HOST} -P ${DB_PORT} -u ${DB_USERNAME} -p${DB_PASSWORD} \
  -e "CREATE DATABASE IF NOT EXISTS \`${DB_DATABASE}\`;" 2>/dev/null || true

php artisan migrate --force

php-fpm -D
sleep 3

nginx -g "daemon off;"
