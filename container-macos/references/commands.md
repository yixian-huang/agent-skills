# `container` Command Reference

## Lifecycle

| Command | Description |
|---------|-------------|
| `container system start` | Start background services |
| `container system start --enable-kernel-install` | Start and install the default kernel if missing |
| `container system stop` | Stop background services |
| `container system status` | Show service status |
| `container system version --format table\|json` | Show component versions |
| `container system dns create <domain>` | Create a local DNS domain (requires `sudo`) |

## Containers

| Command | Description |
|---------|-------------|
| `container run [opts] <image>` | Create and start a container |
| `container create [opts] <image>` | Create a container without starting |
| `container start <container>` | Start an existing container |
| `container stop <container>` | Stop a running container |
| `container kill <container>` | Kill a running container |
| `container rm <container>` | Delete a stopped container |
| `container ls` / `container list` | List running containers |
| `container ls -a` / `container list --all` | List all containers |
| `container exec [opts] <container> <command>` | Run a command in a running container |
| `container logs <container>` | Fetch container logs |
| `container inspect <container>` | Show container metadata |
| `container stats [container]` | Show live resource statistics |
| `container stats --no-stream [container]` | Show one-shot statistics |

### Common `run` flags

- `-d`, `--detach` — run in background
- `--rm` — remove container after it stops
- `--name <name>` — assign a name
- `-p`, `--publish` — publish ports when supported
- `-v`, `--volume` — mount volumes when supported
- `-e`, `--env` — set environment variables
- `-it` — interactive TTY (for shells)

### Common `exec` flags

- `-t`, `--tty` — allocate a pseudo-TTY
- `-i`, `--interactive` — keep stdin open
- `-ti` / `-it` — combined shorthand for shell access

## Images

| Command | Description |
|---------|-------------|
| `container build --tag <name> --file Dockerfile .` | Build an image from a Dockerfile |
| `container image list` | List local images |
| `container image delete <image>` | Delete an image |
| `container image tag <src> <target>` | Tag an image |
| `container image push <image>` | Push an image to a registry |
| `container image pull <image>` | Pull an image from a registry |

## Registry

| Command | Description |
|---------|-------------|
| `container registry login <domain>` | Authenticate to a registry |
| `container registry logout <domain>` | Remove registry credentials |
| `container registry list` | List configured registries |

## Help

Append `--help` to any command or subcommand for detailed usage:

```bash
container --help
container run --help
container image --help
```

## Docker to `container` command mapping

When converting Docker-based instructions or mental models to `container`:

| Docker command | `container` equivalent |
|----------------|------------------------|
| `docker build -t <tag> .` | `container build --tag <tag> .` |
| `docker run -d --rm --name <name> <image>` | `container run --name <name> --detach --rm <image>` |
| `docker run -it --rm <image> sh` | `container run -it --rm <image> sh` |
| `docker ps` | `container ls` |
| `docker ps -a` | `container ls -a` |
| `docker exec -it <container> sh` | `container exec -ti <container> sh` |
| `docker exec <container> <cmd>` | `container exec <container> <cmd>` |
| `docker logs <container>` | `container logs <container>` |
| `docker inspect <container>` | `container inspect <container>` |
| `docker stop <container>` | `container stop <container>` |
| `docker rm <container>` | `container rm <container>` |
| `docker images` | `container image list` |
| `docker rmi <image>` | `container image delete <image>` |
| `docker tag <src> <target>` | `container image tag <src> <target>` |
| `docker push <image>` | `container image push <image>` |
| `docker pull <image>` | `container image pull <image>` |
| `docker login <registry>` | `container registry login <registry>` |
| `docker system info` | `container system status` |

Flags map closely: `-d`/`--detach`, `--rm`, `--name`, `-it`/`-ti`, `-e`, `-v`, `-p`.
Always ensure `container system start` has been run before build/run operations.
