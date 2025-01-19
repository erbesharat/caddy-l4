FROM golang:1.20 AS builder

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@latest

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN xcaddy build master \
    --output /caddy \
    --with github.com/mholt/caddy-l4=/app

FROM alpine:3.18

LABEL org.opencontainers.image.source="github.com/erbesharat/caddy-l4"
LABEL org.opencontainers.image.description="Caddy server with the L4 plugin"
LABEL org.opencontainers.image.licenses="Apache-2.0"

COPY --from=builder /caddy /usr/bin/caddy

ENTRYPOINT ["/usr/bin/caddy"]
CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
