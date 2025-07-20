# Base image: Use an official lightweight Linux distribution
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    python3 \
    python3-pip \
    libssl-dev \
    clang \
    gdb \
    make \
    openssh-server \
    sudo

# Add a user with the same UID and GID as the host user
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} devgroup && \
    useradd -m -u ${UID} -g ${GID} -s /bin/bash devuser && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the new user
USER devuser

# Set working directory
WORKDIR /workspace

CMD ["tail", "-f", "/dev/null"]