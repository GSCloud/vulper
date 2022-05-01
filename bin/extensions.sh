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
[ -z ${APT_EXTRAS+x} ] && fail "Missing APT_EXTRAS definition!"
[ -z ${CMD_EXTRAS1+x} ] && fail "Missing CMD_EXTRAS1 definition!"
[ -z ${CMD_EXTRAS2+x} ] && fail "Missing CMD_EXTRAS2 definition!"
[ -z ${PHP_EXTENSIONS+x} ] && fail "Missing PHP_EXTENSIONS definition!"

# check if container is running
[ -z "$(docker ps | grep ${APP_NAME})" ] && fail "$APP_NAME is not running!"

echo "Updating APT"
docker exec $APP_NAME apt-get update -yqq

# command extras #1
[ ! -z "${CMD_EXTRAS1}" ] && docker exec $APP_NAME ${CMD_EXTRAS1}
# APT install
[ ! -z "${APT_EXTRAS}" ] && docker exec $APP_NAME apt-get install -yq ${APT_EXTRAS}
# PHP extensions install
[ ! -z "${PHP_EXTENSIONS}" ] && docker exec $APP_NAME docker-php-ext-install ${PHP_EXTENSIONS}
# command extras #2
[ ! -z "${CMD_EXTRAS2}" ] && docker exec $APP_NAME ${CMD_EXTRAS2}

echo "Restarting container"
docker restart $APP_NAME

exit 0
