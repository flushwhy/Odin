# syntax=docker/dockerfile:1

FROM debian:trixie-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG ODIN_VERSION=master

# Install build dependencies and available security updates.
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        gnupg \
        make \
        wget \
        libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Add the official LLVM repository.
RUN wget -qO- https://apt.llvm.org/llvm-snapshot.gpg.key \
    | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] https://apt.llvm.org/trixie/ llvm-toolchain-trixie-22 main" \
    > /etc/apt/sources.list.d/llvm.list

# Install LLVM 22 and Clang 22.
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        clang-22 \
        lld-22 \
        llvm-22 \
        llvm-22-dev \
    && rm -rf /var/lib/apt/lists/*

# Provide standard tool names.
RUN ln -s /usr/bin/llvm-config-22 /usr/local/bin/llvm-config \
    && ln -s /usr/bin/clang-22 /usr/local/bin/clang

# Fetch and build Odin.
WORKDIR /opt/odin

RUN git init \
    && git remote add origin https://github.com/odin-lang/Odin.git \
    && git fetch --depth=1 origin "${ODIN_VERSION}" \
    && git checkout --detach FETCH_HEAD \
    && ./build_odin.sh \
    && ln -s /opt/odin/odin /usr/local/bin/odin

WORKDIR /app

CMD ["odin", "version"]
