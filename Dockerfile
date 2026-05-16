FROM ubuntu:24.04

ARG RGBDS_VERSION=v1.0.1

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      bison \
      ca-certificates \
      g++ \
      gcc \
      git \
      libpng-dev \
      make \
      pkg-config \
 && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch "${RGBDS_VERSION}" https://github.com/gbdev/rgbds.git /tmp/rgbds \
 && make -C /tmp/rgbds -j"$(nproc)" \
 && mkdir -p /opt/rgbds \
 && cp /tmp/rgbds/rgbasm /tmp/rgbds/rgbfix /tmp/rgbds/rgbgfx /tmp/rgbds/rgblink /opt/rgbds/ \
 && rm -rf /tmp/rgbds

WORKDIR /work

CMD ["make", "RGBDS=/opt/rgbds/", "compare"]
