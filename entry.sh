#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

# Copy default spool from cache
if [ ! "$(ls -A /var/spool/postfix)" ]; then
   cp -a /var/spool/postfix.cache/* /var/spool/postfix/
fi

if [ -z "$MAILNAME" ]; then
    echo "Error: MAILNAME not specified"
    exit 128
fi

if [ -z "$MYNETWORKS" ]; then
    MYNETWORKS='127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16'
    echo "Warning: MYNETWORKS not specified, allowing all private IPs"
fi

# Configure Postfix
echo "Setting mailname to $MAILNAME"
echo $MAILNAME > /etc/mailname 
postconf -e myhostname="$MAILNAME"
postconf -e mydestination="$MAILNAME"
postconf -e mynetworks="$MYNETWORKS"

# Create logging FIFO
mkfifo /dev/maillog

echo "Exec'ing $@"
exec "$@"
