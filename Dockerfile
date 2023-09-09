FROM docker.io/golang:1.20 as builder
RUN git clone --branch=20230623-1 --depth=1 https://github.com/camptocamp/helm-sops && \
    cd helm-sops && \
    go build
RUN wget -O /tmp/helmfile https://github.com/roboll/helmfile/releases/download/v0.144.0/helmfile_linux_amd64 && chmod +x /tmp/helmfile
RUN wget -O /tmp/yq https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_amd64 && chmod +x /tmp/yq

FROM quay.io/argoproj/argocd:v2.8.3
USER root
COPY argocd-repo-server-wrapper /usr/local/bin/
COPY argocd-helmfile /usr/local/bin/
COPY --from=builder /go/helm-sops/helm-sops /usr/local/bin/
COPY --from=builder /tmp/helmfile /usr/local/bin/
COPY --from=builder /tmp/yq /usr/local/bin/
RUN cd /usr/local/bin && \
    mv argocd-repo-server _argocd-repo-server && \
    mv argocd-repo-server-wrapper argocd-repo-server && \
    chmod 755 argocd-repo-server && \
    mv helm _helm && \
    mv helm-sops helm
USER 999
