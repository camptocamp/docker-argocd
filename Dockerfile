FROM docker.io/golang:1.20 as builder
RUN git clone --branch=20230623-1 --depth=1 https://github.com/camptocamp/helm-sops && \
    cd helm-sops && \
    go build

FROM quay.io/argoproj/argocd:v2.11.3
USER root
COPY argocd-repo-server-wrapper /usr/local/bin/
COPY --from=builder /go/helm-sops/helm-sops /usr/local/bin/
RUN cd /usr/local/bin && \
    mv argocd-repo-server _argocd-repo-server && \
    mv argocd-repo-server-wrapper argocd-repo-server && \
    chmod 755 argocd-repo-server && \
    mv helm _helm && \
    mv helm-sops helm
USER 999
