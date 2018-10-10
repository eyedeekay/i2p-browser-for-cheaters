FROM debian:sid
ARG DEBIAN_FRONTEND=noninteractive
ARG HOME=/home/anon
ARG BROWSER_VERSION="7.5.6"
ARG HOST="172.80.80.4"
ARG PORT="44443"
ARG TOR_FORCE_NET_CONFIG=0
ARG TOR_SKIP_LAUNCH=1
ARG TOR_SKIP_CONTROLPORTTEST=1
ARG TOR_HIDE_BROWSER_LOGO=1
ARG TOR_CONFIGURE_ONLY=0

ENV DEBIAN_FRONTEND=noninteractive
ENV HOME=/home/anon
ENV TOR_FORCE_NET_CONFIG=0
ENV TOR_SKIP_LAUNCH=1
ENV TOR_SKIP_CONTROLPORTTEST=1
ENV TOR_HIDE_BROWSER_LOGO=1
ENV TOR_CONFIGURE_ONLY=0
ENV TOR_SOCKS_HOST=$HOST
ENV TOR_SOCKS_PORT=$PORT

RUN sed -i 's/sid main/sid main contrib/g' /etc/apt/sources.list

RUN apt-get update && \
    apt-get -y dist-upgrade

RUN apt-get update && apt-get install -y \
    firefox-esr \
    gnupg \
    zenity \
    ca-certificates \
    xz-utils \
    curl \
    sudo \
    xdotool \
    dirmngr \
    file \
    libgtkextra-dev

RUN localedef -v -c -i en_US -f UTF-8 en_US.UTF-8 || :

RUN groupadd -g 1000 anon
RUN adduser --home /home/anon --gecos 'anon,,,,' --gid 1000 --uid 1000 --disabled-password anon
RUN adduser anon sudo

USER anon

RUN mkdir /home/anon/.local

WORKDIR /home/anon

RUN curl -sSL -o /home/anon/tor.tar.xz \
      https://www.torproject.org/dist/torbrowser/${BROWSER_VERSION}/tor-browser-linux64-${BROWSER_VERSION}_en-US.tar.xz

RUN curl -sSL -o /home/anon/tor.tar.xz.asc \
      https://www.torproject.org/dist/torbrowser/${BROWSER_VERSION}/tor-browser-linux64-${BROWSER_VERSION}_en-US.tar.xz.asc

RUN gpg --keyserver ha.pool.sks-keyservers.net \
      --recv-keys "EF6E 286D DA85 EA2A 4BA7  DE68 4E2C 6E87 9329 8290"

RUN gpg --verify /home/anon/tor.tar.xz.asc

RUN tar xf /home/anon/tor.tar.xz

RUN rm -f /home/anon/tor.tar.xz*

COPY setup-i2p-browser.sh .
COPY etc/ etc/

RUN ./setup-i2p-browser.sh "/home/anon/tor-browser_en-US/" "$PORT"

RUN mkdir -p /home/anon/working

RUN cp -r /home/anon/tor-browser_en-US/ /home/anon/working/i2p-browser_en-US/

RUN cd /home/anon/working/ && \
    tar czf /home/anon/i2p-browser.tar.gz .

RUN mv /home/anon/working/i2p-browser_en-US/ /home/anon/i2p-browser_en-US/

USER root

COPY i2p-diffs.html /usr/share/i2p-torbrowser-sockets-workaround/homepage/i2p-diffs.html

CMD chown -R anon:anon /home/anon/.local/ && \
    chmod -R o+rw /home/anon/.local/ && \
    sudo -u anon /home/anon/i2p-browser_en-US/Browser/start-i2p-browser --verbose /usr/share/i2p-torbrowser-sockets-workaround/homepage/i2p-diffs.html
