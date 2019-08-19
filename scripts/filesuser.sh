#!/bin/bash

LOGIN=${1::1}.$2
export OC_PASS="sapiens"

sudo -Eu www-data php /var/www/owncloud/occ user:add \
 --password-from-env \
 --display-name="$LOGIN" \
 --group="allusers" \
 --group="all" \
 --email=$LOGIN@sapiens.solutions $LOGIN
