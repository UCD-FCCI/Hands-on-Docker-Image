# Hands-on Docker Image Template

A customizable Docker template for creating hands-on digital forensics investigation containers with SSH access and organized file structure.

## Overview

This repository provides a template for building Docker images specifically designed for digital forensics analysis. The template creates an Ubuntu-based container with SSH access, organized directory structure, and a framework for adding custom forensics tools and evidence files.

## Quick Start

1. **Create a new repository from this template**

    1. Open the template repository page:
    https://github.com/UCD-FCCI/Hands-on-Docker-Image

    2. Click "**Use this template**" button at the top right → choose an owner, give the new repository a name, set visibility (**should be Private due to exam security**), then click "**Create repository from template**".

    3. Clone the new repository locally:
    ```bash
    # HTTPS
    git clone https://github.com/YOUR_USERNAME/NEW_REPO_NAME.git

    cd NEW_REPO_NAME
    ```

> [!NOTE]
> - Replace YOUR_USERNAME and NEW_REPO_NAME with appropriate values.
> - After creating the repository, customize app.py and other files as described below.

2. **Customize the setup (see [Customization](#customization) section below)**

3. **Build your image (see [Build and Usage](#building-and-usage) section below for more details):**
   ```bash
   docker build -t your-forensics-image .
   ```

4. **Run the container:**
   ```bash
   docker run -d -p 2222:22 your-forensics-image
   ```

5. **Connect via SSH:**
   ```bash
   ssh forensics@localhost -p 2222
   # Default password: forensics123
   ```

## Container Features

- **Ubuntu 22.04** base image
- **SSH server** for remote access
- **Organized directory structure** for forensics work
- **Sudo access** for the forensics user
- **Customizable setup script** for adding tools and evidence
- **Environment variables** for configuring SSH credentials

## Directory Structure

Once inside the container, you'll find the following organized structure:

```
/forensics/
├── images/      # Disk images and snapshots during the analysis
├── output/      # Analysis results and extracted data
├── tools/       # Custom forensics tools
├── scripts/     # Analysis scripts and utilities
├── evidence/    # Evidence files
├── reports/     # Investigation reports
└── workspaces/  # Working directories for analysis
```

## Customization

### Primary Method: Modify `setup.sh`

The main customization point is the `setup.sh` script. This is where you should add all your custom forensics tools, evidence files, and configuration.

#### Installing Tools

Add package installations and tool compilations to `setup.sh`:

```bash
#!/bin/bash

# Install forensics tools via apt
apt update && apt install -y \
    sleuthkit \
    autopsy \
    volatility3 \
    binwalk \
    foremost \
    hexedit \
    wireshark-common \
    tcpdump \
    && rm -rf /var/lib/apt/lists/*

# Install tools from source
cd /forensics/tools

# Example: Install custom tool
git clone https://github.com/example/forensics-tool.git
cd forensics-tool
make && make install
cd ..

# Download and setup additional tools
wget https://example.com/tool.tar.gz
tar -xzf tool.tar.gz
rm tool.tar.gz
```

#### Adding Evidence Files (OPTIONAL)

Include evidence files during the build process:

```bash
cd /forensics/evidence
wget https://example.com/sample-evidence.dd
```

> [!NOTE]
> You don't need to insert the evidence files during the build process of the Docker image, unless you want to.
> Our computer-based exam platform supports mounting the evidence file as ***read-only*** during the exam deployment.

#### Adding Custom Scripts

Include your analysis scripts:

```bash
# Copy scripts
cd /forensics/scripts/
wget https://example.com/sample-script.sh
chmod +x sample-script.sh
```

#### Python Packages and Dependencies

Install Python forensics libraries:

```bash
# Install Python packages
apt update && apt install -y python3-pip
pip3 install \
    volatility3 \
    pycryptodome \
    yara-python \
    python-magic \
    pillow
```

### Configuration Options

#### SSH Credentials

Customize SSH access by setting environment variables when running the container:

```bash
docker run -d -p 2222:22 \
  -e SSH_USERNAME=analyst \
  -e SSH_PASSWORD=secure123 \
  your-forensics-image
```

#### Persistent Storage

Mount host directories for persistent storage:

```bash
docker run -d -p 2222:22 \
  -v /host/evidence:/forensics/evidence \
  -v /host/output:/forensics/output \
  your-forensics-image
```

## Building and Usage

### Build Command

```bash
docker build -t forensics-analysis .
```

### Run with Custom Configuration

```bash
# Run with custom SSH credentials and mounted volumes
docker run -d \
  --name forensics-container \
  -p 2222:22 \
  -e SSH_USERNAME=investigator \
  -e SSH_PASSWORD=MySecurePassword123 \
  -v $(pwd)/evidence:/forensics/evidence \
  -v $(pwd)/output:/forensics/output \
  forensics-analysis
```

### Connect to Container

```bash
# SSH connection
ssh investigator@localhost -p 2222

# Or use docker exec for direct access
docker exec -it forensics-container bash
```

## Troubleshooting

- **SSH Connection Issues**: Ensure port 2222 is available and not used by other applications or services
- **Permission Issues**: The forensics user has sudo access; use `sudo` for system operations
- **Tool Installation Failures**: Check package names and availability for Ubuntu 22.04
- **Container Won't Start**: Check Docker logs with `docker logs <container-name>`

## Technical Issues
This template is maintained as part of the computer-based examination platform. For technical support or feature requests, please create an [ISSUE](https://github.com/UCD-FCCI/Hands-on-Docker-Image/issues).

## Version History
- v1.0: Initial template release.