.DEFAULT_GOAL: build-and-serve
.PHONY: build build-and-serve help page post serve
.SILENT: help page post

HUGO_VERSION ?= 0.109.0
HUGO_URL ?= https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_$(HUGO_VERSION)_darwin-universal.tar.gz

build-and-serve: build serve ## hugo && hugo serve [DEFAULT]

build: | hugo themes/blackburn/theme.toml ## run hugo
	./hugo

serve: | hugo ## run server for testing
	./hugo serve

clean: ## clean public/
	-rm -rf public/
	-rm .hugo_build.lock

clean-all: clean ## clean hugo binary & themes submodule
	-rm hugo
	-rm -rf themes/

content/%.md: | hugo
	./hugo new $(*).md
	vim content/$(*).md

content/post/%.md: | hugo
	./hugo new post/$(*).md
	vim content/post/$(*).md

help: ## show this help
	@awk 'BEGIN {FS = ":.*?## "}; /^.+: .*?## / && !/awk/ {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' ${MAKEFILE_LIST} | sort

hugo: ## install hugo v$(HUGO_VERSION) from github releases
	curl -sL $(HUGO_URL) | \
	tar -zxv hugo

page: ## create a new page at the content root
	read -p "title: " title; \
	make content/$${title}.md

post: ## create a new post in content/post/
	read -p "title: " title; \
	make content/post/$${title}-$$(date +%F).md

themes/blackburn/theme.toml:
	git submodule update
