ARG BASE_VERSION=1.10-dev.3

FROM gcr.io/istio-release/base:${BASE_VERSION}

COPY client /usr/local/bin/client
COPY server /usr/local/bin/server

ENTRYPOINT ["/usr/local/bin/server"]
