FROM debian:buster-slim

ENV DOCKER_IP=${DOCKER_IP:-'10.0.0.1'}

LABEL maintainer="Bruno Souza <brnosouza@gmail.com>"
LABEL description="Provides an image with Janus Gateway"

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt install -y \
          build-essential \
          liblua5.3-dev \
          libcurl4-openssl-dev \
          libmicrohttpd-dev \
          libjansson-dev \
          libnice-dev \
          libssl-dev \
          libsofia-sip-ua-dev \
          libglib2.0-dev \
          libopus-dev \
          libconfig-dev \
          libogg-dev \
          libini-config-dev \
          libcollection-dev \
          pkg-config \
          gengetopt \
          libtool \
          autotools-dev \
          automake \
          sudo \
          make \
          git \
          cmake

RUN cd ~ \
    && git clone https://github.com/cisco/libsrtp.git \
    && cd libsrtp \
    && git checkout v2.2.0 \
    && ./configure --prefix=/usr --enable-openssl \
    && make shared_library \
    && sudo make install

RUN cd ~ \
    && git clone https://github.com/sctplab/usrsctp \
    && cd usrsctp \
    && ./bootstrap \
    && ./configure --prefix=/usr \
    && make \
    && sudo make install

RUN cd ~ \
    && git clone https://github.com/warmcat/libwebsockets.git \
    && cd libwebsockets \
    && git checkout v3.2-stable \
    && mkdir build \
    && cd build \
    && cmake -DCMAKE_INSTALL_PREFIX:PATH=/usr .. \
    && make \
    && sudo make install

RUN cd ~ \
    && git clone https://github.com/meetecho/janus-gateway.git \
    && cd janus-gateway \
    && sh autogen.sh \
    && ./configure --prefix=/opt/janus --disable-rabbitmq --disable-mqtt --disable-docs \
    && make CFLAGS='-std=c99' \
    && make install \
    && make configs

COPY ./certs /opt/janus/share/janus
COPY conf/*.jcfg /opt/janus/etc/janus/

EXPOSE 7088 7188 7889 7989 8088 8089 8188 8989
EXPOSE 10000-10200/udp

CMD /opt/janus/bin/janus --stun-server=stun.l.google.com:19302 --nat-1-1=${DOCKER_IP}