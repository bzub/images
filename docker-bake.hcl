variable "REGISTRY" {default = "ghcr.io"}
variable "USERNAME" {default = "bzub"}
variable "REPO_NAME" {default = "images"}
variable "TAG" {default = "dev"}

variable "ALPINE_VERSION" {default = "3.15.0"}
variable "BUILDX_VERSION" {default = "0.7.1"}
variable "DOCKER_VERSION" {default = "20.10.12-alpine3.15"}

variable "ALPINE_IMAGE" {default = "docker.io/library/alpine:${ALPINE_VERSION}"}
variable "BUILDX_IMAGE" {default = "docker.io/docker/buildx-bin:${BUILDX_VERSION}"}
variable "DOCKER_IMAGE" {default = "docker.io/library/docker:${DOCKER_VERSION}"}

group "default" {
  targets = ["base"]
}

target "docker-metadata-action" {}

target "base" {
  inherits = ["docker-metadata-action"]
  tags = [
    "${REGISTRY}/${USERNAME}/${REPO_NAME}/base:${TAG}",
  ]
  args = {
    ALPINE_IMAGE = ALPINE_IMAGE
    BUILDX_IMAGE = BUILDX_IMAGE
    DOCKER_IMAGE = DOCKER_IMAGE
  }
}
