.PHONY: default help
default: help

#!
#! Launching the application:
up:        ## Launch the app with debug access
bg:        ## Launch the app in the background
stop:      ## Shut down the app

#!
#! Common tasks:
test:      ## Run tests
console:   ## Launch a Rails console
sh:        ## Run Bash
bundle:    ## Install gems

#!
#! Viewing application status:
logs:      ## View logs for the running server
ps:        ## View running processes for the application

#!
#! Other:
help:      ## Show this message
	@egrep -h "##|#!" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//' | sed -e 's/: /  /' | sed -e 's/^/  make /' | sed -e 's/^[ ]*make #![ ]*//'
	@echo

# Meta-dependency for everything we need prior to running the app
.PHONY: deps
deps: tmp/docker-build vendor/bundle

.PHONY: bundle
bundle: tmp/docker-build
	docker-compose run --no-deps --rm app bundle install
	docker-compose run --no-deps --rm app bundle clean
	touch vendor/bundle

.PHONY: up
up: stop deps
	docker-compose up --no-recreate app

.PHONY: bg
bg: stop deps
	docker-compose up --no-recreate -d app

.PHONY: stop
stop:
	docker-compose stop app db

.PHONY: console
console: deps
	docker-compose run --rm app bundle exec rails console

.PHONY: test
test: deps
	@echo "Not implemented" && exit 1

.PHONY: sh
sh: tmp/docker-build
	docker-compose run --rm app /bin/bash

.PHONY: logs
logs:
	docker-compose logs app

.PHONY: ps
ps:
	docker-compose ps

# Physical files and directories
vendor/bundle: tmp/docker-build docker/app/Dockerfile $(wildcard Gemfile*)
	$(MAKE) bundle

tmp/docker-build: docker-compose.yml $(wildcard docker/app/*)
	docker-compose build app db
	touch tmp/docker-build
