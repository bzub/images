variable "REGISTRY" {default = "ghcr.io"}
variable "USERNAME" {default = "bzub"}
variable "REPO_NAME" {default = "images"}

variable "ALPINE_VERSION" {default = "3.15.0"}
variable "KPT_VERSION" {default = "v1.0.0-beta.13"}
variable "KIND_VERSION" {default = "v0.11.1"}
variable "CAPI_V0_3_VERSION" {default = "v0.3.24"}
variable "CAPI_V0_4_VERSION" {default = "v0.4.5"}
variable "CAPI_V1_0_VERSION" {default = "v1.0.2"}
variable "CAPI_V1_1_VERSION" {default = "v1.1.2"}

variable "ALPINE_IMAGE" {default = "docker.io/library/alpine:${ALPINE_VERSION}"}
variable "KPT_IMAGE" {default = "ghcr.io/bzub/images/kpt:${KPT_VERSION}"}
variable "KIND_IMAGE" {default = "ghcr.io/bzub/images/kind:${KIND_VERSION}"}
variable "CLUSTERCTL_V0_3_IMAGE" {default = "ghcr.io/bzub/images/clusterctl:${CAPI_V0_3_VERSION}"}
variable "CLUSTERCTL_V0_4_IMAGE" {default = "ghcr.io/bzub/images/clusterctl:${CAPI_V0_4_VERSION}"}
variable "CLUSTERCTL_V1_0_IMAGE" {default = "ghcr.io/bzub/images/clusterctl:${CAPI_V1_0_VERSION}"}
variable "CLUSTERCTL_V1_1_IMAGE" {default = "ghcr.io/bzub/images/clusterctl:${CAPI_V1_1_VERSION}"}

group "default" {
  targets = [
    "kpt",
    "kind",
    "clusterctl",
  ]
}

target "docker-metadata-action" {}

target "_common" {
  inherits = ["docker-metadata-action"]
  args = {
    ALPINE_IMAGE = ALPINE_IMAGE
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
  args = {
    KPT_VERSION = KPT_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kpt:${KPT_VERSION}"
  ]
}

target "kind" {
  inherits = ["_common"]
  args = {
    KIND_VERSION = KIND_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/kind:${KIND_VERSION}"
  ]
}

group "clusterctl" {
  targets = [
    "clusterctl-v0.3",
    "clusterctl-v0.4",
    "clusterctl-v1.0",
    "clusterctl-v1.1",
  ]
}

target "clusterctl-v0.3" {
  inherits = ["_common"]
  target = "clusterctl"
  args = {
    CLUSTERCTL_VERSION = CAPI_V0_3_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${CAPI_V0_3_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:v0.3",
  ]
}

target "clusterctl-v0.4" {
  inherits = ["_common"]
  target = "clusterctl"
  args = {
    CLUSTERCTL_VERSION = CAPI_V0_4_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${CAPI_V0_4_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:v0.4",
  ]
}

target "clusterctl-v1.0" {
  inherits = ["_common"]
  target = "clusterctl"
  args = {
    CLUSTERCTL_VERSION = CAPI_V1_0_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${CAPI_V1_0_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:v1.0",
  ]
}

target "clusterctl-v1.1" {
  inherits = ["_common"]
  target = "clusterctl"
  args = {
    CLUSTERCTL_VERSION = CAPI_V1_1_VERSION
  }
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:${CAPI_V1_1_VERSION}",
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/clusterctl:v1.1",
  ]
}
