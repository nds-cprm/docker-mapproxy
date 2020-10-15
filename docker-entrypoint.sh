#!/bin/bash
set -e

if [ "$1" = 'mapproxy' ]; then
  echo "Running additional provisioning"
  for f in /docker-entrypoint.d/*; do
    case "$f" in
      */*.sh)     echo "$0: running $f"; . "$f" ;;
      */mapproxy.yml)  cp /docker-entrypoint.d/mapproxy.yml $MAPPROXY_DIR/mapproxy.yaml ;;
      */mapproxy.yaml) cp /docker-entrypoint.d/mapproxy.yaml $MAPPROXY_DIR/mapproxy.yaml ;;
    esac
    echo
  done

  if [ ! -f $MAPPROXY_DIR/mapproxy.yaml ] ;then
    mapproxy-util create -t base-config $MAPPROXY_DIR/
  fi
  if [ ! -f $MAPPROXY_DIR/app.py ] ;then
    mapproxy-util create -t wsgi-app -f $MAPPROXY_DIR/mapproxy.yaml $MAPPROXY_DIR/app.py
  fi
  echo "Start mapproxy"

  # --wsgi-disable-file-wrapper is required because of https://github.com/unbit/uwsgi/issues/1126
  if [ "$2" = 'http' ]; then
    exec uwsgi --wsgi-disable-file-wrapper --http 0.0.0.0:8080 --wsgi-file $MAPPROXY_DIR/app.py --master --enable-threads --processes $MAPPROXY_PROCESSES --threads $MAPPROXY_THREADS --stats 0.0.0.0:9191
    exit
  fi

  exec uwsgi --wsgi-disable-file-wrapper --http-socket 0.0.0.0:8080 --wsgi-file $MAPPROXY_DIR/app.py --master --enable-threads --processes $MAPPROXY_PROCESSES --threads $MAPPROXY_THREADS --stats 0.0.0.0:9191
  exit
fi

exec "$@"
