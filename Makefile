.DEFAULT_GOAL: build-and-serve
.PHONY: build build-and-serve help page post serve
.SILENT: help page post

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

help: ## show this help
	@awk 'BEGIN {FS = ":.*?## "}; /^.+: .*?## / && !/awk/ {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' ${MAKEFILE_LIST} | sort
