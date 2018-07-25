IMAGE?=pxdocs:developer

.PHONY: image
image:
	docker build -t $(IMAGE) .

.PHONY: update-theme
update-theme:
	git submodule update --remote --merge

.PHONY: develop
develop: image
	docker run -ti --rm \
		--name pxdocs-develop \
		-e VERSIONS_ALL \
		-e VERSIONS_CURRENT \
		-e VERSIONS_BASE_URL \
		-e ALGOLIA_APP_ID \
		-e ALGOLIA_API_KEY \
		-e ALGOLIA_INDEX_NAME \
		-p 1313:1313 \
		-v "$(PWD):/pxdocs" \
		$(IMAGE) server --bind=0.0.0.0 --disableFastRender

.PHONY: publish
publish: image
	docker run -ti --rm \
		--name pxdocs-publish \
		-e VERSIONS_ALL \
		-e VERSIONS_CURRENT \
		-e VERSIONS_BASE_URL \
		-e ALGOLIA_APP_ID \
		-e ALGOLIA_API_KEY \
		-e ALGOLIA_INDEX_NAME \
		-v "$(PWD):/pxdocs" \
		$(IMAGE) -v --debug --gc --ignoreCache --cleanDestinationDir
