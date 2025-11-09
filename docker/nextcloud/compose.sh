#!/bin/sh
docker-compose --env-file /run/secrets/nextcloud.env "$@"
