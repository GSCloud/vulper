#!/bin/bash
#@author Fred Brooker <git@gscloud.cz>

if [ ! -f "./bin/_includes.sh" ]; then
    echo -en "\n\n\e[1;31mMissing _includes.sh file!\e[0m\n\n"
    exit 1
fi
source ./bin/_includes.sh
command -v docker >/dev/null 2>&1 || fail "Docker is NOT installed!"
[ ! -r ".env" ] && fail "Missing .env file!"
source .env

###############################################################################

command -v ruby >/dev/null 2>&1 || fail "Ruby is NOT installed!"

echo -en "APP_IMAGE: $APP_IMAGE\nAPP_NAME: $APP_NAME\nAPP_PORT: $APP_PORT\nAPP_VOLUME: $APP_VOLUME\nAPT_EXTRAS: $APT_EXTRAS\nCMD_EXTRAS1: $CMD_EXTRAS1\nCMD_EXTRAS2: $CMD_EXTRAS2\nDB_IMAGE: $DB_IMAGE\nDB_INTERNAL_PORT: $DB_INTERNAL_PORT\nDB_NAME: $DB_NAME\nDB_PORT: $DB_PORT\nDB_VOLUME: $DB_VOLUME\nMYSQL_DATABASE_NAME:  $MYSQL_DATABASE_NAME\nMYSQL_PASSWORD: $MYSQL_PASSWORD\nMYSQL_ROOT_PASSWORD: $MYSQL_ROOT_PASSWORD\nMYSQL_USER: $MYSQL_USER\nPHP_CHECK_EXTENSIONS: $PHP_CHECK_EXTENSIONS\nPHP_EXTENSIONS: $PHP_EXTENSIONS\nPMA_IMAGE: $PMA_IMAGE\nPMA_NAME: $PMA_NAME\nPMA_PORT: $PMA_PORT\nPROJECT_NAME: $PROJECT_NAME\nREDIS_IMAGE: $REDIS_IMAGE\nREDIS_NAME: $REDIS_NAME\nREDIS_PORT: $REDIS_PORT\nREDIS_INTERNAL_PORT: $REDIS_INTERNAL_PORT\nREDIS_VOLUME: $REDIS_VOLUME\n" | ruby -r yaml -r json -e 'puts YAML.load($stdin.read).to_json'

exit 0
