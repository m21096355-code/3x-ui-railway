#!/bin/sh
# Start3x-ui in background
/app/x-ui &

# Wait for panel to be ready
echo "Waiting for panel on port 2054..."
for i in $(seq 1 30); do
  if curl -s http://localhost:2054/ > /dev/null 2>&1; then
    echo "Panel ready!"
    break
  fi
  sleep 2
done

sleep 3

# Get CSRF token
CSRF=$(curl -s -c /tmp/r3x.txt "http://localhost:2054/" 2>&1 | grep -oP 'csrf-token" content="\K[^"]+')

# Login
curl -s -X POST "http://localhost:2054/login" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-TOKEN: $CSRF" \
  -d '{"username":"admin","password":"admin"}' \
  -b /tmp/r3x.txt -c /tmp/r3x.txt > /dev/null 2>&1

# Get new CSRF
CSRF2=$(curl -s "http://localhost:2054/panel/" -b /tmp/r3x.txt -c /tmp/r3x.txt 2>&1 | grep -oP 'csrf-token" content="\K[^"]+')

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

echo "Inbound creation: $RESULT"

# Keep container alive by waiting for x-ui process
wait
