FROM golang:1.18

# install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    build-essential libboost-dev libboost-filesystem-dev libboost-iostreams-dev libboost-program-options-dev libboost-system-dev liblua5.1-0-dev libprotobuf-dev libshp-dev libsqlite3-dev protobuf-compiler rapidjson-dev git-core osmium-tool unzip wget ca-certificates gzip


RUN mkdir -p /tilemaker/src \
    && cd /tilemaker/src \
    && git clone https://github.com/systemed/tilemaker.git 

WORKDIR /tilemaker/src/tilemaker
RUN make
RUN make install


RUN mkdir -p /usr/share/man/man1
RUN apt-get install -y default-jre
RUN apt-get install -y osmosis

RUN apt-get install -y python3-pip python-dev build-essential
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

WORKDIR /server/backend/server

RUN go build

WORKDIR /server

ENTRYPOINT ["/start.sh"]