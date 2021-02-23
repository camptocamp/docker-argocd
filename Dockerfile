FROM golang:1.16 as builder
RUN git clone --branch=20200403-1 --depth=1 https://github.com/camptocamp/helm-sops && \
    cd helm-sops && \
    go build

FROM argoproj/argocd:v1.8.5
USER root
COPY argocd-repo-server-wrapper /usr/local/bin/
COPY --from=builder /go/helm-sops/helm-sops /usr/local/bin/
RUN cd /usr/local/bin && \
    mv argocd-repo-server _argocd-repo-server && \
    mv argocd-repo-server-wrapper argocd-repo-server && \
    mv helm _helm && \
    mv helm2 _helm2 && \
    mv helm-sops helm && \
    ln helm helm2
USER argocd
