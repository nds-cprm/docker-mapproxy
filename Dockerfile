FROM python:3.6-slim-buster

ARG MAPPROXY_VERSION=1.11.0

ENV MAPPROXY_PROCESSES 4
ENV MAPPROXY_THREADS 2
ENV MAPPROXY_DIR /var/lib/mapproxy

RUN set -ex ; \
    apt-get update ; \
    apt-get install --no-install-recommends -y \
        libproj13 \
        libgeos-dev \
        libgdal-dev \
        build-essential \
        libjpeg-dev \
        zlib1g-dev \
        libfreetype6-dev ; \
    rm -rf /var/lib/apt/lists/* ; \
    groupadd -g 200 mapproxy ; \
    useradd -g 200 -u 200 -m -s /bin/bash mapproxy ; \
    mkdir -p $MAPPROXY_DIR ; \
    chown mapproxy.mapproxy $MAPPROXY_DIR ; \
    pip install --upgrade pip ; \
    pip install Shapely Pillow requests geojson uwsgi lxml MapProxy==$MAPPROXY_VERSION

RUN set -ex ; \
    mkdir -p /docker-entrypoint.d

COPY docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["mapproxy"]

USER mapproxy
VOLUME ["/mapproxy"]
EXPOSE 8080
# Stats
EXPOSE 9191
