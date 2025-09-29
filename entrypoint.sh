#!/bin/bash

# Get SSH username and password from environment variables (with defaults)
SSH_USERNAME=${SSH_USERNAME:-forensics}
SSH_PASSWORD=${SSH_PASSWORD:-forensics123}

# Check if user already exists, if not create it
if ! id "$SSH_USERNAME" &>/dev/null; then
    echo "Creating user: $SSH_USERNAME"
    useradd -m -s /bin/bash "$SSH_USERNAME"
    usermod -aG sudo "$SSH_USERNAME"
    echo "$SSH_USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    
    # Set up user environment
    chown -R "$SSH_USERNAME:$SSH_USERNAME" /forensics
fi

# Set up user's shell profile to start in /forensics directory
USER_HOME="/home/$SSH_USERNAME"
if [ -d "$USER_HOME" ]; then
    # Add cd command to .bashrc if not already present
    if ! grep -q "cd /forensics" "$USER_HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$USER_HOME/.bashrc"
        echo "# Auto-navigate to forensics directory" >> "$USER_HOME/.bashrc"
        echo "cd /forensics" >> "$USER_HOME/.bashrc"
        chown "$SSH_USERNAME:$SSH_USERNAME" "$USER_HOME/.bashrc"
    fi
fi

# Set password for the SSH user
echo "$SSH_USERNAME:$SSH_PASSWORD" | chpasswd
echo "Password set for user: $SSH_USERNAME"

# Create user environment and help system
echo 'echo "============================================="' >> "$USER_HOME/.bashrc" && \
echo 'echo "  Digital Forensics Analysis Container"' >> "$USER_HOME/.bashrc" && \
echo 'echo "============================================="' >> "$USER_HOME/.bashrc" && \
echo 'echo "Evidence:   /forensics/evidence/"' >> "$USER_HOME/.bashrc" && \
echo 'echo "Tools:      /forensics/tools/"' >> "$USER_HOME/.bashrc" && \
echo 'echo "Scripts:    /forensics/scripts/"' >> "$USER_HOME/.bashrc" && \
echo 'echo "Output:     /forensics/output/"' >> "$USER_HOME/.bashrc" && \
echo 'echo "Reports:    /forensics/reports/"' >> "$USER_HOME/.bashrc" && \
chown "$SSH_USERNAME:$SSH_USERNAME" "$USER_HOME/.bashrc"

# Start SSH daemon
service ssh start

# Keep container running
tail -f /dev/null