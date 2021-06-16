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

RUN go get github.com/gorilla/websocket

RUN mkdir -p /usr/share/man/man1
RUN apt-get install -y default-jre
RUN apt-get install -y osmosis

RUN apt-get install -y python-pip
RUN pip install mbutil


COPY tilemaker-configs/config.json /
COPY tilemaker-configs/process.lua /

COPY index.html /index.html

RUN mkdir -p /server/backend/server
COPY server/ /server/backend/server
RUN chmod +x /server/backend/server/main.go

COPY start.sh /start.sh

RUN mkdir -p /provisioning-scripts
COPY provisioning-scripts/ /provisioning-scripts

RUN mkdir -p /map-styles
COPY map-styles/ /map-styles

RUN chmod +x /start.sh
RUN chmod +x /provisioning-scripts/*.sh

WORKDIR /server

ENTRYPOINT ["/start.sh"]