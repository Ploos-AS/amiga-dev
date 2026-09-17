# M7.2: keep both stages on the same qualified Debian snapshot.
# Refresh only through the documented base-image qualification procedure.
ARG DEBIAN_BASE=debian:bookworm-20260824-slim@sha256:88200866dfff7ea7f5cbcb6ec7c8a701889efe6fe859fe64d6990e4b07ea4171

FROM ${DEBIAN_BASE} AS toolchain

ARG DEBIAN_FRONTEND=noninteractive
ARG AMIGA_GCC_REPO=https://franke.ms/git/bebbo/amiga-gcc
ARG AMIGA_GCC_REF=926bf10f1ff0bb0e72d99d49b69b22828988761c

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      autoconf automake bison build-essential ca-certificates cmake curl flex \
      git libgmp-dev libmpc-dev libmpfr-dev libncurses-dev make ninja-build \
      python3 rsync texinfo wget xz-utils \
 && rm -rf /var/lib/apt/lists/*

COPY toolchain/bebbo.lock /tmp/bebbo.lock
COPY toolchain/build-inputs.lock /tmp/build-inputs.lock
COPY toolchain/git-locked /usr/local/bin/git
RUN chmod 0755 /usr/local/bin/git
WORKDIR /tmp
RUN git clone "${AMIGA_GCC_REPO}" amiga-gcc \
 && cd amiga-gcc \
 && git checkout --detach "${AMIGA_GCC_REF}" \
 && make update \
 && while IFS="$(printf '\t')" read -r repo commit origin; do \
      case "${repo}" in ''|'#'*) continue ;; esac; \
      test -d "${repo}"; \
      test "$(git -C "${repo}" config --get remote.origin.url)" = "${origin}"; \
      git -C "${repo}" checkout --detach "${commit}"; \
      test "$(git -C "${repo}" rev-parse HEAD)" = "${commit}"; \
    done < /tmp/bebbo.lock \
 && verify_available_inputs() { \
      while IFS="$(printf '\t')" read -r input expected; do \
        case "${input}" in ''|'#'*) continue ;; esac; \
        if [ -f "${input}" ]; then \
          actual="$(sha256sum "${input}" | awk '{print $1}')"; \
          test "${actual}" = "${expected}"; \
        fi; \
      done < /tmp/build-inputs.lock; \
    }; \
    verify_available_inputs \
 && mkdir -p /opt/amiga/share/amiga-dev \
 && cp /tmp/bebbo.lock /opt/amiga/share/amiga-dev/bebbo.lock \
 && cp /tmp/build-inputs.lock /opt/amiga/share/amiga-dev/build-inputs.lock \
 && SDL_TIMER_FILE="$(find . -type f -path '*/timer/amigaos/SDL_systimer.c' -print -quit)" \
 && test -n "${SDL_TIMER_FILE}" \
 && grep -Eq '^[[:space:]]*struct[[:space:]]+Library[[:space:]]*\*[[:space:]]*TimerBase[[:space:]]*;' "${SDL_TIMER_FILE}" \
 && sed -Ei '/^[[:space:]]*struct[[:space:]]+Library[[:space:]]*\*[[:space:]]*TimerBase[[:space:]]*;/d' "${SDL_TIMER_FILE}" \
 && LIBNIX_PREPLIB="projects/libnix/preplib" \
 && test -f "${LIBNIX_PREPLIB}" \
 && test "$(grep -c -- '-not -name __vwfprintf_total_size.o' "${LIBNIX_PREPLIB}")" -eq 1 \
 && test "$(grep -c -- '-not -name __vfwprintf_total_size.o' "${LIBNIX_PREPLIB}")" -eq 0 \
 && sed -i 's/__vwfprintf_total_size\.o/__vfwprintf_total_size.o/' "${LIBNIX_PREPLIB}" \
 && make -j"$(nproc)" all PREFIX=/opt/amiga \
 && while IFS="$(printf '\t')" read -r input expected; do \
      case "${input}" in ''|'#'*) continue ;; esac; \
      test -f "${input}"; \
      actual="$(sha256sum "${input}" | awk '{print $1}')"; \
      test "${actual}" = "${expected}"; \
    done < /tmp/build-inputs.lock \
 && test "$(git -C projects/vasm config --get remote.origin.url)" = "https://github.com/mheyer32/vasm" \
 && test "$(git -C projects/vasm rev-parse HEAD)" = "bb048d9d3cf54d5e38c643182a0ff55b552f65be" \
 && { \
      printf 'schema=2\n'; \
      printf 'amiga_gcc_repo=%s\n' "${AMIGA_GCC_REPO}"; \
      printf 'amiga_gcc_requested_ref=%s\n' "${AMIGA_GCC_REF}"; \
      printf 'amiga_gcc_commit=%s\n' "$(git rev-parse HEAD)"; \
      find . -type d -name .git -print | sort | while IFS= read -r gitdir; do \
        repo="${gitdir%/.git}"; \
        commit="$(git -C "${repo}" rev-parse HEAD)"; \
        origin="$(git -C "${repo}" config --get remote.origin.url || true)"; \
        printf 'repo=%s\tcommit=%s\torigin=%s\n' "${repo#./}" "${commit}" "${origin}"; \
      done; \
    } > /opt/amiga/share/amiga-dev/toolchain.manifest \
 && { \
      printf 'schema=1\n'; \
      while IFS="$(printf '\t')" read -r input expected; do \
        case "${input}" in ''|'#'*) continue ;; esac; \
        printf 'file=%s\tsha256=%s\n' "${input}" "${expected}"; \
      done < /tmp/build-inputs.lock; \
    } > /opt/amiga/share/amiga-dev/build-inputs.manifest

FROM ${DEBIAN_BASE}

ARG DEBIAN_FRONTEND=noninteractive
ARG AMITOOLS_VERSION=0.8.1
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      binutils build-essential ca-certificates cmake curl default-jre-headless file git jlha-utils jq make ninja-build \
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
COPY scripts/amiga-package /usr/local/bin/amiga-package
RUN chmod 0755 /usr/local/bin/amiga-dev-smoke /usr/local/bin/amiga-toolchain-info \
      /usr/local/bin/amiga-build /usr/local/bin/amiga-check \
      /usr/local/bin/amiga-test /usr/local/bin/amiga-inspect /usr/local/bin/amiga-package

ENV AMIGA_PREFIX=/opt/amiga
ENV AMIGA_CPU_PROFILE=68000
ENV AMIGA_TOOLCHAIN_MANIFEST=/opt/amiga/share/amiga-dev/toolchain.manifest
ENV AMIGA_BUILD_INPUTS_MANIFEST=/opt/amiga/share/amiga-dev/build-inputs.manifest
ENV PATH="/opt/amiga/bin:${PATH}"
WORKDIR /workspace
USER amiga

CMD ["/bin/bash"]
