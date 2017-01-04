FROM ubuntu:16.04
MAINTAINER pete@port.direct

ENV DEBIAN_FRONTEND=noninteractive

RUN set -e && \
    set -x && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        git \
        python-virtualenv \
        python-dev \
        python-pip \
        gcc \
        libssl-dev \
        libffi-dev \
        crudini \
        curl \
        docker.io && \
    apt-get clean

WORKDIR /root

ENV KOLLA_REPO=http://git.openstack.org/openstack/kolla.git

RUN set -e && \
    set -x && \
    git clone ${KOLLA_REPO} ./kolla-master && \
    cd ./kolla-master && \
    mkdir -p .venv && \
    virtualenv .venv/kolla-builds

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

ENTRYPOINT ["bash", "/usr/local/bin/entrypoint.sh"]
