FROM alpine

ARG TARGETARCH

RUN set -x \
	&& apk add --update ca-certificates curl zip

RUN set -x \
	&& curl -LO https://github.com/moparisthebest/static-curl/archive/refs/heads/master.zip \
	&& unzip master.zip \
	&& cd static-curl-master \
	&& ARCH=${TARGETARCH} ./build.sh



FROM debian

ARG TARGETOS
ARG TARGETARCH
ARG VERSION

ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

RUN set -x \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl bzip2

RUN set -x \
	&& curl -fsSL https://dl.k8s.io/$VERSION/kubernetes-client-${TARGETOS}-${TARGETARCH}.tar.gz | tar -zxv



FROM busybox

LABEL org.opencontainers.image.source https://github.com/appscodelabs/kubectl-docker

ARG TARGETARCH

COPY --from=0 /tmp/release/curl-$TARGETARCH /usr/bin/curl
COPY --from=1 /kubernetes/client/bin/kubectl /usr/bin/kubectl
