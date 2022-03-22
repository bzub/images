# syntax = docker.io/docker/dockerfile-upstream:1.4.0

ARG ALPINE_IMAGE
ARG PYTHON_IMAGE
ARG KIND_NODE_UPSTREAM_IMAGE
ARG TRIVY_UPSTREAM_IMAGE

FROM --platform=linux ${ALPINE_IMAGE} as alpine
FROM ${KIND_NODE_UPSTREAM_IMAGE} as kind-node-upstream
FROM ${PYTHON_IMAGE} as python
FROM $TRIVY_UPSTREAM_IMAGE as trivy-upstream

FROM --platform=linux alpine as builder
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
ARG TARGETOS
ARG TARGETARCH
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}
ARG KPT_VERSION
ENV KPT_VERSION="${KPT_VERSION}"
ENV ASSET_URL="https://github.com/GoogleContainerTools/kpt/releases/download/${KPT_VERSION}/kpt_${GOOS}_${GOARCH}"
RUN curl --fail --no-progress-meter -L -o /usr/local/bin/kpt-${GOOS}-${GOARCH} "${ASSET_URL}"
RUN chmod +x /usr/local/bin/kpt-${GOOS}-${GOARCH}

FROM base-image as kpt
COPY --from=kpt-build /usr/local/bin/kpt-${TARGETOS}-${TARGETARCH} /kpt
ENTRYPOINT ["/kpt"]

FROM builder as kind-build
ARG TARGETOS
ARG TARGETARCH
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}
ARG KIND_VERSION
ENV KIND_VERSION="${KIND_VERSION}"
ENV ASSET_URL="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-${GOOS}-${GOARCH}"
RUN curl --fail --no-progress-meter -L -o /usr/local/bin/kind-${GOOS}-${GOARCH} "${ASSET_URL}"
RUN chmod +x /usr/local/bin/kind-${GOOS}-${GOARCH}

FROM base-image as kind
COPY --from=kind-build /usr/local/bin/kind-${TARGETOS}-${TARGETARCH} /kind
ENTRYPOINT ["/kind"]

FROM builder as clusterctl-build
ARG TARGETOS
ARG TARGETARCH
ENV GOOS=${TARGETOS}
ENV GOARCH=${TARGETARCH}
ARG CLUSTERCTL_VERSION
ENV CLUSTERCTL_VERSION="${CLUSTERCTL_VERSION}"
ENV ASSET_URL="https://github.com/kubernetes-sigs/cluster-api/releases/download/${CLUSTERCTL_VERSION}/clusterctl-${GOOS}-${GOARCH}"
RUN curl --fail --no-progress-meter -L -o /usr/local/bin/clusterctl-${GOOS}-${GOARCH} "${ASSET_URL}"
RUN chmod +x /usr/local/bin/clusterctl-${GOOS}-${GOARCH}

FROM base-image as clusterctl
COPY --from=clusterctl-build /usr/local/bin/clusterctl-${TARGETOS}-${TARGETARCH} /clusterctl
ENTRYPOINT ["/clusterctl"]

# kind-node images with backported fixes for use with Colima.
FROM kind-node-upstream as kind-node
COPY --from=docker.io/kindest/node:v1.23.3 /etc/systemd/system/kubelet.service.d/10-kubeadm.conf /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
ARG USERNAME
ARG REPO_NAME
LABEL org.opencontainers.image.source https://github.com/${USERNAME}/${REPO_NAME}
LABEL org.opencontainers.image.url https://github.com/${USERNAME}/${REPO_NAME}

# redfishtool
FROM python as redfishtool
ARG USERNAME
ARG REPO_NAME
ARG REDFISHTOOL_VERSION
RUN pip install "redfishtool==${REDFISHTOOL_VERSION}"
ENTRYPOINT ["redfishtool"]
LABEL org.opencontainers.image.source https://github.com/${USERNAME}/${REPO_NAME}
LABEL org.opencontainers.image.url https://github.com/${USERNAME}/${REPO_NAME}

FROM trivy-upstream as trivy
ARG USERNAME
ARG REPO_NAME
RUN apk add -U --no-cache jq
LABEL org.opencontainers.image.source https://github.com/${USERNAME}/${REPO_NAME}
LABEL org.opencontainers.image.url https://github.com/${USERNAME}/${REPO_NAME}
