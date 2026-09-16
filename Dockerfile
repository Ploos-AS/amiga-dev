FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      build-essential ca-certificates cmake curl file git jq make ninja-build \
      pkg-config python3 python3-pip python3-venv rsync unzip wget xz-utils zip \
 && rm -rf /var/lib/apt/lists/*

RUN useradd --create-home --uid 10001 --shell /bin/bash amiga \
 && mkdir -p /workspace /opt/amiga \
 && chown -R amiga:amiga /workspace /opt/amiga

COPY scripts/amiga-dev-smoke /usr/local/bin/amiga-dev-smoke
RUN chmod 0755 /usr/local/bin/amiga-dev-smoke

ENV AMIGA_PREFIX=/opt/amiga
ENV PATH="/opt/amiga/bin:${PATH}"
WORKDIR /workspace
USER amiga

CMD ["/bin/bash"]
