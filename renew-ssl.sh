#!/bin/bash
cd /home/nellcorp/modoboa-setup
docker-compose stop web
/opt/certbot-auto renew --quiet --no-self-upgrade
docker-compose start web
service postfix reload
service dovecot reload
