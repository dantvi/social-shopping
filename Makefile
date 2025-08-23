# One-command helpers to bootstrap, run and install a local WordPress/WooCommerce stack

SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

PROJECT ?= social-shopping
WP_URL  ?= http://localhost:8084
ADMIN_USER  ?= daniel
ADMIN_PASS  ?= notSecureChangeMe
ADMIN_EMAIL ?= you@example.com

.PHONY: help bootstrap build up down nuke logs ps env wp-download wp-install wp

help:
	@echo "Targets: bootstrap | build | up | down | nuke | logs | ps | env | wp-download | wp-install | wp"

bootstrap: ## Clone classroom plugin & theme
	bash scripts/bootstrap.sh

build: ## Build Docker images
	docker compose build

up: ## Start stack in background
	docker compose -p $(PROJECT) up -d

down: ## Stop and remove containers (keeps DB volume)
	docker compose down

nuke: ## Stop stack and remove volumes (DESTROYS DB DATA)
	docker compose down -v

logs: ## Tail container logs
	docker compose logs -f --tail=150

ps: ## Show running containers
	docker compose ps

env: ## Create .env from example if missing
	@test -f .env || cp .env.example .env

wp-download: ## Download WordPress core into ./html if missing
	@[ -d html/wp-admin ] || ( mkdir -p html && curl -L https://wordpress.org/latest.tar.gz | tar -xz --strip-components=1 -C html )

wp-install: ## Install WP core, set permalinks, activate WooCommerce
	docker compose run --rm wpcli bash -lc '\
	  until wp db check >/dev/null 2>&1; do echo "Waiting for DB..."; sleep 2; done; \
	  if ! wp core is-installed >/dev/null 2>&1; then \
	    wp core install \
	      --url="$(WP_URL)" \
	      --title="FSU24D Social Shopping" \
	      --admin_user="$(ADMIN_USER)" \
	      --admin_password="$(ADMIN_PASS)" \
	      --admin_email="$(ADMIN_EMAIL)" \
	      --skip-email; \
	    wp rewrite structure "/%postname%/" --hard; \
