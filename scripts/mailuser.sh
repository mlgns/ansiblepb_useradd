#!/bin/bash
# Add user from zmprov, needed for ansible playbook


LOGIN=${1::1}.$2

/opt/zimbra/bin/zmprov ca $LOGIN@sapiens.solutions sapiens displayName "$1 $2"

/opt/zimbra/bin/zmprov ma $LOGIN@sapiens.solutions userPassword 'sapiens'
