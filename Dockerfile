# Forensics Analysis Container Template
FROM ubuntu:22.04

# Prevent interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive

# Set timezone to UTC
ENV TZ=UTC

# Install required packages to setup SSH and enable sudo
RUN apt update && apt install -y \
    openssh-server \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Run the setup script to install additional tools
COPY setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh
RUN /usr/local/bin/setup.sh

# Create forensics directory structure
WORKDIR /forensics
RUN mkdir -p \
    /forensics/images \
    /forensics/output \
    /forensics/tools \
    /forensics/scripts \
    /forensics/evidence \
    /forensics/reports \
    /forensics/workspaces

# Configure SSH server
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Copy and setup startup script for SSH and user management
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set working directory
WORKDIR /forensics

# Expose SSH port
EXPOSE 22

# Start the container with SSH service
CMD ["/usr/local/bin/entrypoint.sh"]