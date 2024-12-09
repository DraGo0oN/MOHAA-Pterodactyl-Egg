# Use Ubuntu latest as the base image
FROM ubuntu:latest

# Set environment variables for non-interactive frontend and user configuration
ENV DEBIAN_FRONTEND=noninteractive \
    USER=container \
    HOME=/home/container

# Create a user, set up home directory, and symlink for compatibility
RUN useradd -m -d $HOME -s /bin/bash $USER && \
    ln -s $HOME /nonexistent && \
    mkdir -p $HOME/.local/bin && \
    echo "PATH=$HOME/.local/bin:$PATH" >> $HOME/.bashrc

# Update package lists, install dependencies, and clean up
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        dpkg \
        wget \
        curl \
        tar \
        zip \
        unzip \
        tini \
        locales \
        binutils \
        xz-utils \
        libstdc++5:i386 \
        iproute2 \
        net-tools \
        ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up locales
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8

# Set the working directory to the user's home
WORKDIR $HOME

# Specify the stop signal for graceful shutdown
STOPSIGNAL SIGINT

# Copy the entrypoint script into the container
COPY --chown=$USER:$USER ./entrypoint.sh /entrypoint.sh

# Make the entrypoint script executable
RUN chmod +x /entrypoint.sh

# Use tini as the init system for better signal handling
ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["/entrypoint.sh"]