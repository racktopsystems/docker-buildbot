#!/bin/sh

cd /srv/buildbot/master

cp -r /srv/setup/config/* ./

# Clear out twistd.pid to prevent false detection of running master
if [ -e twistd.pid ] ; then
    read twistd_pid < twistd.pid
    if grep -q buildbot /proc/$twistd_pid/cmdline 2>/dev/null ; then
	:
    else
	rm twistd.pid
    fi
fi

if [ ! -e buildbot.tac ] ; then
    echo "Initializing buildbot master"
    buildbot create-master
    rm master.cfg.sample
    cat >> buildbot.tac <<EOF

import sys
from twisted.python import log
log.FileLogObserver(sys.stdout).start()
EOF
else
    echo "Upgrading buildbot master"
    buildbot upgrade-master -r
fi

echo "Starting buildbot master daemon"
buildbot start --nodaemon
