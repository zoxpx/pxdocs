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
		-p 1313:1313 \
		-v "$(PWD):/pxdocs" \
		$(IMAGE) server --bind=0.0.0.0 --disableFastRender

.PHONY: publish
publish: image
	docker run -ti --rm \
		--name pxdocs-publish \
		-v "$(PWD):/pxdocs" \
		$(IMAGE)
