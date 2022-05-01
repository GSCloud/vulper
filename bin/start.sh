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
[ -z ${REDIS_NAME+x} ] && fail "Missing REDIS_NAME definition!"

[ -z "$(docker ps -a | grep ${APP_NAME})" ] && fail "$APP_NAME is not available!"
[ -z "$(docker ps -a | grep ${DB_NAME})" ] && fail "$DB_NAME is not available!"
[ ${PMA_DISABLE:=0} == 0 ] && [ -z "$(docker ps -a | grep ${PMA_NAME})" ] && warn "$PMA_NAME is not available!"
[ -z "$(docker ps -a | grep ${REDIS_NAME})" ] && fail "$REDIS_NAME is not available!"


docker start $DB_NAME
docker start $REDIS_NAME
[ ${PMA_DISABLE:=0} == 0 ] && docker start $PMA_NAME
docker start $APP_NAME

exit 0
