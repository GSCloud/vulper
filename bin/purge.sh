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
[ -z ${DB_VOLUME+x} ] && fail "Missing DB_VOLUME definition!"
[ -z ${PMA_NAME+x} ] && fail "Missing PMA_NAME definition!"
[ -z ${REDIS_NAME+x} ] && fail "Missing PMA_NAME definition!"

[ ! -z "$(docker ps -a | grep ${APP_NAME})" ] && docker rm ${APP_NAME} --force
[ ! -z "$(docker ps -a | grep ${PMA_NAME})" ] && docker rm ${PMA_NAME} --force
[ ! -z "$(docker ps -a | grep ${DB_NAME})" ] && docker rm ${DB_NAME} --force
[ ! -z "$(docker ps -a | grep ${REDIS_NAME})" ] && docker rm ${REDIS_NAME} --force

if [ -d "$DB_VOLUME" ]; then
    yes_or_no "Remove database folder?" \
        && info "Removing database folder" \
        && sudo rm -rf "$DB_VOLUME" \
        && echo "Done."
fi

if [ -d "$REDIS_VOLUME" ]; then
    yes_or_no "Remove cache folder?" \
        && info "Removing cache folder" \
        && sudo rm -rf "$REDIS_VOLUME" \
        && echo "Done."
fi

echo "App logs available at: /tmp/${APP_NAME}/logs"

exit 0
