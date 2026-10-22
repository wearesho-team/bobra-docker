# PHP Debug Image

Same configuration as bobra/php but enabled Xdebug

There is no separate Dockerfile: this image is the `debug` stage of
[php/Dockerfile](../Dockerfile) (see `dockerfile` and `target` in `meta.json`).
It is built on top of the same PHP compile as bobra/php, so changes there apply
to both images. Only `xdebug.ini`, `php.ini` and `php-fpm.conf` live here.

## Usage

### PhpStorm Configuration

- Go to Settings
- Open PHP -> Servers
- Create new server, add path mappings, set name

### Docker Compose configuration

Use `bobra/php:X.Y.Z-debug` as image
Add environment section:
```
    environment:
      - XDEBUG_CLIENT_PORT=9001
      - XDEBUG_CLIENT_HOST=172.17.0.1
      - PHP_IDE_CONFIG=serverName=projectName
```

- change XDEBUG_CLIENT_HOST if you use not linux system
- change projectName in  PHP_IDE_CONFIG variable to project name you set in PhpStorm server configuration

## Maintainers info

Xdebug installation instruction: [Xdebug Wizard](https://xdebug.org/wizard)

