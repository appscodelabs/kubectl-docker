FROM alpine

ARG TARGETOS
ARG TARGETARCH
ARG VERSION

RUN set -x \
	&& apk add --update ca-certificates curl zip bzip2

RUN set -x \
	&& curl -LO "https://dl.k8s.io/release/$VERSION/bin/${TARGETOS}/${TARGETARCH}/kubectl" \
	&& chmod +x kubectl



FROM registry.access.redhat.com/ubi10/ubi-minimal

ARG VERSION

LABEL org.opencontainers.image.source="https://github.com/appscodelabs/kubectl-docker" \
    name="kubectl" \
    maintainer=AppsCode \
    vendor=AppsCode \
    version=${VERSION} \
    release=${VERSION} \
    summary="Kubernetes Command line tool" \
    description="Kubernetes Command line tool"

RUN mkdir -p /licenses
COPY LICENSE /licenses/

RUN set -x \
  && microdnf update -y \
  && microdnf install -y curl tzdata wget \
  && microdnf clean all

ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY --from=0 /kubectl /usr/bin/kubectl

USER 65534
