#@author Fred Brooker <git@gscloud.cz>

ARG CODE_VERSION=${APP_IMAGE}
ARG DEBIAN_FRONTEND=noninteractive
ARG LC_ALL=en_US.UTF-8
ARG TERM=linux

FROM php:${CODE_VERSION}
ENV TERM=xterm LANG=C.UTF-8 LC_ALL=C.UTF-8

RUN apt-get update -qq && apt-get upgrade -yqq && apt-get install -yqq --no-install-recommends curl openssl redis
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions redis
RUN a2enmod rewrite expires headers && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false

COPY INI/php.ini /usr/local/etc/php/
COPY app/* /var/www/app/
COPY composer.* /var/www/
COPY vendor /var/www/vendor
COPY www /var/www/html

WORKDIR /var/www/
EXPOSE 80
