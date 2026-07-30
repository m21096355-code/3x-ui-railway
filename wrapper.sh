#!/bin/sh
# Start real x-ui in background
/app/x-ui.real &
XUI_PID=$!

# Wait for panel on XUI_PORT (default 2053)
PORT=${XUI_PORT:-2053}
echo "Waiting for panel on port $PORT..."
for i in $(seq 1 60); do
  if curl -s "http://localhost:$PORT/" > /dev/null 2>&1; then
    echo "Panel ready!"
    break
  fi
  sleep 2
done

sleep 3

# Get CSRF
CSRF=$(curl -s -c /tmp/3x.txt "http://localhost:$PORT/" 2>&1 | grep -oP 'csrf-token" content="\K[^"]+')

# Login
curl -s -X POST "http://localhost:$PORT/login" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-TOKEN: $CSRF" \
  -d '{"username":"admin","password":"admin"}' \
  -b /tmp/3x.txt -c /tmp/3x.txt > /dev/null 2>&1

sleep 2

# Get new CSRF from panel
CSRF2=$(curl -s "http://localhost:$PORT/panel/" \
  -b /tmp/3x.txt -c /tmp/3x.txt 2>&1 | grep -oP 'csrf-token" content="\K[^"]+')

# Delete any existing inbound on port 2053
curl -s "http://localhost:$PORT/panel/api/inbounds/list" \
  -H "X-CSRF-TOKEN: $CSRF2" \
  -H "X-Requested-With: XMLHttpRequest" \
  -b /tmp/3x.txt 2>&1 | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for item in data.get('obj', []):
        print(f'Delete: {item[\"id\"]}')
except: pass
" 2>/dev/null | while read line; do
    ID=$(echo $line | grep -oP '\d+')
    curl -s -X POST "http://localhost:$PORT/panel/api/inbounds/del/$ID" \
      -H "X-CSRF-TOKEN: $CSRF2" \
      -H "X-Requested-With: XMLHttpRequest" \
      -b /tmp/3x.txt > /dev/null 2>&1
done

sleep 1

# Create VLESS inbound on port 2053 with security:none (Railway handles TLS)
curl -s -X POST "http://localhost:$PORT/panel/api/inbounds/add" \
  -H "Content-Type: application/json" \
  -H "X-CSRF-TOKEN: $CSRF2" \
  -H "X-Requested-With: XMLHttpRequest" \
  -d '{"up":0,"down":0,"total":0,"remark":"VLESS-NL","enable":true,"expiryTime":0,"listen":"","port":2053,"protocol":"vless","settings":"{\"clients\":[{\"id\":\"1116293d-1d9b-d90d-d9bd-5b9184e5f8f8\",\"flow\":\"xtls-rprx-vision\",\"email\":\"xbzuser\",\"limitIp\":0,\"totalGB\":0,\"expiryTime\":0,\"enable\":true}],\"decryption\":\"none\",\"fallbacks\":[]}",
"streamSettings":"{\"network\":\"ws\",\"security\":\"none\",\"wsSettings\":{\"headers\":{\"Host\":\"www.google.com\"},\"path\":\"/ws\"}}",
"sniffing":"{\"enabled\":true,\"destOverride\":[\"http\",\"tls\"],\"routeOnly\":true}","tag":"VLESS-NL"}' \
  -b /tmp/3x.txt 2>&1 | head -c 200

echo ""
echo "=== INBOUND CREATED ==="

# Keep running - wait for x-ui process
wait $XUI_PID
