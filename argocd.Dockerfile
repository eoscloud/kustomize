# Copyright 2024 The Kubernetes Authors.
# SPDX-License-Identifier: Apache-2.0

# Stage 1: Build kustomize binary
FROM golang:1.26.2-trixie AS builder
ARG VERSION
ARG DATE
RUN mkdir /build
ADD . /build/
WORKDIR /build/kustomize
RUN CGO_ENABLED=0 GO111MODULE=on go build \
    -ldflags="-s \
    -X sigs.k8s.io/kustomize/api/provenance.version=${VERSION} \
    -X sigs.k8s.io/kustomize/api/provenance.buildDate=${DATE}" \
    -o kustomize .

# Stage 2: ArgoCD image with custom kustomize build
FROM argoproj/argocd:v2.6.15
COPY --from=builder /build/kustomize/kustomize /usr/local/bin/kustomize
