#!/bin/bash

# Exit on any error
set -e

echo "➡ Switching to /opt"
cd /opt

echo "➡ Cleaning old /opt/nexus if it exists"
sudo mv /opt/nexus /opt/nexus.broken 2>/dev/null || true

echo "➡ Downloading Nexus"
sudo wget https://download.sonatype.com/nexus/3/nexus-unix-x86-64-3.79.0-09.tar.gz

echo "➡ Extracting Nexus"
sudo tar -xvzf nexus-unix-x86-64-3.79.0-09.tar.gz
sudo mv nexus-3.79.0-09 nexus

echo "➡ Creating nexus user"
sudo useradd -M -d /opt/nexus -s /bin/bash nexus || true

echo "➡ Setting ownership"
sudo mkdir -p /opt/sonatype-work
sudo chown -R nexus:nexus /opt/nexus /opt/sonatype-work

echo "➡ Setting run_as_user"
echo 'run_as_user="nexus"' | sudo tee /opt/nexus/bin/nexus.rc

echo "➡ Creating systemd service"
sudo tee /etc/systemd/system/nexus.service > /dev/null <<EOF
[Unit]
Description=Nexus Repository Manager
After=network.target

[Service]
Type=forking
LimitNOFILE=65536
ExecStart=/opt/nexus/bin/nexus start
ExecStop=/opt/nexus/bin/nexus stop
User=nexus
Restart=on-abort

[Install]
WantedBy=multi-user.target
EOF

echo "➡ Enabling and starting Nexus"
sudo systemctl daemon-reload
sudo systemctl enable nexus
sudo systemctl start nexus

echo "✅ Nexus installation complete"
sudo systemctl status nexus
