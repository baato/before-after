FROM debian:buster-slim

# install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential liblua5.1-0 liblua5.1-0-dev libprotobuf-dev libsqlite3-dev protobuf-compiler shapelib libshp-dev libboost-program-options-dev libboost-filesystem-dev libboost-system-dev libboost-iostreams-dev git-core osmium-tool unzip wget ca-certificates gzip


RUN mkdir -p /tilemaker/src \
    && cd /tilemaker/src \
    && git clone https://github.com/systemed/tilemaker.git 

WORKDIR /tilemaker/src/tilemaker
RUN make
RUN make install

RUN apt-get install -y golang

COPY tilemaker-configs/config.json /
COPY tilemaker-configs/process.lua /

COPY index.html /index.html

COPY server.go /
RUN chmod +x /server.go

COPY start.sh /start.sh
COPY provision.sh /provision.sh

RUN chmod +x /start.sh
RUN chmod +x /provision.sh

ENTRYPOINT ["/start.sh"]