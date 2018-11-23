FROM ubuntu:trusty as ipxe

RUN apt-get update && apt-get install -y git make gcc liblzma-dev syslinux \
                                         genisoimage gcc-aarch64-linux-gnu \
                                         binutils-dev binutils-aarch64-linux-gnu

COPY . /usr/pxeboot

WORKDIR /usr/pxeboot

RUN ./script/prep-release.sh
