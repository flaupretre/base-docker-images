# Docker base images

This repository allows to build and publish a set of company-wide base docker
images.

Using common base images provides many benefits : first, it provides developers
and image builders with a set of pre-populated images and avoids them to
start from scratch and reinvent the wheel everytime.

It also provides a
standard runtime environment which is of primary importance for support teams. Troubleshooting
a container is much easier when you're familiar with the environment and tools
it features. Being stuck with a disfunctional container which does not contain
the tools you expect is a major cause of frustration and loss of time. The situation
is still worse when the container is in read-only mode, which is a recommended
security feature we should apply as often as possible.

A final benefit is the question of used memory. Docker images are composed of layers
and each layers is loaded only once per run environment, whatever the count of final images it
appears in. This means that, on a Kubernetes cluster for instance, all the
utilities and tools included in the runtime base will use memory only once
per node.

The images we produce here are split in two branches :

- 'build' images provide build
environments and are supposed to be used in docker multi-stage builds. In such a
build, the artefacts are built using a 'build' image and, then, copied from the
'build' image into a 'runtime' image. Only the 'runtime'-based image is kept
and saved. This avoids to pollute the final runtime environment with the
build environment and intermediate artefacts you don't need anymore.

- 'runtime' images can be used in single or multi-stage builds and they contain
a set of utilities and tools we want to be present in the resulting image.

## Images

### base-root

This is the root image. Every image we produce in this project derive from this
one. It is a minimal debian environment produced by the 'debootstrap' command.

It also includes a wrapper layer we propose to unify interactions with the image.
Among others, this wrapper proposes a standard location for the container's run script,
a 'maintenance' mode which will create the image without running any command (essential
when dealing with persistent volumes), and a basic test framework (currently supporting
shell scripts and [goss](https://github.com/aelsabbahy/goss), planning [bats](https://github.com/bats-core/bats-core) addition).
Among others, this test framework allows to use goss tests for Kubernetes
liveness/readiness probes, and not only at CI time.

This image is not supposed to be used as base for another project as we provide
more-oriented 'build' and 'runtime' images.

### base-build

This a general-purpose 'builder' image to be used in multi-stage builds. It is used
as a base for the more specialized 'base-build-xxx' images we provide.

### base-build-sbt

This is a builder image providing a Scala language build environment.

### base-runtime

This is the base runtime we want to be included in as many final images as
possible.

#### Tools/utilities

It includes a set of common-use tools and utilities : goss, lsof, netcat, iproute,
iputils/ping, curl, jq, net-tools (netstat,...), pip3, pv, ssh, gpg, htop,
goss, vim, rsync, tcpdump, strace, git and others. This already provides a
comfortable environment for troubleshooting and may be enriched in the future depending on
user's demand.

#### AWS & Kubernetes clients

For those needing to interact with AWS and/or Kubernetes from your container,
it also provides the AWS CLI, kubectl, and a set of shell functions to make
interaction between a shell script and AWS/Kubernetes easier.

### base-runtime-jre

This is the base runtime supplemented with a JRE environment. Perfect to run
artefacts produced with the 'base-build-sbt' image.

## Building & pushing images

Images are built, tested and published automatically by the CI system. They are
published to docker hub when a tag
with the same value as the VERSION variable (in vars.sh) is pushed (must be on
master branch). The pushed images take this value as tag.

You may also build some images by yourself. The syntax for this is :

    ./dbuild.sh [<stage1> [<stage2>...]] [<docker build options>]

where 'stage' is the image name without the 'base-' prefix. If no stage is
specified, all the base images are built. For instance, the './dbuild.sh --no-cache'
command (re)builds every image, adding the '--no-cache' option to every 'docker build'
command.

If you want to push images, use this syntax :

    ./dpush.sh [<stage1> [<stage2>...]] [<docker push options>]

If no stage is specified, all the base images are pushed.

## TODO

### Monitoring

More needs to be done to provide application integrators with better mechanisms to
control/interact with the monitoring platform.

### Document build/wrapper system

Need more documentation about leveraging the wrapper system in your own final image
(need tutorials and examples).
