# Development image
FROM alpine:latest AS builder-stage
#FROM ubuntu:latest AS builder-stage
LABEL builder=true

RUN apk update && \
    apk upgrade && \
    apk --update add \
          git \
          sqlite-dev \
          openssl-dev \
          alpine-sdk \
          linux-headers \
          gcc \
          g++ \
          build-base \
          cmake \
          bash \
          libstdc++ \
    && rm -rf /var/cache/apk/*

WORKDIR /src

RUN git clone https://github.com/jvirkki/dupd.git

RUN cd dupd && make

RUN ls -la

# Deploy image ---
FROM alpine AS app-stage
# Removes label docker images --filter "label=builder=true" --format '{{.CreatedAt}}\t{{.ID}}' | sort -nr | head -n 1 | cut -f2
LABEL builder=false

WORKDIR /app

RUN apk update && \
    apk upgrade && \
    apk --update add \
          bash \
          sqlite \
          && \
    rm -rf /var/cache/apk/*

COPY --from=builder-stage /src/dupd/dupd /usr/bin/dupd
COPY --from=builder-stage /usr/lib/*.so* /usr/lib/
