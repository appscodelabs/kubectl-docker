FROM alpine

ARG TARGETOS
ARG TARGETARCH
ARG VERSION

RUN set -x \
	&& apk add --update ca-certificates curl zip bzip2

RUN set -x \
	&& curl -LO https://github.com/moparisthebest/static-curl/archive/refs/heads/master.zip \
	&& unzip master.zip \
	&& cd static-curl-master \
	&& ARCH=${TARGETARCH} ./build.sh

RUN set -x \
	&& curl -LO "https://dl.k8s.io/release/$VERSION/bin/${TARGETOS}/${TARGETARCH}/kubectl" \
	&& chmod +x kubectl



FROM busybox

LABEL org.opencontainers.image.source https://github.com/appscodelabs/kubectl-docker

ARG TARGETARCH

COPY --from=0 /tmp/release/curl-$TARGETARCH /usr/bin/curl
COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=0 /kubectl /usr/bin/kubectl
