#!/bin/bash

# Check CPU architecture and display it
ARCH=$(uname -m)
echo "Your CPU architecture is: $ARCH"

# Download the appropriate file based on architecture
if [ "$ARCH" == "aarch64" ]; then
    DOWNLOAD_URL="https://github.com/Musixal/Backhaul/releases/download/v0.5.0/backhaul_linux_arm64.tar.gz"
    FILE_NAME="backhaul_linux_arm64.tar.gz"
elif [ "$ARCH" == "x86_64" ]; then
    DOWNLOAD_URL="https://github.com/Musixal/Backhaul/releases/download/v0.5.0/backhaul_linux_amd64.tar.gz"
    FILE_NAME="backhaul_linux_amd64.tar.gz"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

# Download the file
wget $DOWNLOAD_URL -O $FILE_NAME

# Extract the file
tar -xzf $FILE_NAME

# Remove unnecessary files
rm -f LICENSE README.md $FILE_NAME

# Ask user if the server is in Iran or abroad
echo "Select the server location:"
echo "1. Iran"
echo "2. Kharej"
read -p "Enter the number (1 or 2): " SERVER_SELECTION

if [ "$SERVER_SELECTION" == "1" ]; then
    TOKEN=$(openssl rand -hex 16)
    echo "Your generated token is: $TOKEN"

    # Ask user for ports
    read -p "Enter the ports you want to forward (use 'iranport:kharejport' format for different ports, comma separated for multiple): " PORTS

    # Format the ports correctly
    PORTS_ARRAY=()
    IFS=',' read -ra ADDR <<< "$PORTS"
    for i in "${ADDR[@]}"; do
        PORTS_ARRAY+=("\"$i\"")
    done
    PORTS_CONFIG=$(IFS=, ; echo "${PORTS_ARRAY[*]}")

    # Create the config.toml file for Iran
    cat <<EOL > /root/config.toml
[server]
bind_addr = "0.0.0.0:3080"
transport = "tcp"
token = "$TOKEN"
keepalive_period = 75
nodelay = true
heartbeat = 40
channel_size = 2048
sniffer = false
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
ports = [
 $PORTS_CONFIG
]
EOL

    echo "config.toml created successfully for the Iranian server."

elif [ "$SERVER_SELECTION" == "2" ]; then
    # Get the IP and token for the Iranian server
    read -p "Enter the Iran server's IP: " IRAN_IP
    read -p "Enter the token for the Iran server: " IRAN_TOKEN

    # Create the config.toml file for foreign server
    cat <<EOL > /root/config.toml
[client]
remote_addr = "$IRAN_IP:3080"
transport = "tcp"
token = "$IRAN_TOKEN"
connection_pool = 8
keepalive_period = 75
dial_timeout = 10
nodelay = true
retry_interval = 3
sniffer = false
web_port = 2060
sniffer_log = "/root/backhaul.json"
log_level = "info"
EOL

    echo "config.toml created successfully for the foreign server."

else
    echo "Invalid option. Please enter 1 or 2."
    exit 1
fi

# Create the service file for backhaul
cat <<EOL > /etc/systemd/system/backhaul.service
[Unit]
Description=Backhaul Reverse Tunnel Service
After=network.target

[Service]
Type=simple
ExecStart=/root/backhaul -c /root/config.toml
Restart=always
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd and enable/start the service
sudo systemctl daemon-reload
sudo systemctl enable backhaul.service
sudo systemctl start backhaul.service

# Show the status of the service
sudo systemctl status backhaul.service

# Show the logs for the service
journalctl -u backhaul.service -e -f
