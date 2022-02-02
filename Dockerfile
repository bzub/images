# syntax = docker.io/docker/dockerfile:1.3.1@sha256:42399d4635eddd7a9b8a24be879d2f9a930d0ed040a61324cfdf59ef1357b3b2

ARG ALPINE_IMAGE
ARG DOCKER_IMAGE
ARG BUILDX_IMAGE

FROM $DOCKER_IMAGE as docker-bin
FROM $BUILDX_IMAGE as buildx-bin

FROM $ALPINE_IMAGE as base
RUN apk add -U git curl build-base bash go
COPY --from=docker-bin /usr/local/bin/docker /usr/local/bin/ctr /usr/local/bin/
COPY --from=buildx-bin /buildx /usr/libexec/docker/cli-plugins/docker-buildx
