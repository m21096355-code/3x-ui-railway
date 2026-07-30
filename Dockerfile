FROM ghcr.io/mhsanaei/3x-ui:latest

RUN apk add --no-cache curl jq bash

# Save real x-ui binary
RUN cp /app/x-ui /app/x-ui.real

# Create wrapper that creates inbound on startup
COPY wrapper.sh /app/x-ui
RUN chmod +x /app/x-ui
