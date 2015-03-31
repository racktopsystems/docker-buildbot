# Buildbot CI Docker Images

## Buildbot Master

This container is pretty simple. It exports one volume, `/master`, which
will be initialized with a default Buildbot configuration if empty. You will
need to edit `master.cfg` afterwards. Otherwise, the existing configuration
is automatically upgraded before Buildbot is started.

Two ports are exposed:

* 8010: Buildbot web interface
* 9989: Buildbot slave-control RPC interface

Due to the unencrypted nature of Buildbot control connections, you may want
to firewall 9989 in some fashion.

## Buildbot Slave

This image is based on jpetazzo/dind ("Docker in Docker"), to permit running
builds within temporary Docker containers. As such, it is important to run the
container with the `--privileged` flag:

```sh
docker run --privileged -d \
        -e MASTER=buildbot.example.com \
        -e SLAVE_NAME=myslavename \
        -e SLAVE_PASSWD=mysecret \
        --name=buildbot-slave purism/buildbot-slave
```

There is no need for volumes in this image, as all state is contained in
environment variables set at run time.

### Required Environment Variables

The container will fail to start if these are unset.

* `MASTER`: "host:port" combination of the master to connect to
* `SLAVE_NAME`: name of the slave, as configured in the master
* `SLAVE_PASSWORD`: password for the slave, as configured in the master

### Optional Variables

It is recommended but not required to set `SLAVE_ARGS` and `SLAVE_ADMIN`.

* `SLAVE_ARGS`: Extra commandline options to pass to `buildslave`
* `SLAVE_ADMIN`: "Name <email>" of the admin of the slave
* `SLAVE_DESCRIPTION`: Short text description of the slave
* `DOCKER_DAEMON_ARGS`: extra arguments to pass to the inner Docker daemon
