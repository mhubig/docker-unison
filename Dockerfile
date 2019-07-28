FROM alpine:3.10 as builder

ENV UNISON_VERSION 2.51.2
ENV UNISON_SHA256 a2efcbeab651be6df69cc9b253011a07955ecb91fb407a219719451197849d5e

COPY fix-inotify-check.patch /usr/src/unison/fix-inotify-check.patch

RUN set -ex; \
  apk add --no-cache curl make libc-dev opam; \
  \
  cd /usr/src/unison; \
  curl -fsLO https://github.com/bcpierce00/unison/archive/v${UNISON_VERSION}.tar.gz; \
  echo "${UNISON_SHA256}  v${UNISON_VERSION}.tar.gz" | sha256sum -c -; \
  tar xzvf v${UNISON_VERSION}.tar.gz --strip 1; \
  cat fix-inotify-check.patch |patch -d src -p 1; \
  \
  make

FROM alpine:3.10
COPY --from=builder /usr/src/unison/src/unison* /usr/local/bin/
CMD ["unison", "-doc", "about"]
