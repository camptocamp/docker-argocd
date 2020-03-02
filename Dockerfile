FROM golang:1.13 as builder
RUN git clone --branch=20200311-1 --depth=1 https://github.com/camptocamp/helm-sops && \
    cd helm-sops && \
    go build

FROM argoproj/argocd:v1.4.2
USER root
RUN apt-get update && \
    apt-get install -y \
      awscli \
      gpg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN mv /usr/local/bin/argocd-repo-server /usr/local/bin/_argocd-repo-server && \
    mv /usr/local/bin/helm /usr/local/bin/_helm
COPY argocd-repo-server-wrapper /usr/local/bin/argocd-repo-server
COPY --from=builder /go/helm-sops/helm-sops /usr/local/bin/helm
USER argocd
