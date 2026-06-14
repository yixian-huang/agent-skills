#!/usr/bin/env bash
set -euo pipefail

# Health check script for Apple's `container` CLI on macOS.
# Verifies CLI availability, service status, kernel configuration, and the
# ability to build and run a minimal container.

CONTAINER_BIN="${CONTAINER_BIN:-container}"
TEST_IMAGE="container-health-check"
TEST_CONTAINER="container-health-check-c"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"; container stop "$TEST_CONTAINER" >/dev/null 2>&1 || true' EXIT

info() { printf '\033[1;34m[INFO]\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m[OK]\033[0m   %s\n' "$*"; }
warn() { printf '\033[1;33m[WARN]\033[0m %s\n' "$*"; }
fail() { printf '\033[1;31m[FAIL]\033[0m %s\n' "$*"; }

info "Checking container CLI..."
if ! command -v "$CONTAINER_BIN" >/dev/null 2>&1; then
    fail "container CLI not found in PATH"
    exit 1
fi
ok "container CLI found at $(command -v "$CONTAINER_BIN")"
"$CONTAINER_BIN" --version

echo
info "Checking container service status..."
if ! "$CONTAINER_BIN" system status >/dev/null 2>&1; then
    warn "container service is not running; attempting to start..."
    if ! "$CONTAINER_BIN" system start --enable-kernel-install; then
        fail "failed to start container service"
        exit 1
    fi
fi
ok "container service is running"

echo
info "Listing existing containers..."
"$CONTAINER_BIN" list --all || true

echo
info "Building a minimal smoke-test image..."
cat > "$TMP_DIR/Dockerfile" <<'EOF'
FROM docker.io/python:alpine
WORKDIR /content
RUN echo '<h1>container health check OK</h1>' > index.html
CMD ["python3", "-m", "http.server", "80", "--bind", "0.0.0.0"]
EOF

if ! "$CONTAINER_BIN" build --tag "$TEST_IMAGE" --file "$TMP_DIR/Dockerfile" "$TMP_DIR"; then
    fail "failed to build smoke-test image"
    exit 1
fi
ok "smoke-test image built"

echo
info "Running smoke-test container..."
if ! "$CONTAINER_BIN" run --name "$TEST_CONTAINER" --detach --rm "$TEST_IMAGE"; then
    fail "failed to run smoke-test container"
    exit 1
fi
ok "smoke-test container running"

echo
info "Waiting for service to be ready..."
sleep 3

echo
info "Fetching container IP..."
IP="$("$CONTAINER_BIN" ls | awk -v c="$TEST_CONTAINER" '$1 == c {print $6}' | sed 's|/.*||')"

if [[ -z "$IP" ]]; then
    fail "could not determine container IP"
    exit 1
fi
ok "container IP is $IP"

echo
info "Testing HTTP endpoint..."
if curl -fsS "http://$IP/" >/dev/null 2>&1; then
    ok "HTTP endpoint responds"
else
    warn "HTTP endpoint did not respond immediately; retrying once..."
    sleep 3
    if curl -fsS "http://$IP/" >/dev/null 2>&1; then
        ok "HTTP endpoint responds after retry"
    else
        fail "HTTP endpoint is not reachable at http://$IP/"
        exit 1
    fi
fi

echo
info "Testing container exec..."
if ! "$CONTAINER_BIN" exec "$TEST_CONTAINER" uname -a >/dev/null 2>&1; then
    fail "container exec failed"
    exit 1
fi
ok "container exec works"

echo
info "Testing container stats..."
"$CONTAINER_BIN" stats --no-stream "$TEST_CONTAINER" || true

echo
ok "All health checks passed. container is working correctly."
