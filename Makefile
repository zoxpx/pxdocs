IMAGE?=px-docs-spike:latest

.PHONY: docker.image
docker.image:
	docker build -t $(IMAGE) .

