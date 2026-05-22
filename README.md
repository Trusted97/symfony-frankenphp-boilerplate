# Symfony EasyAdmin Boilerplate
![Symfony](https://img.shields.io/badge/Symfony-7.4-black?logo=symfony)
![PHP](https://img.shields.io/badge/PHP-8.4-777BB4?logo=php&logoColor=white)
![EasyAdmin](https://img.shields.io/badge/EasyAdmin-5-blue)
![Docker](https://img.shields.io/badge/Docker-ready-2496ED?logo=docker&logoColor=white)
![FrankenPHP](https://img.shields.io/badge/FrankenPHP-enabled-000000)
![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)
![Webpack](https://img.shields.io/badge/Webpack-Encore-8DD6F9?logo=webpack&logoColor=black)
![License](https://img.shields.io/badge/license-MIT-green)

Minimal Symfony 7.4 boilerplate with FrankenPHP, Docker, MySQL, Webpack Encore, and EasyAdmin.

## Stack

- PHP 8.4
- Symfony 7.4
- EasyAdmin 5
- Doctrine ORM and Migrations
- FrankenPHP / Caddy
- MySQL 8
- Yarn and Webpack Encore

## Setup

```bash
composer install
yarn install
docker compose up -d --build
docker compose exec php bin/console doctrine:migrations:migrate --no-interaction
```

Open:

- App: `https://localhost`
- Admin: `https://localhost/admin`

## Production

Create `.env.deploy` from `.env.deploy.example`, fill secrets and domain values, then run:

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

Useful commands:

```bash
docker compose logs -f php
docker compose exec php bin/console doctrine:migrations:migrate --no-interaction
docker compose exec php bin/console cache:clear
```

## Development

Run tests:

```bash
composer test
```

Run static analysis:

```bash
composer phpstan
```

Build assets:

```bash
yarn build
```

## Boilerplate Contents

The app contains one generic EasyAdmin-ready entity:

- `SampleEntity`
  - `id`
  - `name`
  - `createdAt`
  - `updatedAt`

Extend the app by adding new entities, repositories, migrations, and EasyAdmin CRUD controllers following the same structure.
