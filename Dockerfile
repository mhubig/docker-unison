FROM debian:stable-slim as builder

ENV UNISON_VERSION 2.51.2
ENV UNISON_SHA256 a2efcbeab651be6df69cc9b253011a07955ecb91fb407a219719451197849d5e

RUN set -ex; \
  apt-get -y update; \
  apt-get -y install curl build-essential opam; \
  \
  mkdir -p /usr/src/unison && cd /usr/src/unison; \
  curl -fsLO https://github.com/bcpierce00/unison/archive/v${UNISON_VERSION}.tar.gz; \
  echo "${UNISON_SHA256}  unison-${UNISON_VERSION}.tar.gz" | sha256sum -c -; \
  tar xzvf unison-${UNISON_VERSION}.tar.gz --skip 1; \
  \
  make

FROM debian:stable-slim
COPY --from=builder /usr/src/unison/src/unison* /usr/local/bin/

ENTRYPOINT ["unison"]
CMD ["-doc", "about"]
