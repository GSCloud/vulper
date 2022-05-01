# Vulper
[https://github.com/GSCloud/vulper]

Base PHP 8.1 docker container app.  
Deploys containers: **app**, **db**, **cache** and **phpmyadmin** *(optional)*.

## Makefile

Run `make` for detailed help.

## Prerequisites

 - Docker environment [https://docs.docker.com/get-docker/]
 - `sudo apt install make` - Makefile processor
 - `sudo apt install ruby-full` - for YAML 2 JSON conversions only

## Logic

1) WEB: www/**index.php** > app/**Bootstrap.php** > app/**Web.php**
2) CLI: ./**cli.sh** > app/**Bootstrap.php** > app/**Cli.php**

Bootstrap role is to set all the constants, import Composer autoloader, load config and router definitions, setup debugger and execute the Web or Cli app. Debugger can be extensively modified using **config.neon**.

## Configuration

 - **.env** - environment
 - **app/config.neon** - main app config
 - **app/router.neon** - main app router
 - **www/.htaccess** - Apache 2 htaccess
 - **INI/** - ini files to alter resource limits, post and upload limits, default timezone
 - **CLI_REQ** - environment variable to use if CLI SAPI is detected, set it to pass a PHP require file that can load extra data, alter settings or override default constants

Configuration is stored in the **.env** file. Demo configurations are available as **env...-redist** files. Copy a configuration file over the **.env** and run `make`.

Make sure to remove containers before changing ports in the **.env**.  
There is also an **env.mustache** template available for programmatic environment creation.

## Constants

 - **APP** - points to the app/ folder
 - **CLI** - set tu true if CLI SAPI is detected
 - **DS** - directory separator shortcut
 - **LOCALHOST** - set tu true if localhost is detected
 - **ROOT** - full path to the Vulper folder
 - **WWW** - full path to the www/ folder

## Configuration Commands

 - `make cfg` - show docker-compose configuration
 - `make jsoncfg` - show docker-compose configuration as JSON
 - `make jsonapp` - show environment as JSON

There are some extra INI files in the INI/ folder, mapped to the containers.

## Router

Web routes are stored in **router.neon***. The *defaults* are applied to all the routes. Every route must set the *path*, *controller* and corresponding *view*, if not using the default values.

## Installation

  - `make install` - create docker images
  - `make install extensions` - create docker images, add PHP extensions
  - `make check` - check running containers

## Development

 - `make exec` - run Bash in the app container
 - `make applog` - show app logs of the app container
 - `make csfixer` - run PHP CS-FIXER in app/ folder
 - `make phpstan` - run PHPStan static analysis in app/ folder
 - `make test` - run Nette tester tests in app/ folder

## Container Operations

 - `make start` - resume stopped containers
 - `make stop` - stop containers

Always use `install` to create containers if they got removed.

❗ PMA container can be disabled in the environment by setting **PMA_DISABLE=1**

## Cleaning and Removal

 - `make remove` - remove containers
 - `make purge` - remove containers + database folder

## Logging

Tracy logs and exceptions are mapped outside the container and available at: **/tmp/${APP_NAME}/logs**

## To Do

 - Dockerfile
   - build
   - push
 - database access
 - database operations
   - export
   - import
 - tests
   - codeception
