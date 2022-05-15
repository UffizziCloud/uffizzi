# Contributing to `uffizzi_app`

Thanks for your interest! We are actively working to release `uffizzi_app` and define how you can contribute - please follow for updates!

Uffizzi welcomes contributions from everyone!

## Communication:

If you need any help contributing, several maintainers are on the Uffizzi Users Slack group https://join.slack.com/t/uffizzi/shared_invite/zt-ffr4o3x0-J~0yVT6qgFV~wmGm19Ux9A.

## Releases

We're using Semantic Versioning 2.0.0 to name our release tags: https://semver.org/

Be sure to update the `appVersion` within `charts/uffizzi-app/Chart.yaml` whenever you create a new release! And also update the tag for `image` within `charts/uffizzi-app/values.yaml`.

## Helm Chart Releases

When you change the Helm chart, even if it's just bumping the `appVersion` and `image` tag, also increment the `version` within `charts/uffizzi-app/Chart.yaml`.  This chart version does not need to match the app version, and it's probably better if it does not.

When the new `Chart.yaml` makes it into the default branch, then the `chart-releaser` GitHub Action will create a new tag with a `uffizzi-app-` prefix. It will also update our Helm repo within the `gh-pages` branch. Let the automation handle this.

# Procedures for outside collaborators:

- Fork the project on Github.

- Make any changes you want to `uffizzi_app`, commit them, and push them to your fork.

- Create a Pull Request against `UffizziCloud/uffizzi_app:main`, and a maintainer will come by and review your inputs. They may ask for some changes or more information, and hopefully your contribution will be merged to the `main` branch!

# Procedures for Uffizzi team members:

1. Clone the repository and checkout to `develop` branch.

2. Pull repository to ensure you have the latest changes.

```bash
git pull --rebase develop
```

3. Start new branch from `develop`

```bash
git checkout -b feature/ISSUE_NUMBER_short_issue_description (e.g. feature/53_add_domain_settings)
```

4. Make changes you need for the feature, commit them to the repo

```bash
git add .
git commit -m '[#ISSUE_NUMBER] short commit description' (e.g. git commit -m '[#53] added domain settings')
git push origin BRANCH_NAME
```

5. You already can create PR with develop branch as a target. Once the feature is ready let us know in the channel - we will review

6. Merge your feature to `qa` branch and push. Ensure your pipeline is successful.

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
