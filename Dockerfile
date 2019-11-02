FROM debian:stable AS build

ARG DATOMIC_VERSION=0.9.5703.21
ARG DATOMIC_IDENTIFIER=datomic-free-${DATOMIC_VERSION}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    patch \
    unzip \
  && curl -sSLo /tmp/${DATOMIC_IDENTIFIER}.zip \
    https://my.datomic.com/downloads/free/${DATOMIC_VERSION} \
  && unzip -qd /tmp /tmp/${DATOMIC_IDENTIFIER}.zip \
  && mv /tmp/${DATOMIC_IDENTIFIER} /srv/datomic

COPY patch /tmp/datomic-patch

RUN \
  patch /srv/datomic/bin/logback.xml \
    < /tmp/datomic-patch/00-logback-output-to-console.patch \
  && patch /srv/datomic/config/samples/free-transactor-template.properties \
    < /tmp/datomic-patch/10-docker-transactor-properties.patch \
  && mv /srv/datomic/config/samples/free-transactor-template.properties \
    /srv/datomic/config/transactor.properties

FROM openjdk:8u232-jre
LABEL maintainer="Gordon Stratton <gordon.stratton@gmail.com>"

RUN groupadd -r datomic && useradd -r -g datomic datomic

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    gosu \
  && rm -rf /var/lib/apt/lists/*

COPY --from=build /srv/datomic /srv/datomic

COPY docker-entrypoint.sh /usr/local/bin/

RUN mkdir /srv/datomic/data \
  && chown -R datomic:datomic /srv/datomic/data

VOLUME /srv/datomic/data

EXPOSE 4334-4336

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

CMD ["/srv/datomic/config/transactor.properties"]
