FROM debian:bookworm-slim AS toolchain

ARG DEBIAN_FRONTEND=noninteractive
ARG AMIGA_GCC_REPO=https://franke.ms/git/bebbo/amiga-gcc

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      autoconf automake bison build-essential ca-certificates cmake curl flex \
      git libgmp-dev libmpc-dev libmpfr-dev libncurses-dev make ninja-build \
      python3 rsync texinfo wget xz-utils \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN git clone "${AMIGA_GCC_REPO}" amiga-gcc \
 && cd amiga-gcc \
 && make update \
 && SDL_TIMER_FILE="$(find . -type f -path '*/timer/amigaos/SDL_systimer.c' -print -quit)" \
 && test -n "${SDL_TIMER_FILE}" \
 && grep -Eq '^[[:space:]]*struct[[:space:]]+Library[[:space:]]*\*[[:space:]]*TimerBase[[:space:]]*;' "${SDL_TIMER_FILE}" \
 && sed -Ei '/^[[:space:]]*struct[[:space:]]+Library[[:space:]]*\*[[:space:]]*TimerBase[[:space:]]*;/d' "${SDL_TIMER_FILE}" \
 && LIBNIX_PREPLIB="projects/libnix/preplib" \
 && test -f "${LIBNIX_PREPLIB}" \
 && test "$(grep -c -- '-not -name __vwfprintf_total_size.o' "${LIBNIX_PREPLIB}")" -eq 1 \
 && test "$(grep -c -- '-not -name __vfwprintf_total_size.o' "${LIBNIX_PREPLIB}")" -eq 0 \
 && sed -i 's/__vwfprintf_total_size\.o/__vfwprintf_total_size.o/' "${LIBNIX_PREPLIB}" \
 && make -j"$(nproc)" all PREFIX=/opt/amiga

FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG AMITOOLS_VERSION=0.8.1
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      binutils build-essential ca-certificates cmake curl file git jq make ninja-build \
      pkg-config python3 python3-pip python3-venv rsync unzip wget xxd xz-utils zip \
 && rm -rf /var/lib/apt/lists/* \
 && python3 -m pip install --no-cache-dir --break-system-packages "amitools==${AMITOOLS_VERSION}"

COPY --from=toolchain /opt/amiga /opt/amiga

RUN useradd --create-home --uid 10001 --shell /bin/bash amiga \
 && mkdir -p /workspace \
 && chown -R amiga:amiga /workspace

COPY scripts/amiga-dev-smoke /usr/local/bin/amiga-dev-smoke
COPY scripts/amiga-toolchain-info /usr/local/bin/amiga-toolchain-info
COPY scripts/amiga-build /usr/local/bin/amiga-build
COPY scripts/amiga-check /usr/local/bin/amiga-check
COPY scripts/amiga-test /usr/local/bin/amiga-test
COPY scripts/amiga-inspect /usr/local/bin/amiga-inspect
RUN chmod 0755 /usr/local/bin/amiga-dev-smoke /usr/local/bin/amiga-toolchain-info \
      /usr/local/bin/amiga-build /usr/local/bin/amiga-check \
      /usr/local/bin/amiga-test /usr/local/bin/amiga-inspect

ENV AMIGA_PREFIX=/opt/amiga
ENV AMIGA_CPU_PROFILE=68000
ENV PATH="/opt/amiga/bin:${PATH}"
WORKDIR /workspace
USER amiga

CMD ["/bin/bash"]
