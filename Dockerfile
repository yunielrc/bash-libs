ARG VERSION

FROM ubuntu:20.04 as base
ARG APT_PROXY
ARG USER
ENV DEBIAN_FRONTEND=noninteractive
RUN [ -n "$APT_PROXY" ] && echo "$APT_PROXY" | sed "s/'//g" > '/etc/apt/apt.conf.d/00proxy' || :
# add user with sudo
RUN apt-get update -y && \
    apt-get install -y sudo && \
    useradd --no-log-init --create-home --shell /bin/bash "$USER" && \
    usermod -aG sudo "$USER" && \
    echo "${USER} ALL=NOPASSWD:ALL" > /etc/sudoers.d/nopasswd
RUN apt-get install -y wget file xz-utils uuid-runtime tzdata 9base unzip \
            curl iputils-ping cron bash-completion vim tree  && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/America/Havana /etc/localtime && \
    echo America/Havana > /etc/timezone

FROM base as dev
ENV LIBS_DIR=/usr/local/lib
RUN apt-get update -y && \
    apt-get install -y git shellcheck build-essential && \
    apt-get autoremove -y && \
    apt-get autoclean -y && \
    rm -rf /var/lib/apt/lists/* && \
    cd /tmp/ && \
    git clone https://github.com/bats-core/bats-core.git && \
    cd bats-core && \
    ./install.sh /usr/local && \
    cd - && rm -r /tmp/bats-core && \
    git clone https://github.com/bats-core/bats-assert.git /usr/local/lib/bats-assert && \
    git clone https://github.com/bats-core/bats-support.git /usr/local/lib/bats-support
