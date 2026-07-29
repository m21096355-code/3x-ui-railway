#!/bin/sh
echo "CWD=$(pwd)"
echo "HOME=$HOME"
ls -la bin/ 2>&1 || echo "NO bin/ at CWD"
# Create bin/ at CWD
mkdir -p "$(pwd)/bin"
cp /app/bin/xray-linux-amd64 "$(pwd)/bin/xray-linux-amd64" 2>/dev/null
cp /app/geoip.dat "$(pwd)/" 2>/dev/null
cp /app/geosite.dat "$(pwd)/" 2>/dev/null
ls -la "$(pwd)/bin/"
exec /app/x-ui
