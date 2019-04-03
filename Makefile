DATOMIC_VERSION = $(shell grep '^ARG DATOMIC_VERSION=' Dockerfile | cut -d'=' -f2)

.PHONY: all image push

all: image

image:
	docker build --pull \
		-t gordonstratton/datomic-free-transactor:latest \
		.

push: image
	docker tag gordonstratton/datomic-free-transactor:latest \
		gordonstratton/datomic-free-transactor:$(DATOMIC_VERSION)
	docker push gordonstratton/datomic-free-transactor:latest
	docker push gordonstratton/datomic-free-transactor:$(DATOMIC_VERSION)
