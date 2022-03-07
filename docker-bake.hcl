variable "REGISTRY" {default = "ghcr.io"}
variable "USERNAME" {default = "bzub"}
variable "REPO_NAME" {default = "images"}

variable "ALPINE_VERSION" {default = "3.15.0"}
variable "PYTHON_VERSION" {default = "3.10.2"}
variable "KPT_VERSION" {default = "v1.0.0-beta.13"}
variable "KIND_VERSION" {default = "v0.11.1"}
variable "CAPI_V0_3_VERSION" {default = "v0.3.25"}
variable "CAPI_V0_4_VERSION" {default = "v0.4.7"}
variable "CAPI_V1_0_VERSION" {default = "v1.0.4"}
variable "CAPI_V1_1_VERSION" {default = "v1.1.2"}
variable "K8S_V1_19_VERSION" {default = "v1.19.11"}
variable "K8S_V1_20_VERSION" {default = "v1.20.7"}
variable "K8S_V1_21_VERSION" {default = "v1.21.2"}
variable "K8S_V1_22_VERSION" {default = "v1.22.5"}
variable "KIND_NODE_VERSION" {default = K8S_V1_19_VERSION}
variable "REDFISHTOOL_VERSION" {default = "1.1.5"}
variable "TRIVY_VERSION" {default = "0.24.2"}

variable "ALPINE_IMAGE" {default = "docker.io/library/alpine:${ALPINE_VERSION}"}
variable "PYTHON_IMAGE" {default = "docker.io/library/python:${PYTHON_VERSION}"}
variable "KIND_NODE_UPSTREAM_IMAGE" {default = "docker.io/kindest/node"}
variable "TRIVY_UPSTREAM_IMAGE" {default = "ghcr.io/aquasecurity/trivy"}

function "majorminorversion" {
  params = [semver]
  result = format("%s.%s",
    lookup(
      regex("^(?P<major>v?\\d*)\\.(?P<minor>\\d*)\\.(?P<patch>\\d*).*$", semver),
      "major",
      "error-major_version_not_found"
    ),
    lookup(
      regex("^(?P<major>v?\\d*)\\.(?P<minor>\\d*)\\.(?P<patch>\\d*).*$", semver),
      "minor",
      "error-minor_version_not_found"
    )
  )
}

group "default" {
  targets = [
    "kpt",
    "kind",
    "clusterctl",
    "kind-node",
  ]
}

target "_common" {
  args = {
    ALPINE_IMAGE = ALPINE_IMAGE
    PYTHON_IMAGE = PYTHON_IMAGE
    KIND_NODE_UPSTREAM_IMAGE = KIND_NODE_UPSTREAM_IMAGE
    TRIVY_UPSTREAM_IMAGE = TRIVY_UPSTREAM_IMAGE
    REGISTRY = REGISTRY
    USERNAME = USERNAME
    REPO_NAME = REPO_NAME
  }
  platforms = [
    "darwin/amd64",
    "linux/amd64",
  ]
}

target "kpt" {
  inherits = ["_common"]
  target = "kpt"
  args = {
    KPT_VERSION = KPT_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kpt:${KPT_VERSION}"
  ]
}

target "kind" {
  inherits = ["_common"]
  target = "kind"
  args = {
    KIND_VERSION = KIND_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kind:${KIND_VERSION}"
  ]
}

group "clusterctl" {
  targets = [
    "clusterctl-v0_3",
    "clusterctl-v0_4",
    "clusterctl-v1_0",
    "clusterctl-v1_1",
  ]
}

target "clusterctl-v0_3" {
  inherits = ["_common"]
  target = "clusterctl"
  args = {
    CLUSTERCTL_VERSION = CAPI_V0_3_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${CAPI_V0_3_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${majorminorversion(CAPI_V0_3_VERSION)}",
  ]
}

target "clusterctl-v0_4" {
  inherits = ["_common"]
  target = "clusterctl"
  args = {
    CLUSTERCTL_VERSION = CAPI_V0_4_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${CAPI_V0_4_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${majorminorversion(CAPI_V0_4_VERSION)}",
  ]
}

target "clusterctl-v1_0" {
  inherits = ["_common"]
  target = "clusterctl"
  args = {
    CLUSTERCTL_VERSION = CAPI_V1_0_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${CAPI_V1_0_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${majorminorversion(CAPI_V1_0_VERSION)}",
  ]
}

target "clusterctl-v1_1" {
  inherits = ["_common"]
  target = "clusterctl"
  args = {
    CLUSTERCTL_VERSION = CAPI_V1_1_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${CAPI_V1_1_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${majorminorversion(CAPI_V1_1_VERSION)}",
  ]
}

group "kind-node" {
  targets = [
    "kind-node-v1_19",
    "kind-node-v1_20",
    "kind-node-v1_21",
    "kind-node-v1_22",
  ]
}

target "_kind-node-common" {
  target = "kind-node"
  platforms = [
    "linux/amd64",
    "linux/arm64",
  ]
}

target "kind-node-v1_19" {
  inherits = ["_common", "_kind-node-common"]
  args = {
    KIND_NODE_UPSTREAM_IMAGE = "${KIND_NODE_UPSTREAM_IMAGE}:${K8S_V1_19_VERSION}"
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kind-node:${K8S_V1_19_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kind-node:${majorminorversion(K8S_V1_19_VERSION)}",
  ]
}

target "kind-node-v1_20" {
  inherits = ["_common", "_kind-node-common"]
  args = {
    KIND_NODE_UPSTREAM_IMAGE = "${KIND_NODE_UPSTREAM_IMAGE}:${K8S_V1_20_VERSION}"
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kind-node:${K8S_V1_20_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kind-node:${majorminorversion(K8S_V1_20_VERSION)}",
  ]
}

target "kind-node-v1_21" {
  inherits = ["_common", "_kind-node-common"]
  args = {
    KIND_NODE_UPSTREAM_IMAGE = "${KIND_NODE_UPSTREAM_IMAGE}:${K8S_V1_21_VERSION}"
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kind-node:${K8S_V1_21_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kind-node:${majorminorversion(K8S_V1_21_VERSION)}",
  ]
}

target "kind-node-v1_22" {
  inherits = ["_common", "_kind-node-common"]
  args = {
    KIND_NODE_UPSTREAM_IMAGE = "${KIND_NODE_UPSTREAM_IMAGE}:${K8S_V1_22_VERSION}"
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kind-node:${K8S_V1_22_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kind-node:${majorminorversion(K8S_V1_22_VERSION)}",
  ]
}

target "redfishtool" {
  target = "redfishtool"
  inherits = ["_common"]
  args = {
    REDFISHTOOL_VERSION = REDFISHTOOL_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/redfishtool:${REDFISHTOOL_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/redfishtool:${majorminorversion(REDFISHTOOL_VERSION)}",
  ]
  platforms = ["linux/amd64"]
}

target "trivy" {
  target = "trivy"
  inherits = ["_common"]
  args = {
    TRIVY_UPSTREAM_IMAGE = "${TRIVY_UPSTREAM_IMAGE}:${TRIVY_VERSION}"
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/trivy:${TRIVY_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/trivy:${majorminorversion(TRIVY_VERSION)}",
  ]
  platforms = ["linux/amd64"]
}
