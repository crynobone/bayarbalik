#!/usr/bin/env bash

/usr/bin/mysql -uroot -p$1 -e "CREATE DATABASE IF NOT EXISTS bayarbalik DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"

cd /vagrant/

if [ ! -f .env ]; then
    cp ./build/provision/.env .env
fi

composer install --prefer-dist --no-dev
