# Uffizzi App  

**The primary REST API for creating and managing Previews**

While it provides a documented REST API for anyone to use, it's most valuable when used with the open-source [`uffizzi_cli`](https://github.com/UffizziCloud/uffizzi_cli).  

## Uffizzi Overview

Uffizzi is the Full-stack Previews Engine that makes it easy for your team to preview code changes before merging—whether frontend, backend or microserivce. Define your full-stack apps with a familiar syntax based on Docker Compose, then Uffizzi will create on-demand test environments when you open pull requests or build new images. Preview URLs are updated when there’s a new commit, so your team can catch issues early, iterate quickly, and accelerate your release cycles.  

[Learn more about full-stack previews and the broader goals of this project.](docs/continuous-previews.md)

## Getting started with Uffizzi  

The fastest and easiest way to get started with Uffizzi is via the fully hosted version available at https://uffizzi.com, which includes free plans for small teams and qualifying open-source projects.  

Alternatively, you can self-host Uffizzi via the open-source repositories available here on GitHub. The remainder of this README is intended for users interested in self-hosting Uffizzi or for those who are just curious about how Uffizzi works.

## Uffizzi Architecture  

Uffizzi consists of the following components:  

* Uffizzi App (this repository) - The primary REST API for creating and managing Previews  
* [Uffizzi Controller](https://github.com/UffizziCloud/uffizzi_controller) - A smart proxy service that handles requests from Uffizzi App to the Kubernetes API  
* [Uffizzi CLI](https://github.com/UffizziCloud/uffizzi_cli) - A command-line interface for Uffizzi App     
* [Uffizzi Dashboard](https://app.uffizzi.com) - A graphical user interface for Uffizzi App (not available for self-hosting)

To host Uffizzi yourself, you will also need the following external dependencies:  

 * Kubernetes (k8s) cluster  
 * Postgres database  
 * Redis cache  

## Controller Design  

This `uffizzi_app` acts as a REST API for [`uffizzi_cli`](https://github.com/UffizziCloud/uffizzi_app) and [`Uffizzi Dashboard`](https://app.uffizzi.com) interfaces. It requires [`uffizzi_controller`](https://github.com/UffizziCloud/uffizzi_controller) as a supporting service.

## Uffizzi App Environment Variables

- `RAILS_SECRET_KEY_BASE` - secret_key_base of Rails::Application
- `DATABASE_HOST` - the database hostname (default: 127.0.0.1)
- `DATABASE_USER` - the database username (default: postgres)
- `DATABASE_PASSWORD` - the database password
- `DATABASE_PORT` - the database port (default: 5432)
- `BUNDLE_PATH` - the location of gems for `bundle install` command (not required)
- `GEM_PATH` - the location where gems can be found (not required)
- `GEM_HOME` - where gems will be installed (not required)
- `RAILS_WORKERS_COUNT` - the number of `puma` workers (default: 18)
- `RAILS_THREADS_COUNT` - the number of `puma` threads (default: 5)
- `RAILS_PORT` - the `puma` port (default: 7000)
- `RAILS_ENV` - the rails environment (default: development)
- `SIDEKIQ_CONCURRENCY` - sidekiq concurrency (default: 5)
- `ALLOWED_HOSTS` - allowed hosts for rails app used for Rack::Cors (default: [])
- `APP_URL` - URL of the application
- `REDIS_URL` - URL of a Redis server
- `CONTROLLER_URL` - URL of the controller application (default: http://controller:8080)
- `CONTROLLER_LOGIN` - the login of the controller application (default: '')
- `CONTROLLER_PASSWORD` - the password of the controller application (default: '')

## Prepare

```bash
docker-compose run --rm web bash -c "bundle install && bundle exec rails db:setup"
docker-compose up
```

## Connect from uffizzi-cli to the app

```bash
docker-compose run --rm gem bash
bundle exec uffizzi login --hostname http://web:7000 -u admin@uffizzi.com
```

password - `password`

## API Documentation

* [Development](http://lvh.me:7000/api-docs/index.html)

Rebuild documentation locally:

```bash
docker-compose run --rm core bash
bundle exec rake core:generate_docs
```

## Git workflow for the app:

1. Clone the repository and checkout to `develop` branch

2. Pull repository to ensure you have the latest changes
   
```bash
git pull --rebase develop
```

1. Start new branch from `develop`
   
```bash
git checkout -b feature/short_issue_description (e.g. feature/add_domain_settings)
```

1. Make changes you need for the feature, commit them to the repo
   
```bash
git add .
git commit -m 'short commit description' (e.g. git commit -m 'added domain settings')
git push origin BRANCH_NAME
```

1. You already can create PR with develop branch as a target. Once the feature is ready let us know in the channel - we will review

2. Merge your feature to `qa` branch and push. Ensure your pipeline is successful
   
```bash
git checkout qa
git pull --rebase qa
git merge --no-ff BRANCH_NAME
git push origin qa
```

# Running linter

```bash
docker-compose run --rm web bundle exec rubocop -A
```

# Running test

```bash
docker-compose run --rm core bash
bin/rails test
```

# Health checks

The default health check uri is `health_check`. To use a custom uri please add the `HEALTH_CHECK_URI` environment
variable to the docker-compose.yml

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/UffizziCloud/uffizzi_app.
