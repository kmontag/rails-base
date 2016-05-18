.PHONY: default help
default: help

#!
#! Launching the application:
up:        ## Launch the app with debug access
debug:     ## Launch the app in the background
stop:      ## Shut down the app

#!
#! Common tasks:
test:      ## Run tests
console:   ## Launch a Rails console
sh:        ## Run Bash in the app container
sh-js:     ## Run Bash in the JS container
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
deps: tmp/docker-build vendor/bundle node_modules

.PHONY: bundle
bundle: tmp/docker-build
	docker-compose run --no-deps --rm app bundle install
	docker-compose run --no-deps --rm app bundle clean
	touch vendor/bundle/

.PHONY: npm
npm: tmp/docker-build
	docker-compose run --no-deps --rm js npm install
	touch node_modules/

.PHONY: up
up: stop deps
	docker-compose up -d app js

.PHONY: debug
debug: stop deps
	docker-compose up -d js
	docker-compose up app

.PHONY: stop
stop:
	docker-compose stop app db js

.PHONY: console
console: deps
	docker-compose run --rm app bundle exec rails console

.PHONY: test
test: deps
	@echo "Not implemented" && exit 1

.PHONY: sh
sh: tmp/docker-build
	docker-compose run --rm app /bin/bash

.PHONY: sh-js
sh-js: tmp/docker-build
	docker-compose run --rm js /bin/bash

.PHONY: logs
logs:
	docker-compose logs app

.PHONY: ps
ps:
	docker-compose ps

# Physical files and directories
vendor/bundle: tmp/docker-build docker/app/Dockerfile $(wildcard Gemfile*)
	$(MAKE) bundle

node_modules: tmp/docker-build docker/js/Dockerfile package.json
	$(MAKE) npm

tmp/docker-build: docker-compose.yml $(wildcard docker/*/*)
	docker-compose build app db js
	touch tmp/docker-build
