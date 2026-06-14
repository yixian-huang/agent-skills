# `container` Troubleshooting Guide

## Service will not start

### Symptom: `No default kernel configured`

`container system start` prompts for kernel installation but hangs in non-interactive shells.

**Fix:**

```bash
container system start --enable-kernel-install
```

This installs the default Kata Containers kernel automatically.

### Symptom: `failed to read user input`

The start command requires a TTY for the kernel install prompt.

**Fix:** use `--enable-kernel-install` or `--disable-kernel-install` to avoid the prompt.

### Symptom: `apiserver` not responding

Check status:

```bash
container system status
```

Restart the service:

```bash
container system stop
container system start --enable-kernel-install
```

## Container cannot be reached from host

1. Confirm the container IP:

   ```bash
   container ls
   ```

2. Inside the container, bind the service to `0.0.0.0`, not `127.0.0.1`.
3. From the host, use the container IP (e.g., `http://192.168.64.3`).
4. If a local DNS domain is configured, use `<container-name>.<domain>`.

## DNS name does not resolve

1. Verify the domain was created:

   ```bash
   sudo container system dns create test
   ```

2. Check `/etc/resolver/` contains a file for the domain.
3. Ensure the container name matches the hostname exactly.
4. DNS resolution may require a brief delay after container start.

## Build fails or is slow

1. Confirm `container system status` shows `running`.
2. The first build pulls the base image and may be slow.
3. Ensure the build context (the `.` argument) contains the Dockerfile and needed files.
4. For network issues, verify registry access:

   ```bash
   container image pull docker.io/hello-world
   ```

## Image push fails

1. Log in first:

   ```bash
   container registry login <registry-domain>
   ```

2. Tag the image with the full registry path:

   ```bash
   container image tag my-app <registry-domain>/<user>/<repo>:<tag>
   ```

3. Check the default registry in `~/.config/container/config.toml` if you expect Docker Hub.

## General diagnostic checklist

1. `which container` — CLI installed?
2. `container --version` — which version?
3. `container system status` — service running?
4. `container list --all` — any stuck containers?
5. `container image list` — expected images present?
6. Run `bash <skill-path>/scripts/health-check.sh` for an end-to-end smoke test.
