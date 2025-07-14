#!/usr/bin/env bash
cp -r /run/secrets/ssh/authorized_keys/lovgren /home/lovgren/.ssh/authorized_keys
chmod 600 /home/lovgren/.ssh/authorized_keys
chown 1000:100 /home/lovgren/.ssh/authorized_keys
