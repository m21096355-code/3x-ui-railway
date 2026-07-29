#!/bin/sh
# Start3x-ui in background
/app/x-ui &
XUI_PID=$!

# Wait for panel to be ready on port 2054
echo "Waiting for panel on port 2054..."
for i in $(seq 1 60); do
  if curl -s http://localhost:2054/ > /dev/null 2>&1; then
    echo "Panel ready after ${i} attempts!"
    break
  fi
  sleep 2
done

sleep 5

# Get CSRF token
CSRF=$(curl -s -c /tmp/r3x.txt "http://localhost:2054/" 2>&1 | grep -oP 'csrf-token" content="\K[^"]+')
echo "CSRF: ${CSRF:0:20}..."

# Login
curl -s -X POST "http://localhost:2054/login" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-TOKEN: $CSRF" \
  -d '{"username":"admin","password":"admin"}' \
  -b /tmp/r3x.txt -c /tmp/r3x.txt > /dev/null 2>&1

sleep 2

# Get new CSRF from panel
CSRF2=$(curl -s "http://localhost:2054/panel/" -b /tmp/r3x.txt -c /tmp/r3x.txt 2>&1 | grep -oP 'csrf-token" content="\K[^"]+')
echo "CSRF2: ${CSRF2:0:20}..."

# Check existing inbounds
EXISTING=$(curl -s "http://localhost:2054/panel/api/inbounds/list" \
  -H "X-CSRF-TOKEN: $CSRF2" \
  -H "X-Requested-With: XMLHttpRequest" \
  -b /tmp/r3x.txt 2>&1)
echo "Existing inbounds: $EXISTING" | head -c 200

# Create VLESS inbound on port 2053
RESULT=$(curl -s -X POST "http://localhost:2054/panel/api/inbounds/add" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-TOKEN: $CSRF2" \
  -H "X-Requested-With: XMLHttpRequest" \
  -d '{
    "up":0,"down":0,"total":0,
    "remark":"VLESS-NL",
    "enable":true,"expiryTime":0,
    "listen":"",
    "port":2053,
    "protocol":"vless",
    "settings":"{\"clients\":[{\"id\":\"1116293d-1d9b-d90d-d9bd-5b9184e5f8f8\",\"flow\":\"xtls-rprx-vision\",\"email\":\"xbzuser\",\"limitIp\":0,\"totalGB\":0,\"expiryTime\":0,\"enable\":true}],\"decryption\":\"none\",\"fallbacks\":[]}",
    "streamSettings":"{\"network\":\"ws\",\"security\":\"tls\",\"tlsSettings\":{\"serverName\":\"www.google.com\",\"fingerprint\":\"chrome\"},\"wsSettings\":{\"headers\":{\"Host\":\"www.google.com\"},\"path\":\"/ws\"}}",
    "sniffing":"{\"enabled\":true,\"destOverride\":[\"http\",\"tls\"],\"routeOnly\":true}",
    "tag":"VLESS-NL"
  }' \
  -b /tmp/r3x.txt 2>&1)
echo "Inbound result: $RESULT" | head -c 300

# Keep container alive
wait $XUI_PID
