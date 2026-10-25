# Bobra Docker
Dockerfile and resources for Bobra docker base images.

## Requirements
Images are published as multi-arch (`linux/amd64` + `linux/arm64`) manifest lists,
so the same tag works on x86 servers and on Apple Silicon. Building them needs a
`bobra` buildx builder that handles both architectures, set up once on the build
machine in one of the two ways below.

### Native builders (recommended for releases)
One machine per architecture, e.g. an x86 and a Graviton (arm64) EC2 instance.
buildx sends each platform to the node that runs it natively and merges the
results into one manifest list, so `./build` is used exactly as before, and the
arm64 build takes about as long as the amd64 one.

Each node only needs Docker and non-interactive SSH access (key auth, host key
already accepted) as a user in the `docker` group. `./build` keeps running on the
release machine: it sends the build context to the nodes, and pushes use the
release machine's `docker login`.
```bash
docker context create bobra-amd64 --docker host=ssh://builder@x86.example.com
docker context create bobra-arm64 --docker host=ssh://builder@arm64.example.com
docker buildx rm bobra  # if an emulation builder exists
docker buildx create --name bobra --node bobra-amd64 --platform linux/amd64 bobra-amd64
docker buildx create --name bobra --append --node bobra-arm64 --platform linux/arm64 bobra-arm64
docker buildx inspect --bootstrap bobra  # each node marks its platform with "*"
```
If the release machine is x86 itself, it can serve as the amd64 node: leave out
the `bobra-amd64` context (create that node without a context argument) and only
add the arm64 machine.

The build cache stays on the nodes' disks, so the instances can be stopped
between releases and started again for the next one.

### QEMU emulation
Without an arm64 machine, arm64 is emulated on the x86 host. This is roughly
10-20x slower than native: compiling PHP takes over an hour.
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

`php` and `php/debug` share one PHP compile per architecture through the
builder's cache: whichever of them is built second on the same builder only adds
its own layers on top.

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

## Updates
[Renovate](https://docs.renovatebot.com/) checks every pinned version once a
day ([workflow](.github/workflows/renovate.yml), [config](renovate.json)) and
keeps a "Dependency Dashboard" issue listing what it found:
- patch releases (PHP, composer, nginx, xdebug) and rebuilt base images (a new
  `composer` digest, a new ngx_brotli commit) get a PR right away;
- minor and major releases (PHP 8.6, Alpine 3.24, ...) wait on the dashboard
  until their checkbox is ticked;
- the actions and images used by the workflows are updated in one PR on
  Mondays, with releases at least a week old.

Each PR also gives the image its new tag and is built natively on amd64 and
arm64 by the [Build](.github/workflows/build.yml) workflow. Nothing is
published automatically: after merging, publish with `PUBLISH=1 ./build`.

Versions that are not in a `FROM` line are found through the `# renovate:`
comments in the Dockerfiles.

### Tags
`PUBLISH=1 ./build` skips an image whose tag is already published, so every
change to an image needs a new tag in its `meta.json`. `./sync` sets it, and
Renovate runs it on every update branch. After editing a Dockerfile or config
by hand, run it before committing:
```bash
./sync
```
An image whose files changed since the last commit gets the new upstream
version as its tag (nginx `1.31.4.2` -> `1.31.8`). If only something else
changed, it gets the next revision of its tag (`1.31.8` -> `1.31.8.1`). A tag
already changed by hand is kept. bobra/php and its `-debug` variant always get a
new tag together, and bobra/php-composer is tagged with the PHP version inside
the composer image. `./sync` also updates the sha256 of the xdebug tarball when
its version changes.

### Setup
Renovate pushes with a GitHub App token: PRs pushed with the workflow's own
`GITHUB_TOKEN` would not trigger the Build workflow.
1. Create a GitHub App with webhooks disabled and these repository
   permissions: Checks, Commit statuses, Contents, Issues, Pull requests and
   Workflows set to read and write (Metadata stays read-only).
2. Install it on this repository.
3. Add the app's Client ID as the `RENOVATE_CLIENT_ID` repository variable and
   one of its private keys as the `RENOVATE_PRIVATE_KEY` repository secret.
4. Run the Renovate workflow once by hand (Actions -> Renovate -> Run workflow)
   to create the Dependency Dashboard.

## Contents
- [php](./php) - PHP Image for Bobra Backend
- [nginx](./nginx) - Nginx Image using php-fpm for Bobra Backend
- [php-composer](./php/composer) - PHP Composer Image for dependencies installation using stage builds 

## Author
- [Alexander <Horat1us> Letnikow](mailto:reclamme@gmail.com)

## License
Proprietary
