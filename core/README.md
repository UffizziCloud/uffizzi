# Uffizzi Core

**Uffizzi CLI API, Models, Services and core libraries**

## Uffizzi Overview

Uffizzi is the Full-stack Previews Engine that makes it easy for your team to preview code changes before merging—whether frontend, backend or microserivce. Define your full-stack apps with a familiar syntax based on Docker Compose, and Uffizzi will create on-demand test environments when you open pull requests or build new images. Preview URLs are updated when there’s a new commit, so your team can catch issues early, iterate quickly, and accelerate your release cycles.

## Getting started with Uffizzi

The fastest and easiest way to get started with Uffizzi is via the fully hosted version available at https://uffizzi.com, which includes free plans for small teams and qualifying open-source projects. 

Alternatively, you can self-host Uffizzi via the open-source repositories available here on GitHub. The remainder of this README is intended for users interested in self-hosting Uffizzi or for those who are just curious about how Uffizzi works.

## Uffizzi Architecture

Uffizzi consists of the following components:

* [Uffizzi App](https://github.com/UffizziCloud/uffizzi_app) - The primary REST API for creating and managing Previews
* [Uffizzi Controller](https://github.com/UffizziCloud/uffizzi_controller) - A smart proxy service that handles requests from Uffizzi App to the Kubernetes API
* Uffizzi CLI (this repository) - A command-line interface for Uffizzi App
* [Uffizzi Dashboard](https://app.uffizzi.com) - A graphical user interface for Uffizzi App, available as a paid service at https://uffizzi.com

To host Uffizzi yourself, you will also need the following external dependencies:

 * Kubernetes (k8s) cluster
 * Postgres database
 * Redis cache

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'uffizzi_core'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install uffizzi_core
```

## Development

# Prepare steps

```
docker-compose build
```

```
docker-compose run --rm core bash
bundle install
bin/rails db:setup
```

# Running test

```
docker-compose run --rm core bash
bin/rails test
```

# Running linter

```
docker-compose run --rm core bundle exec rubocop -A
```

## Git workflow for the app:

1. Clone the repository and checkout to `develop` branch

2. Pull repository to ensure you have the latest changes
```
git pull --rebase develop
```

3. Start new branch from `develop`
```
git checkout -b feature/short_issue_description (e.g. feature/add_domain_settings)
```

4. Make changes you need for the feature, commit them to the repo
```
git add .
git commit -m 'short commit description' (e.g. git commit -m 'added domain settings')
git push origin FEATURE_NAME
```

4. You already can create PR with develop branch as a target. Once the feature is ready let us know in the channel - we will review

5. Merge your feature to `qa` branch and push. Ensure your pipeline is successful
```
git checkout qa
git pull --rebase qa
git merge --no-ff FEATURE_NAME
git push origin qa
```

## API Documentation

* [Development](http://0.0.0.0:7007/api-docs/index.html)

Rebuild documentation locally:

```
bundle exec rake core:generate_docs
```

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/UffizziCloud/uffizzi_core.
