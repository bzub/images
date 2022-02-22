# syntax = docker.io/docker/dockerfile:1.3.1@sha256:42399d4635eddd7a9b8a24be879d2f9a930d0ed040a61324cfdf59ef1357b3b2

ARG ALPINE_IMAGE

FROM --platform=linux $ALPINE_IMAGE as builder
RUN apk add -U --no-cache git curl bash go build-base
ARG CGO_ENABLED=0
ENV CGO_ENABLED="${CGO_ENABLED}"
ENV GOCACHE /.cache/go-build
ENV GOMODCACHE /.cache/mod

FROM scratch as base-image
ARG USERNAME
ARG REPO_NAME
ARG TARGETOS
ARG TARGETARCH
LABEL org.opencontainers.image.source https://github.com/${USERNAME}/${REPO_NAME}
LABEL org.opencontainers.image.url https://github.com/${USERNAME}/${REPO_NAME}

FROM builder as kpt-build
ARG KPT_VERSION
ENV KPT_VERSION="${KPT_VERSION}"
ENV GOOS=darwin
ENV GOARCH=amd64
ENV ASSET_URL="https://github.com/GoogleContainerTools/kpt/releases/download/${KPT_VERSION}/kpt_${GOOS}_${GOARCH}"
RUN curl --fail --no-progress-meter -L -o /usr/local/bin/kpt-${GOOS}-${GOARCH} "${ASSET_URL}"
RUN chmod +x /usr/local/bin/kpt-${GOOS}-${GOARCH}
ENV GOOS=linux
ENV GOARCH=amd64
ENV ASSET_URL="https://github.com/GoogleContainerTools/kpt/releases/download/${KPT_VERSION}/kpt_${GOOS}_${GOARCH}"
RUN curl --fail --no-progress-meter -L -o /usr/local/bin/kpt-${GOOS}-${GOARCH} "${ASSET_URL}"
RUN chmod +x /usr/local/bin/kpt-${GOOS}-${GOARCH}

FROM base-image as kpt
COPY --from=kpt-build /usr/local/bin/kpt-${TARGETOS}-${TARGETARCH} /kpt
ENTRYPOINT ["/kpt"]

FROM builder as kind-build
ARG KIND_VERSION
ENV KIND_VERSION="${KIND_VERSION}"
ENV GOOS=darwin
ENV GOARCH=amd64
ENV ASSET_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-${GOOS}-${GOARCH}"
RUN curl --fail --no-progress-meter -L -o /usr/local/bin/kind-${GOOS}-${GOARCH} "${ASSET_URL}"
RUN chmod +x /usr/local/bin/kind-${GOOS}-${GOARCH}
ENV GOOS=linux
ENV GOARCH=amd64
ENV ASSET_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-${GOOS}-${GOARCH}"
RUN curl --fail --no-progress-meter -L -o /usr/local/bin/kind-${GOOS}-${GOARCH} "${ASSET_URL}"
RUN chmod +x /usr/local/bin/kind-${GOOS}-${GOARCH}

FROM base-image as kind
COPY --from=kind-build /usr/local/bin/kind-${TARGETOS}-${TARGETARCH} /kind
ENTRYPOINT ["/kind"]

FROM builder as clusterctl-build
ARG CLUSTERCTL_VERSION
ENV CLUSTERCTL_VERSION="${CLUSTERCTL_VERSION}"
ENV GOOS=darwin
ENV GOARCH=amd64
ENV ASSET_URL="https://github.com/kubernetes-sigs/cluster-api/releases/download/${CLUSTERCTL_VERSION}/clusterctl-${GOOS}-${GOARCH}"
RUN curl --fail --no-progress-meter -L -o /usr/local/bin/clusterctl-${GOOS}-${GOARCH} "${ASSET_URL}"
RUN chmod +x /usr/local/bin/clusterctl-${GOOS}-${GOARCH}
ENV GOOS=linux
ENV GOARCH=amd64
ENV ASSET_URL="https://github.com/kubernetes-sigs/cluster-api/releases/download/${CLUSTERCTL_VERSION}/clusterctl-${GOOS}-${GOARCH}"
RUN curl --fail --no-progress-meter -L -o /usr/local/bin/clusterctl-${GOOS}-${GOARCH} "${ASSET_URL}"
RUN chmod +x /usr/local/bin/clusterctl-${GOOS}-${GOARCH}

FROM base-image as clusterctl
COPY --from=clusterctl-build /usr/local/bin/clusterctl-${TARGETOS}-${TARGETARCH} /clusterctl
ENTRYPOINT ["/clusterctl"]
