# Minecraft AutoRun Systemd Service

This systemd service automatically starts and manages a Minecraft server script (`crashfix.sh`) using `screen`.  
It ensures the server restarts if it crashes and runs after the network and required mounts are ready.

## Installation

Copy the service file to `/etc/systemd/system/`:

