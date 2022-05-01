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

[ -z ${APP_NAME+x} ] && fail "Missing APP_NAME definition!"
[ -z ${DB_NAME+x} ] && fail "Missing DB_NAME definition!"
[ -z ${PMA_NAME+x} ] && fail "Missing PMA_NAME definition!"
[ -z ${CMD_EXTRAS1+x} ] && fail "Missing CMD_EXTRAS1 definition!"
[ -z ${DB_VOLUME+x} ] && fail "Missing DB_VOLUME definition!"

# make empty volumes
mkdir -p "${DB_VOLUME}" "${REDIS_VOLUME:=''}"

# make empty logs folder
APP_LOGS="/tmp/${APP_NAME}/logs" # path to Tracy logs
mkdir -p "$APP_LOGS"

info "Installing containers"
if [ ${PMA_DISABLE:=0} == 1 ]; then
    docker-compose up -d app
else
    docker-compose up -d
fi
docker exec $APP_NAME cp -u /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
docker exec $APP_NAME pear config-set php_ini /usr/local/etc/php/php.ini

# command extras #1
[ ! -z "${CMD_EXTRAS1}" ] && docker exec $APP_NAME ${CMD_EXTRAS1} && docker restart $APP_NAME && echo ""

echo -en "APP running at: \e[1;32mhttp://localhost:${APP_PORT}\e[0m\n"
docker exec $APP_NAME chmod 0777 /tmp/logs
docker exec $APP_NAME php -i | grep 'memory_limit'
docker exec $APP_NAME php -i | grep 'upload_max_filesize'
echo ""

if [ ${PMA_DISABLE:=0} == 0 ]; then
    echo -en "ADMIN running at: \e[1;32mhttp://localhost:${PMA_PORT}\e[0m\n"
    docker exec $PMA_NAME php -i | grep 'memory_limit'
    docker exec $PMA_NAME php -i | grep 'upload_max_filesize'
    echo ""
fi

echo "App logs available at: /tmp/${APP_NAME}/logs"

exit 0
