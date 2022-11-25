.DEFAULT_GOAL: build-and-serve
.PHONY: aws build build-and-serve help page pipx post serve
.SILENT: help page post

S3_URL_ROOT = http://charlesthomas.dev.s3-website.us-east-2.amazonaws.com

AWS_CMD = aws --profile personal
PIPX_VENV_ROOT := $(shell pipx environment | grep PIPX_LOCAL_VENVS= | cut -d = -f 2)
STATIC_LOCAL = static/
STATIC_S3 = s3://charlesthomas.dev/static

build-and-serve: build serve ## hugo && hugo serve [DEFAULT]

build: ## run hugo
	hugo

serve: ## run server for testing
	hugo serve

content/%.md:
	hugo new $(*).md
	vim content/$(*).md

content/post/%.md:
	hugo new post/$(*).md
	vim content/post/$(*).md

page: ## create a new page at the content root
	read -p "title: " title; \
	make content/$${title}.md

post: ## create a new post in content/post/
	read -p "title: " title; \
	make content/post/$${title}-$$(date +%F).md

static-upload: | aws
	$(AWS_CMD) s3 sync --exclude .DS_Store $(STATIC_LOCAL) $(STATIC_S3)

static-download: | aws
	$(AWS_CMD) s3 sync $(STATIC_S3) $(STATIC_LOCAL)

help: ## show this help
	@awk 'BEGIN {FS = ":.*?## "}; /^.+: .*?## / && !/awk/ {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' ${MAKEFILE_LIST} | sort

aws: | $(PIPX_VENV_ROOT)/awscli/bin/aws

$(PIPX_VENV_ROOT)/awscli/bin/aws:
	pipx install awscli

pipx: | ${HOMEBREW_PREFIX}/bin/pipx

${HOMEBREW_PREFIX}/bin/pipx:
	brew install pipx
