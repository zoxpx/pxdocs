IMAGE?=pxdocs:latest

.PHONY: docker.image
docker.image:
	docker build -t $(IMAGE) .

.PHONY: update.theme
update.theme:
	git submodule update --remote --merge