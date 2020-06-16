# Bobra Docker
Dockerfile and resources for Bobra docker base images.

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

## Contents
- [php](./php) - PHP Image for Bobra Backend
- [nginx](./nginx) - Nginx Image using php-fpm for Bobra Backend
- [php-composer](./php/composer) - PHP Composer Image for dependencies installation using stage builds 

## Author
- [Alexander <Horat1us> Letnikow](mailto:reclamme@gmail.com)

## License
Proprietary
