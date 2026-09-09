---
name: tnt-dockerize-dry-project
description: Migrate a legacy T&T dry/Oak PHP project from Vagrant to Docker, keeping its original PHP version and using a symlink to the local dry package instead of the composer one. Use when the user wants to "dockerize" a dry project, replace a Vagrantfile with docker-compose, or mentions dry-docker, dry-base, tnt-reverse-proxy or "make it run in Docker" for a T&T site.
---

# Dockerizing a legacy dry project

Replaces a `Vagrantfile` + `dry-shell-provision` setup with `docker-compose.yml` + a `Makefile`, using the shared [dry-docker](https://github.com/TallieuTallieu/dry-docker) image and Traefik from `tnt-reverse-proxy`.

## First: which kind of dry project is this?

| | Legacy dry (this skill) | Modern dry3 (`dry-base`) |
| --- | --- | --- |
| `index.php` | `require_once 'dry/init.inc.php'` | composer autoload only |
| `dry` | symlink to `../dry/src/dry` | `vendor/tallieutallieu/dry/src/dry` |
| Docroot | project root | `public/` |
| dry-docker branch | `php7.2` / `php7.4` / `php8.2` | `php8.4` + `APACHE_DOCUMENT_ROOT` arg |

If `index.php` starts with `require_once 'dry/init.inc.php'`, you are in the legacy case: the app uses the **local** `../dry` checkout, not the composer package. Never replace that symlink with `tallieutallieu/dry`.

## Prerequisites the project depends on

The compose file mounts siblings by relative path, so the project must sit next to its dependencies:

```
tnt/
├── center/              # dry development center, provides the `dry` database UI
├── dry/                 # the local dry package (src/dry, src/bin)
├── tnt-reverse-proxy/   # Traefik + the shared external `dev` network
└── <project>/
```

`tnt-reverse-proxy` must be up (`docker compose up -d` in it), because every project's compose file joins its `dev` network as `external: true`.

**In a git worktree**, `../dry` and `../center` will not exist. Symlink them into the worktree's parent directory before starting, or run from the main checkout.

## Steps

### 1. Pick the PHP version

The Vagrantfile provisions with `dry-shell-provision/setup.sh`; read its `installPHP` function to see which PHP the project actually ran on. Match that to a dry-docker branch:

```
build: https://github.com/TallieuTallieu/dry-docker.git#php7.4
```

Branches: `php7.2`, `php7.4`, `php8.2`, `php8.4`, `main`. Tags (`#1.1.7`) pin an exact Dockerfile.

Keep the old PHP version. Bumping PHP on a legacy dry project is a separate, much larger job.

### 2. `docker-compose.yml`

Four services, named `<project>-adminer`, `-db`, `-center`, `-site`. Copy the file from a sibling project already on the same PHP branch (`koeketiene`, `musicmania-php7`, `tao`) and replace the project name. The parts that matter:

```yaml
networks:
  dev:
    external: true

services:
  <project>-db:
    image: mariadb:10.11.3          # mysql:8.0.34 for the modern dry3 stack
    volumes:
      - ./docker/db_init:/docker-entrypoint-initdb.d:ro
      - ./docker/db:/var/lib/mysql
    command: --sql-mode=ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION

  <project>-site:
    build: https://github.com/TallieuTallieu/dry-docker.git#php7.4
    hostname: docker_app
    volumes:
      - .:/var/www/html
      - ../dry:/var/www/dry              # required: dry's bin/ is on PATH in the image
      - ./docker/xdebug/xdebug.ini:/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini:ro
      - ./docker/xdebug/error_reporting.ini:/usr/local/etc/php/conf.d/error_reporting.ini:ro
      - ./docker/xdebug/log:/tmp/xdebug
      - ~/.ssh:/root/.ssh:ro
    command: ["sh", "-c", "eval `ssh-agent -s` && (ssh-add || true) && (composer install || true) && apache2ctl -D FOREGROUND"]
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.${APP_NAME}.entrypoints=http"
      - "traefik.http.routers.${APP_NAME}.rule=Host(`${APP_NAME}.localhost`)"
    networks:
      - dev
```

Router label names must be unique across all projects on the `dev` network, hence the `a`/`c` prefixes on adminer and center (`a${APP_NAME}`, `c${APP_NAME}`).

### 3. `docker/` scaffolding

```
docker/
├── db/.gitkeep              # mysql data volume, gitignored
├── db_dump/.gitkeep         # target for `make sync-db`, gitignored
├── db_init/
│   ├── 00_0_init.sql        # root@localhost + root@'%' grants
│   ├── 00_1_center_init.sql # CREATE DATABASE dry + center schema + seed user
│   └── 01_app_init.sql      # CREATE DATABASE app
└── xdebug/
    ├── xdebug.ini
    ├── error_reporting.ini
    └── log/.gitkeep
```

Copy `db_init/` verbatim from a sibling project. The `dry` database is not optional: `dry\admin\User` has `const CONNECTION = 'dry'` and `dry\admin\Session::login()` runs `SELECT * FROM dry.user`, a cross-database query on the same server. Without `00_1_center_init.sql` the backend login is dead.

`xdebug.ini`:

```ini
zend_extension=xdebug

[xdebug]
xdebug.client_port=9003
xdebug.mode=develop,debug
xdebug.client_host=host.docker.internal
xdebug.start_with_request=yes
xdebug.idekey = docker
xdebug.output_dir = "/tmp/xdebug"
xdebug.log = "/tmp/xdebug/xdebug-log.log"
```

### 4. Symlinks to the local dry

```sh
ln -s ../dry/src/dry ./dry
ln -s ../../dry/src/dry/js js/dry
ln -s ../../dry/src/dry/style style/dry
```

Keep them **relative**. On the host `./dry` resolves to `../dry/src/dry`; inside the container the same relative link resolves to `/var/www/dry/src/dry`, which is the mount. An absolute symlink works in exactly one of the two places. They are gitignored, so the Makefile recreates them (`make setup-symlink`).

### 5. `.env`

`Oak\Application`'s constructor loads `.env` through Dotenv before any config is read, and `config/app.php` reads it with `getenv()`. Compose reads the same file for `${APP_NAME}`.

```
APP_NAME=project_name
APP_HTTP_HOST=project_name.localhost
APP_HTTP_ROOT=/                    # was /default/ under Vagrant
APP_DB_HOST=project_name-db        # the compose service name, not localhost

SSH_SERVER=
SSH_USER=
SSH_ROOT=
PROD_DB=
PROD_DB_USER=
PROD_DB_PASS=
```

`APP_NAME` is new; the Vagrant-era `.env.example` will not have it.

If the project has no `.env` support at all (older projects read constants directly), install `vlucas/phpdotenv` and load it at the top of `app/configuration/main.inc.php` before adding the keys.

### 6. `Makefile`

Copy `../dry-base/Makefile` (canonical, has `make update-makefile` to refresh it later) or the smaller one from `locas2021`. It wraps everything in `docker compose exec <APP_NAME>-site`: `docker`, `docker-exec`, `dev`, `build`, `deploy`, `oak`, `sync-db`, `sync-media`, `ssh`.

Two guards worth keeping in `docker-init`: start Docker Desktop if it is not running, and `docker network create dev` if the network is missing.

### 7. `.gitignore`

```
/docker/db/**
!/docker/db/.gitkeep
/docker/db_dump/**
!/docker/db_dump/.gitkeep
/docker/xdebug/log/**
!/docker/xdebug/log/.gitkeep
```

Drop `/.vagrant`. **Un-ignore `composer.lock`** (see below).

### 8. Delete the Vagrantfile and rewrite the README

`dry-deploy.json`'s `upload-files` task already excludes `docker`, `.env` and `dry`, so nothing else needs changing for deploys.

## Pitfalls that will bite you

**`composer install` fails on `tallieutallieu/dry` "could not be found".** A dependency (typically `tallieutallieu/dry-redirects: dev-master`) has moved on to the dry3 era and now requires `tallieutallieu/dry ^3|^4` plus `dry-dbi 3.*`, which needs PHP 8.1+. On a legacy PHP 7.4 project the fix is to pin the dependency to its last dry-v1 compatible tag (for dry-redirects that is `^1.0`; check `git show <tag>:composer.json` in the package's local clone). Adding `"provide": {"tallieutallieu/dry": "4.0.0"}` gets past the missing-package error but not past the PHP 8 requirement underneath, so it is rarely the real answer.

**`composer.lock` is gitignored in these projects.** That is exactly why the above happens: `dev-master` constraints silently drift. Remove it from `.gitignore` and commit the lock as part of dockerizing, otherwise the container that builds today will not build next month.

**`ssh-add` breaks the startup chain.** The stock command is `eval \`ssh-agent -s\` && ssh-add && composer install && apache2ctl -D FOREGROUND`. With no key, a passphrase-protected key, or a composer failure, the `&&` chain aborts and **Apache never starts** while the container still reports healthy. Wrap the fragile steps: `(ssh-add || true) && (composer install || true) && apache2ctl -D FOREGROUND`.

**`.node-version` is mandatory.** The image installs node through nodenv and sets no global version, so every `node`/`npm`/`yarn` shim fails without it. Pick a version the Dockerfile actually installed (`10.24.1`, `12.22.12`, `14.21.3`, `16.20.1`, `18.16.1`, `20.11.1`, `22.14.0`, and `24.18.0` on `main`). Note corepack (and therefore yarn) is only enabled from 16.20.1 up: on node 14 you must use npm.

**`dry-deploy.json` predeploy tasks run locally, inside the container**, via `system()`. Vagrant-era entries like `sudo npm install` fail because the image has no `sudo` and already runs as root. Strip the `sudo`.

**Traefik shares port 80 with Valet.** `tnt-reverse-proxy` listens on `127.0.0.1:8880` and Valet forwards `*.localhost` to it, so a project unreachable at `project.localhost` is usually a Valet config problem, not a compose one.

## Verify it works

```sh
docker compose config                       # compose file parses
docker compose up -d --build
docker compose logs <project>-site          # composer resolved, Apache started
docker compose exec <project>-site sh -c 'php -v; node -v; which dry'
docker compose exec <project>-db mysql -uroot -proot -e "show databases;"   # app AND dry
curl -s -o /dev/null -w "%{http_code}\n" http://<project>.localhost/
docker compose exec <project>-site php oak  # oak CLI boots
```

A `dry\db\Exception: Table 'app.<x>' doesn't exist` on the homepage is a **success signal** at this stage: PHP, the `.htaccess` rewrite, the dry symlink and the database connection all work, and the database is simply empty. Run `make sync-db` to pull production data.
