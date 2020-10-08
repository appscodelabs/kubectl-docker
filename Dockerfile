FROM debian

LABEL org.opencontainers.image.source https://github.com/appscode/kubectl-docker

ARG OS
ARG ARCH
ARG VERSION

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl bzip2

RUN set -x \
	&& curl -fsSL https://dl.k8s.io/$VERSION/kubernetes-client-$OS-$ARCH.tar.gz | tar -zxv

FROM busybox
COPY --from=0 /kubernetes/client/bin/kubectl /usr/bin/kubectl
