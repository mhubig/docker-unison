FROM alpine:3.11 as builder

ENV UNISON_VERSION 2.51.2
ENV UNISON_SHA256 a2efcbeab651be6df69cc9b253011a07955ecb91fb407a219719451197849d5e

WORKDIR /usr/src/unison

COPY fix-inotify-check.patch /usr/src/unison/fix-inotify-check.patch
COPY ocaml-4.08.patch /usr/src/unison/ocaml-4.08.patch

RUN set -ex; \
  \
  export UNISON_VERSION=2.51.2 UNISON_SHA256=a2efcbeab651be6df69cc9b253011a07955ecb91fb407a219719451197849d5e; \
  apk --update add --no-cache \
    libc-dev \
    make \
    opam \
  \
  && wget https://github.com/bcpierce00/unison/archive/v${UNISON_VERSION}.tar.gz \
  \
  && echo "${UNISON_SHA256}  v${UNISON_VERSION}.tar.gz" | sha256sum -c - \
  \
  && tar xzvf v${UNISON_VERSION}.tar.gz --strip 1 \
  \
  && cat fix-inotify-check.patch \
       | patch -d src -p 1 \
  \
  && cat ocaml-4.08.patch \
       | patch -d src -p 1 \
  && make -j$(nproc) \
  \
  && src/unison -doc about

FROM alpine:3.11
COPY --from=builder /usr/src/unison/src/unison /usr/src/unison/src/unison-fsmonitor /usr/local/bin/
CMD ["unison", "-doc", "about"]
