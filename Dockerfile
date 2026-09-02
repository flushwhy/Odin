FROM debian:bookworm-slim

# Install wget, software properties, and gnupg to add the LLVM apt repo
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    ca-certificates \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Add LLVM official nightly/release repository for Debian Bookworm (using LLVM 22 as suggested)
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/llvm-archive-keyring.gpg] http://apt.llvm.org/bookworm/ llvm-toolchain-bookworm-22 main" > /etc/apt/sources.list.d/llvm.list

# Install LLVM 22, Clang 22, LLD, and development packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    clang-22 \
    llvm-22 \
    llvm-22-dev \
    lld-22 \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Point llvm-config to the version-specific binary so Odin's build script detects it
RUN ln -s /usr/bin/llvm-config-22 /usr/bin/llvm-config
RUN ln -s /usr/bin/clang-22 /usr/bin/clang

WORKDIR /app

# Accept version or branch as a build argument (defaults to master for nightly)
ARG ODIN_VERSION=master

# Clone Odin at the specified tag, branch, or commit
RUN git clone --depth=1 --branch ${ODIN_VERSION} https://github.com/odin-lang/Odin.git /opt/odin

# Build Odin from source
RUN cd /opt/odin && ./build_odin.sh

# Create a symlink for global access
RUN ln -s /opt/odin/odin /usr/local/bin/odin

CMD ["odin", "version"]