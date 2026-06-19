FROM docker.io/eclipse-temurin:26-jdk@sha256:0e52e08108f27ab71328304e0c704ad53e2b6be812718ad38a2821c11ecb231d

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && dpkg --add-architecture i386 \
    && apt update \
    && apt install -q -y bison \
        bc \
        curl \
        flex \
        g++-multilib \
        git \
        gperf \
        liblz4-tool \
        libssl-dev \
        libxml2-utils \
        make \
        msmtp \
        python-is-python3 \
        rsync \
        zip \
        zlib1g-dev zlib1g-dev:i386 \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*

COPY container/msmtprc /etc/msmtprc

USER ubuntu

RUN git config --global user.email "ubuntu@example.com" \
    && git config --global user.name "ubuntu"

RUN mkdir ~/bin \
    && curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo \
    && chmod a+x ~/bin/repo \
    && echo 'export PATH=~/bin:$PATH' >> ~/.bashrc

ENV PATH=~/bin:$PATH

WORKDIR /script

COPY . .
