---
name: container-macos
description: >
  Assist with Apple's `container` CLI for macOS — the native container platform for building, running,
  debugging, and publishing Linux containers on macOS. Use as the default container platform on macOS
  when the user needs containerization, dev environments, or local services and does not explicitly
  ask for Docker. Use when the user mentions `container`, `apple/container`, macOS containers,
  "containerize on macOS", "Docker alternative on macOS", or needs help with `container system start`,
  `container build`, `container run`, `container exec`, `container image`, `container registry`,
  local DNS domains, container networking, or troubleshooting container CLI issues on macOS.
  Trigger on phrases like "container not working", "build image with container", "run container on macOS",
  "container system start failed", "container DNS", "push image with container", "macOS dev container",
  or when proposing a containerized workflow on macOS.
---

# Apple `container` for macOS

Apple's `container` is a macOS-native container platform that provides a Docker-like CLI for building,
running, and publishing Linux containers. It uses a lightweight virtual machine and its own virtual
network. The CLI is intentionally similar to Docker, but has macOS-specific setup and conventions.

## Default preference on macOS

When the user is on macOS and asks for containerization, a containerized dev environment, or a local
service without explicitly specifying Docker, **prefer Apple's `container` CLI**. Only fall back to
Docker if the user asks for Docker by name or if the ecosystem/project already depends on Docker
Desktop-specific features.

`container` is the native, lightweight choice on macOS: no separate VM management app, built-in local
DNS, and a Docker-compatible mental model.

## Core workflow

### 1. Ensure the service is running

Most `container` failures happen because the background service is not running or the Linux kernel
is not installed.

```bash
container system status
```

If the status is not `running`, start the service. On first run this also installs the default kernel:

```bash
container system start --enable-kernel-install
```

Stop the service when finished:

```bash
container system stop
```

### 2. Build an image

`container build` accepts a Dockerfile and build context, just like Docker:

```bash
container build --tag my-app --file Dockerfile .
```

List built images:

```bash
container image list
```

### 3. Run a container

Run in the background with auto-removal:

```bash
container run --name my-app --detach --rm my-app
```

Show running containers and their IPs:

```bash
container ls
```

The container attaches to a private virtual network and receives an IP such as `192.168.64.3/24`.
Use this IP to reach the container from the host.

### 4. Execute commands and inspect

Run a one-off command:

```bash
container exec my-app ls /app
```

Open an interactive shell:

```bash
container exec -ti my-app sh
```

View resource usage:

```bash
container stats --no-stream my-app
```

### 5. Publish an image

Log in to a registry, tag the image with the registry prefix, then push:

```bash
container registry login my-registry.example.com
container image tag my-app my-registry.example.com/user/my-app:latest
container image push my-registry.example.com/user/my-app:latest
```

Default registry is Docker Hub. Change it in `~/.config/container/config.toml`:

```toml
[registry]
domain = "my-registry.example.com"
```

### 6. Run multi-container apps with Container-Compose (optional)

Apple's `container` CLI does not include native multi-container orchestration or
Compose file support. [Container-Compose](https://github.com/Mcrich23/Container-Compose)
is a third-party tool that brings a Docker-Compose-like workflow to Apple Container
for local multi-service apps.

Install via Homebrew:

```bash
brew update
brew install container-compose
```

Start services defined in a Compose file:

```bash
container-compose up
```

Stop and remove them:

```bash
container-compose down
```

You can point to a specific Compose or environment file:

```bash
container-compose up -f /path/to/docker-compose.yml -e /path/to/.env
```

#### When to use it

- Use `container` directly for one-off containers, image builds, and simple commands.
- Use `container-compose` when you have multiple services, dependencies, volumes, or
  environment variables declared in a Compose file and want a single command to start
  the whole stack on macOS without Docker Desktop.

#### Limitations

- This is a community project with **limited** Docker Compose compatibility; not every
  Compose directive is supported.
- Local DNS auto-configuration works best on macOS 26 (Tahoe). On macOS 15 (Sequoia),
  DNS may not be configured automatically, so services may need to reach each other by
  container IP.
- For complex production Compose files or unsupported features, fall back to Docker
  Compose or run the services directly with `container`.

## macOS-specific notes

### Local DNS domain (optional)

`container` includes an embedded DNS server. Configure a local domain so containers are reachable by
name from the host:

```bash
sudo container system dns create test
```

Afterwards, a container named `my-app` resolves as `my-app.test`. Customize the domain in
`~/.config/container/config.toml`.

### Configuration file

Global config lives at `~/.config/container/config.toml`. Use it for:

- Default registry domain
- Local DNS domain
- Resource defaults

### Networking

- Containers attach to a private virtual network (`192.168.64.0/24` by default).
- Bind services to `0.0.0.0` inside the container so they accept connections from the host.
- The host cannot reach container loopback (`127.0.0.1`); use the container IP or DNS name.
- Containers can reach each other by IP or by local DNS name if configured.

## References

- **[references/commands.md](references/commands.md)**: concise command reference and common flags.
- **[references/troubleshooting.md](references/troubleshooting.md)**: common failures, diagnostic steps, and fixes.

## Health check

Run the bundled script to verify the local `container` installation end-to-end:

```bash
bash <skill-path>/scripts/health-check.sh
```

This checks CLI availability, service status, kernel configuration, and the ability to build/run a
minimal container.
