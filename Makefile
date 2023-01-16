.DEFAULT_GOAL: build-and-serve
.PHONY: aws build build-and-serve clean clean-all help install-hooks page pipx post serve static-download static-upload
.SILENT: help page post

AWS_CMD = aws --profile personal
HUGO_VERSION ?= 0.109.0
HUGO_URL ?= https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_$(HUGO_VERSION)_darwin-universal.tar.gz
PIPX_VENV_ROOT := $(shell pipx environment | grep PIPX_LOCAL_VENVS= | cut -d = -f 2)
S3_URL_ROOT = http://charlesthomas.dev.s3-website.us-east-2.amazonaws.com
STATIC_LOCAL = static/
STATIC_S3 = s3://charlesthomas.dev/static

all: | build-and-serve

aws: | $(PIPX_VENV_ROOT)/awscli/bin/aws

build: | hugo themes/blackburn/theme.toml static-download ## run hugo
	./hugo

build-and-serve: | install-hooks build serve ## hugo && hugo serve [DEFAULT]

clean: ## clean public/
	-rm -rf public/
	-rm .hugo_build.lock

clean-all: clean ## clean hugo binary & themes submodule
	-rm hugo
	-rm -rf themes/

content/%.md: | hugo
	./hugo new $(*).md
	code content/$(*).md

content/post/%.md: | hugo
	./hugo new post/$(*).md
	code content/post/$(*).md

.git/hooks/%:
	cp etc/git-hooks/$(*) $(@)

help: ## show this help
	@awk 'BEGIN {FS = ":.*?## "}; /^.+: .*?## / && !/awk/ {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' ${MAKEFILE_LIST} | sort

install-hooks: .git/hooks/pre-push ## install git hooks

hugo: ## install hugo v$(HUGO_VERSION) from github releases
	curl -sL $(HUGO_URL) | \
	tar -zxv hugo

page: ## create a new page at the content root
	read -p "title: " title; \
	make content/$${title}.md

pipx: | ${HOMEBREW_PREFIX}/bin/pipx

post: ## create a new post in content/post/
	read -p "title: " title; \
	make content/post/$${title}-$$(date +%F).md

serve: | hugo ## run server for testing
	./hugo serve

static-download: | aws ## download static/ from s3
	$(AWS_CMD) s3 sync $(STATIC_S3) $(STATIC_LOCAL)

static-upload: | aws ## sync local static/ to s3
	$(AWS_CMD) s3 sync --exclude .DS_Store $(STATIC_LOCAL) $(STATIC_S3)

themes/blackburn/theme.toml:
	git submodule update

$(PIPX_VENV_ROOT)/awscli/bin/aws:
	pipx install awscli

${HOMEBREW_PREFIX}/bin/pipx:
	brew install pipx
