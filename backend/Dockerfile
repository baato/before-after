FROM golang:1.18

# bullseye is archived; deb.debian.org no longer serves its packages
RUN printf '%s\n' \
      'deb http://archive.debian.org/debian bullseye main' \
      > /etc/apt/sources.list && \
    rm -f /etc/apt/sources.list.d/*.list /etc/apt/sources.list.d/*.sources && \
    echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/10no-check-valid-until

# one apt layer — jre needs the man dir to exist first
RUN mkdir -p /usr/share/man/man1 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential libboost-dev libboost-filesystem-dev libboost-iostreams-dev \
      libboost-program-options-dev libboost-system-dev \
      lua5.1 liblua5.1-0-dev libluajit-5.1-dev \
      libprotobuf-dev libshp-dev libsqlite3-dev protobuf-compiler rapidjson-dev \
      git-core osmium-tool unzip wget aria2 ca-certificates gzip \
      default-jre osmosis python3-pip python3-dev && \
    rm -rf /var/lib/apt/lists/*

RUN pip3 install mbutil

RUN mkdir -p /tilemaker/src \
    && cd /tilemaker/src \
    && git clone --depth 1 --branch v2.2.0 https://github.com/systemed/tilemaker.git

WORKDIR /tilemaker/src/tilemaker
RUN make -j$(nproc) && make install

COPY tilemaker-configs/config-openmaptiles.json /config.json
COPY tilemaker-configs/process-openmaptiles.lua /process.lua
COPY index.html /index.html

RUN mkdir -p /server/backend/server
COPY server/ /server/backend/server

COPY start.sh /start.sh
COPY provisioning-scripts/ /provisioning-scripts
COPY map-styles/ /map-styles

RUN chmod +x /start.sh /provisioning-scripts/*.sh

WORKDIR /server/backend/server
RUN go build

WORKDIR /server
ENTRYPOINT ["/start.sh"]