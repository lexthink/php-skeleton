#!/bin/bash

OS = $(shell uname)
UID = $(shell id -u)
DOCKER_NETWORK = lexthink-php_skeleton-network
DOCKER_PHP = lexthink-php_skeleton-php

help: ## Show this help message
	@echo 'usage: make [target]'
	@echo
	@echo 'targets:'
	@egrep '^(.+)\:\ ##\ (.+)' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

build: ## Rebuilds all the containers
	docker network create ${DOCKER_NETWORK} || true
	cp -n docker-compose.yaml.dist docker-compose.yaml || true
	cp -n .env.dist .env || true
	U_ID=${UID} docker-compose build

start: ## Start the containers
	docker network create ${DOCKER_NETWORK} || true
	cp -n docker-compose.yaml.dist docker-compose.yaml || true
	cp -n .env.dist .env || true
	U_ID=${UID} docker-compose up -d

stop: ## Stop the containers
	U_ID=${UID} docker-compose stop

restart: ## Restart the containers
	$(MAKE) stop && $(MAKE) start

install: ## Installs composer dependencies
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_PHP} composer install --no-interaction

migrations: ## Runs doctrine migrations
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_PHP} bin/console doctrine:migration:migrate -n --allow-no-migration

logs: ## Tails the Symfony dev log
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_PHP} tail -f var/log/dev.log

bash: ## bash into the be container
	U_ID=${UID} docker exec -it --user ${UID} ${DOCKER_PHP} bash

fix-style: ## Fix code style errors using php-cs-fixer and phpcbf
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_PHP} composer dev:fix-style

tests: ## Runs the entire test suite
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_PHP} composer dev:tests

coverage: ## Runs phpunit with xdebug and storage coverage in var/coverage/html/
	U_ID=${UID} docker exec --user ${UID} ${DOCKER_PHP} composer dev:coverage

.PHONY: help build start stop restart install migrations logs bash fix-style tests coverage
