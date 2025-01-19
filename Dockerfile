# ----------- Build stage -----------
FROM golang:1.20 AS builder

# Install xcaddy
RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

# Work inside /app
WORKDIR /app

# Bring in go.mod, go.sum first to cache modules
COPY go.mod go.sum ./
RUN go mod download

# Now copy the rest of the source
COPY . .

# Build Caddy with the L4 module
RUN xcaddy build master \
    --output /caddy \
    --with github.com/mholt/caddy-l4=/app

# ----------- Final stage -----------
FROM alpine:3.18

# Labels (optional but recommended for OCI compliance)
LABEL org.opencontainers.image.source="github.com/erbesharat/caddy-l4"
LABEL org.opencontainers.image.description="Caddy server with the L4 plugin"
LABEL org.opencontainers.image.licenses="Apache-2.0"

# Copy the final Caddy binary into a minimal image
COPY --from=builder /caddy /usr/bin/caddy

# Default entrypoint and command
ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
