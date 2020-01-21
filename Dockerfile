
FROM ubuntu:19.10

ENV SS_VERSION=3.3.4 \
KCP_VERSION=20200103 \
GO_VERSION=1.13.6

ENV SS_URL=https://github.com/shadowsocks/shadowsocks-libev/releases/download/v${SS_VERSION}/shadowsocks-libev-${SS_VERSION}.tar.gz \
KCP_URL=https://github.com/xtaci/kcptun/releases/download/v${KCP_VERSION}/kcptun-linux-amd64-${KCP_VERSION}.tar.gz \
GO_URL=https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz \
V2RAY_URL=https://github.com/shadowsocks/v2ray-plugin.git

ENV SERVER_ADDR=0.0.0.0 \
SERVER_PORT=2222 \
LOCAL_PORT=1080 \
PASSWORD=asdewq123 \
METHOD=chacha20 \
TIMEOUT=60 \
FASTOPEN=--fast-open \
UDP_RELAY=-u \
PLUGIN=v2ray-plugin \
PLUGIN_OPTS=server \
ARGS='' \
KCP_LISTEN=3333 \
KCP_PASS=asdewq123 \
KCP_ENCRYPT=salsa20 \
KCP_MODE=fast2 \
KCP_MTU=1350 \
KCP_SNDWND=2048 \
KCP_RCVWND=2048 \
KCP_DSCP=46 \
KCP_NOCOMP=false \
KCP_ARGS=''

ARG TempDir=SS_KCPTUN

RUN set -ex \
    && mkdir -p /tmp/${TempDir} \
    && cd /tmp/${TempDir} \
    && apt-get -y update \
    && apt-get -y upgrade \
    && apt-get -y install --no-install-recommends gettext build-essential autoconf automake \
    libtool openssl xmlto libssl-dev zlib1g-dev libpcre3-dev libev-dev libc-ares-dev \
    libsodium-dev libmbedtls-dev git rng-tools wget ca-certificates asciidoc \
    && wget --no-check-certificate -O shadowsocks-libev-${SS_VERSION}.tar.gz ${SS_URL} \
    && wget --no-check-certificate -O kcptun-linux-amd64-${KCP_VERSION}.tar.gz ${KCP_URL} \
    && wget --no-check-certificate -O go${GO_VERSION}.linux-amd64.tar.gz ${GO_URL} \
    && tar zxf shadowsocks-libev-${SS_VERSION}.tar.gz \
    && tar zxf kcptun-linux-amd64-${KCP_VERSION}.tar.gz \
    && tar zxf go${GO_VERSION}.linux-amd64.tar.gz \
    && git clone ${V2RAY_URL} \
    && cd shadowsocks-libev-${SS_VERSION} \
    && ./configure --disable-documentation \
    && make \
    && make install \
    && cd /tmp/${TempDir} \
    && mv server_linux_amd64 /usr/local/bin/kcpserver \
    && mv client_linux_amd64 /usr/local/bin/kcpclient \
    && mv go /usr/local \
    && cd v2ray-plugin \
    && export GOROOT=/usr/local/go \
    && export PATH=$GOPATH/bin:$GOROOT/bin:$PATH \
    && go build \
    && mv v2ray-plugin /usr/local/bin

WORKDIR /usr/local/bin
RUN rm -rf /tmp/${TempDir}

CMD ss-server -s ${SERVER_ADDR} \
              -p ${SERVER_PORT} \
              -l ${LOCAL_PORT} \
              -k ${PASSWORD} \
              -m ${METHOD} \
              -t ${TIMEOUT} \
              ${FASTOPEN} \
              ${UDP_RELAY} \
              --plugin ${PLUGIN} \
              --plugin-opts ${PLUGIN_OPTS} \
              ${ARGS} \
              -f /var/run/shadowsocks-libev.pid \
              && kcpserver -l ":${KCP_LISTEN}" \
              -t "127.0.0.1:${SERVER_PORT}" \
              --key ${KCP_PASS} \
              --crypt ${KCP_ENCRYPT} \
              --mode ${KCP_MODE} \
              --mtu ${KCP_MTU} \
              --sndwnd ${KCP_SNDWND} \
              --rcvwnd ${KCP_RCVWND} \
              --dscp ${KCP_DSCP} \
              ${KCP_NOCOMP} \
              ${KCP_ARGS}





