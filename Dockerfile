FROM golang:1.17 as builder
RUN git clone --branch=20200403-1 --depth=1 https://github.com/camptocamp/helm-sops && \
    cd helm-sops && \
    go build
RUN wget -O /tmp/helmfile https://github.com/roboll/helmfile/releases/download/v0.144.0/helmfile_linux_amd64 && chmod +x /tmp/helmfile
RUN wget -O /tmp/yq https://github.com/mikefarah/yq/releases/download/v4.25.1/yq_linux_amd64 && chmod +x /tmp/yq

FROM argoproj/argocd:v2.4.11
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
    mv helm2 _helm2 && \
    mv helm-sops helm && \
    ln helm helm2

USER 999
