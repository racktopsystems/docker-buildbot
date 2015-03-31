#!/bin/sh

set -e

: ${MASTER:?"Required environment variable unset"}
: ${SLAVE_NAME:?"Required environment variable unset"}
: ${SLAVE_PASSWORD:?"Required environment variable unset"}

if [ -z "$(ls -A /slave)" ] ; then
    echo "Initializing buildslave"
    buildslave create-slave /slave "$MASTER" "$SLAVE_NAME" "$SLAVE_PASSWORD"
    cat >> /slave/buildbot.tac <<EOF
import sys
from twisted.python import log
log.FileLogObserver(sys.stdout).start()
EOF

    [ -n "$SLAVE_ADMIN" ] && echo "$SLAVE_ADMIN" > /slave/info/admin
    [ -n "$SLAVE_DESCRIPTION" ] && echo "$SLAVE_DESCRIPTION" > /slave/info/host
    chown buildbot.buildbot -R /slave
fi

cd /slave

# prevent these from leaking into or cluttering the build report
unset GOSU_VERSION \
    MASTER \
    SLAVE_NAME \
    SLAVE_PASSWORD \
    SLAVE_ADMIN \
    SLAVE_DESCRIPTION

exec gosu buildbot buildslave start --nodaemon $SLAVE_ARGS
