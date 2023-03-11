FROM docker.io/archlinux:base-devel-20230305.0.131236

RUN pacman -Syu --noconfirm \
    bc \
    fontconfig \
    gcc-go \
    git \
    gperf \
    jdk17-openjdk \
    msmtp \
    openssh \
    repo \
    rsync \
    ttf-dejavu \
    unzip \
    wget \
    zip

COPY container/msmtprc /etc/msmtprc

RUN useradd -m -s /bin/bash -u 1000 builder \
    && useradd -m -s /bin/bash -u 1001 installer \
    && passwd -d installer \
    && printf 'installer ALL=(ALL) ALL\n' | tee -a /etc/sudoers

USER installer

WORKDIR /tmp

RUN wget https://aur.archlinux.org/cgit/aur.git/snapshot/ncurses5-compat-libs.tar.gz \
    && tar xvf ncurses5-compat-libs.tar.gz \
    && rm ncurses5-compat-libs.tar.gz \
    && cd ncurses5-compat-libs \
    && gpg --recv-key 19882D92DDA4C400C22C0D56CC2AF4472167BE03 \
    && makepkg -si --noconfirm


USER builder

RUN git config --global user.email "builder@example.com" \
    && git config --global user.name "builder"

WORKDIR /script

COPY . .
