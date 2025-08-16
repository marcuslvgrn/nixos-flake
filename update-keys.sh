#!/usr/bin/env bash
cp /run/secrets/ssh/authorized_keys/lovgren /home/lovgren/.ssh/authorized_keys
chmod 600 /home/lovgren/.ssh/authorized_keys
chown 1000:100 /home/lovgren/.ssh/authorized_keys
cp /run/secrets/age/keys.txt /root/.config/sops/age/keys.txt
chmod 400 /root/.config/sops/age/keys.txt
chown 0:0 /root/.config/sops/age/keys.txt 
cp /run/secrets/ssh/keys/id_ed25519 /home/lovgren/.ssh/
cp /run/secrets/ssh/keys/id_ed25519.pub /home/lovgren/.ssh/
chmod 600 /home/lovgren/.ssh/id_ed25519*
chown 1000:100 /home/lovgren/.ssh/id_ed25519*
