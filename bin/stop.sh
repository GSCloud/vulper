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

[ -z "$(docker ps | grep ${APP_NAME})" ] || docker stop $APP_NAME
[ ${PMA_DISABLE:=0} == 1 ] || ( [ -z "$(docker ps | grep ${PMA_NAME})" ] || docker stop $PMA_NAME )
[ -z "$(docker ps | grep ${DB_NAME})" ] || docker stop $DB_NAME
[ -z "$(docker ps | grep ${REDIS_NAME})" ] || docker stop $REDIS_NAME

exit 0
