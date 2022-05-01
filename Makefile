#@author Fred Brooker <git@gscloud.cz>
include .env
app_dock != docker ps | grep ${APP_NAME}

all: info

info:
	@echo "\e[1;34m👾 Welcome to ${PROJECT_NAME}"
ifeq ($(strip $(PMA_DISABLE)),1)
	@echo "\e[90mEnvironment: \e[0;1m${APP_IMAGE}${DB_IMAGE}\e[90mExtensions: \e[0;1m${PHP_CHECK_EXTENSIONS}\e[0m"
else
	@echo "\e[90mEnvironment: \e[0;1m${APP_IMAGE}${DB_IMAGE}${PMA_IMAGE}\e[90mExtensions: \e[0;1m${PHP_CHECK_EXTENSIONS}\e[0m"
endif
	@echo ""
	@echo "\e[92mConfiguration / Documentation\e[0m"
	@echo "🆘 \e[0;1mmake cfg\e[0m \t\t- show Docker config"
	@echo "🆘 \e[0;1mmake jsoncfg\e[0m \t- show Docker config as JSON"
	@echo "🆘 \e[0;1mmake jsonapp\e[0m \t- show application config as JSON"
	@echo "🆘 \e[0;1mmake docs\e[0m \t\t- build documentation"
	@echo ""
	@echo "\e[92mContainers\e[0m"
	@echo "🆘 \e[0;1mmake install\e[0m \t- install and start containers"
	@echo "🆘 \e[0;1mmake extensions\e[0m \t- install PHP extensions"
	@echo "🆘 \e[0;1mmake check\e[0m \t\t- check running configuration"
	@echo "🆘 \e[0;1mmake start\e[0m \t\t- resume containers"
	@echo "🆘 \e[0;1mmake stop\e[0m \t\t- stop containers"
	@echo "🆘 \e[0;1mmake remove\e[0m \t\t- remove all containers"
	@echo "🆘 \e[0;1mmake purge\e[0m \t\t- purge installation ❗ DB DATA WILL VANISH"
	@echo ""
	@echo "\e[92mDeveloper Tools\e[0m"
	@echo "🆘 \e[0;1mmake applog\e[0m \t\t- show app container logs"
	@echo "🆘 \e[0;1mmake csfixer\e[0m \t- run CS-FIXER on app/"
	@echo "🆘 \e[0;1mmake exec\e[0m \t\t- execute bash in the app container"
	@echo "🆘 \e[0;1mmake phpstan\e[0m \t- run static analysis on app/"
	@echo "🆘 \e[0;1mmake refresh\e[0m \t- restart app container"
	@echo "🆘 \e[0;1mmake test\e[0m \t\t- run tests in app/"

applog:
	@docker logs -f --details ${APP_NAME}

refresh:
ifneq ($(strip $(app_dock)),)
	@echo "Application container details: \e[0;1m${app_dock}\e[0m"
	@docker restart ${APP_NAME}
else
	@echo "Container is not running."
endif

docs:
	@echo "🔨 \e[1;32m Building documentation\e[0m"
	@bash ./bin/create_pdf.sh

install:
	@echo "🔨 \e[1;32m Installing containers\e[0m"
	@bash ./bin/install.sh

extensions:
	@echo "🔨 \e[1;32m Installing PHP extensions\e[0m"
	@bash ./bin/extensions.sh

stop:
	@echo "🔨 \e[1;32m Stopping containers\e[0m"
	@bash ./bin/stop.sh

start:
	@echo "🔨 \e[1;32m Resuming containers\e[0m"
	@bash ./bin/start.sh

remove:
	@echo "🔨 \e[1;32m Removing containers\e[0m"
	@bash ./bin/remove.sh

cfg:
	@echo "🔨 \e[1;32m Configuration\e[0m"
	@docker-compose config

jsoncfg:
	@bash ./bin/configjson.sh

jsonapp:
	@bash ./bin/exportconfig.sh

check:
	@echo "🔨 \e[1;32m Checking configuration\e[0m"
	@bash ./bin/check.sh

exec:
ifneq ($(strip $(app_dock)),)
	@bash ./bin/execbash.sh
else
	@echo "Container is not running."
endif

purge:
	@echo "🔨 \e[1;32m Purging installation\e[0m"
	@bash ./bin/purge.sh

csfixer:
	./bin/php-cs-fixer/vendor/bin/php-cs-fixer fix app

phpstan:
	docker run -v ${PWD}:/app --rm ghcr.io/phpstan/phpstan analyze app

test:
	./vendor/bin/tester .

# basic worflow: install containers, add PHP extensions (will reuse database data), runtime check
everything: install extensions check
