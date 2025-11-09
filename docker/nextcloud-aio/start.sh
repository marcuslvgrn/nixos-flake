#!/bin/sh
docker run \
  -d \
  --name nextcloud-aio-mastercontainer \
  --restart=always \
  -p 80:80 -p 8080:8080 \
  -v nextcloud_aio_mastercontainer:/mnt/docker-aio-config \
  nextcloud/all-in-one:latest
