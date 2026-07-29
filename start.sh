#!/bin/bash
# startup script for 3x-ui on Railway
echo "=== DEBUG ==="
echo "CWD: $(pwd)"
echo "PATH: $PATH"
ls -la /root/bin/ 2>/dev/null || echo "/root/bin/ NOT FOUND"
ls -la bin/ 2>/dev/null || echo "bin/ NOT FOUND"
echo "=== END DEBUG ==="

# Create bin/ at current working directory
mkdir -p bin

# Copy xray from all possible locations
cp /usr/local/bin/xray-core bin/xray-linux-amd64 2>/dev/null || \
cp /usr/local/bin/xray bin/xray-linux-amd64 2>/dev/null || \
cp /usr/bin/xray bin/xray-linux-amd64 2>/dev/null || \
cp /root/bin/xray-linux-amd64 bin/xray-linux-amd64 2>/dev/null || true

chmod +x bin/xray-linux-amd64 2>/dev/null || true

echo "bin/ contents:"
ls -la bin/ 2>/dev/null

# Start x-ui
exec x-ui
