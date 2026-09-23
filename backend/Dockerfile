FROM golang:1.18

# Debian bullseye's live security mirror has dropped old point-release .debs while
# the index still lists them, so deb.debian.org 404s during install. Pin apt to
# snapshot.debian.org (immutable: index and pool always match) to fix the build
# without changing any package versions or the toolchain.
RUN printf '%s\n' \
    'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/20240701T000000Z bullseye main' \
    'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian-security/20240701T000000Z bullseye-security main' \
    'deb [check-valid-until=no] http://snapshot.debian.org/archive/debian/20240701T000000Z bullseye-updates main' \
    > /etc/apt/sources.list \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get -o Acquire::Check-Valid-Until=false -o Acquire::Retries=5 update \
    && apt-get install -y --no-install-recommends \
    build-essential libboost-dev libboost-filesystem-dev libboost-iostreams-dev libboost-program-options-dev libboost-system-dev lua5.1 liblua5.1-0-dev libluajit-5.1-dev libprotobuf-dev libshp-dev libsqlite3-dev protobuf-compiler rapidjson-dev git-core osmium-tool unzip wget ca-certificates gzip


RUN mkdir -p /tilemaker/src \
    && cd /tilemaker/src \
    && git clone --branch v2.2.0 https://github.com/systemed/tilemaker.git

WORKDIR /tilemaker/src/tilemaker
RUN make
RUN make install


RUN mkdir -p /usr/share/man/man1
RUN apt-get install -y default-jre
RUN apt-get install -y osmosis

RUN apt-get install -y python3-pip python-dev build-essential
RUN pip install mbutil
RUN pip3 install osmium


COPY tilemaker-configs/config-openmaptiles.json /config.json
COPY tilemaker-configs/process-openmaptiles.lua /process.lua

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
