# Bobra Docker
Dockerfile and resources for Bobra docker base images.

## Requirements
Images are published as multi-arch (`linux/amd64` + `linux/arm64`) manifest lists,
so the same tag works on x86 servers and on Apple Silicon. This needs a one-time
setup on the build machine:
```bash
# QEMU emulation for foreign architectures
docker run --privileged --rm tonistiigi/binfmt --install arm64
# builder able to handle more than one platform
docker buildx create --name bobra --driver docker-container --bootstrap
```
The `tonistiigi/binfmt` registration is lost on reboot. Install `qemu-user-static`
and `qemu-user-static-binfmt` from the distribution repositories to make it stick.

## Building
Build all projects
```bash
./build
# or build & publish
PUBLISH=1 ./build
```
Build specified project
```bash
./build backend
```
Without `PUBLISH`, only the host architecture is built and the image is loaded
into the local docker store. With `PUBLISH`, every architecture is built and
pushed straight to the registry - a multi-arch image cannot exist locally, so
nothing is left behind on the build machine.

Building `linux/arm64` on an x86 host runs under emulation and is roughly 10-20x
slower than native.

### Options
| Variable | Default | Description |
| --- | --- | --- |
| `PUBLISH` | unset | Build every architecture and push. `force` republishes an existing tag. |
| `PLATFORMS` | `linux/amd64,linux/arm64` | Architectures to publish. Overridden per image by `platforms` in its `meta.json`. |
| `BUILDER` | `bobra` | Buildx builder to use. |
| `CPU_MARCH_AMD64` | `x86-64-v3` | Baseline x86 instruction set for nginx. |
| `CPU_MARCH_ARM64` | `armv8-a` | Baseline arm64 instruction set for nginx. |
| `CPU_FLAGS` | unset | Replaces both baselines, e.g. `-march=native` for a single-host build. |

Note that `-march=native` produces an image that only runs on the CPU that built
it, which is why it is not the default.

## Contents
- [php](./php) - PHP Image for Bobra Backend
- [nginx](./nginx) - Nginx Image using php-fpm for Bobra Backend
- [php-composer](./php/composer) - PHP Composer Image for dependencies installation using stage builds 

## Author
- [Alexander <Horat1us> Letnikow](mailto:reclamme@gmail.com)

## License
Proprietary
