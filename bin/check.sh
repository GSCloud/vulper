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
[ -z ${APP_PORT+x} ] && fail "Missing APP_PORT definition!"
[ -z ${DB_NAME+x} ] && fail "Missing DB_NAME definition!"
[ -z ${PHP_CHECK_EXTENSIONS+x} ] && fail "Missing PHP_CHECK_EXTENSIONS definition!"
[ -z ${PMA_NAME+x} ] && fail "Missing PMA_NAME definition!"
[ -z ${PMA_PORT+x} ] && fail "Missing PMA_PORT definition!"
[ -z ${REDIS_NAME+x} ] && fail "Missing REDIS_NAME definition!"

[ -z "$(docker ps | grep ${REDIS_NAME})" ] && warn "$REDIS_NAME is not running!"
[ ${PMA_DISABLE:=0} == 0 ] && [ -z "$(docker ps | grep ${PMA_NAME})" ] && fail "$PMA_NAME is not running!"
[ -z "$(docker ps | grep ${DB_NAME})" ] && fail "$DB_NAME is not running!"
[ -z "$(docker ps | grep ${APP_NAME})" ] && fail "$APP_NAME is not running!"

info "Docker containers (id, name, size, network, ports)"
docker ps --filter status=running --format '{{.ID}}\t{{.Names}}\t{{.Size}}\t{{.Networks}}\t{{.Ports}}' \
    | grep -E "${APP_NAME}|${DB_NAME}|${PMA_NAME}|${REDIS_NAME}"

if [ ! -z "$(docker ps | grep ${APP_NAME})" ]; then
    info "PHP Extensions"
    c=1
    for i in ${PHP_CHECK_EXTENSIONS}
    do
        if [ -n "$(docker exec $APP_NAME php -m | grep $i)" ]; then
            echo -en "$c. 🆗 OK $i "
        else
            echo -en "$c. ❌️ FAIL $i "
        fi
        ((c++))
    done
    echo -en "\n\n"

    echo -en "APP running at: \e[1;32mhttp://localhost:${APP_PORT}\e[0m\n"
    docker exec $APP_NAME php -i | grep 'memory_limit'
    docker exec $APP_NAME php -i | grep 'upload_max_filesize'
    echo -en "\n"
    
    if [ ${PMA_DISABLE:=0} == 0 ]; then
        echo -en "ADMIN running at: \e[1;32mhttp://localhost:${PMA_PORT}\e[0m\n"
        docker exec $PMA_NAME php -i | grep 'memory_limit'
        docker exec $PMA_NAME php -i | grep 'upload_max_filesize'
        echo -en "\n"
    fi

fi

echo "App logs available at: /tmp/${APP_NAME}/logs"

exit 0
