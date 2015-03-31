#!/bin/sh

cd /master

if [ -z "$(ls -A /master)" ] ; then
    echo "Initializing buildbot master"
    echo "WARNING: default buildbot configuration, you will need to reconfigure"
    chown buildbot.buildbot /master
    gosu buildbot buildbot create-master
    mv master.cfg.sample master.cfg
    cat >> buildbot.tac <<EOF

import sys
from twisted.python import log
log.FileLogObserver(sys.stdout).start()
EOF
else
    echo "Upgrading buildbot master"
    gosu buildbot buildbot upgrade-master -r
fi

echo "Starting buildbot master daemon"
exec gosu buildbot buildbot start --nodaemon
