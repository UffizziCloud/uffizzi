## Contributing to `uffizzi_app`

Thanks for your interest we are actively working to release `uffizzi_app` and define how you can contribute - please follow for updates!

Uffizzi welcomes contributions from everyone!

## Procedures:

- Fork the project on Github.

- Make any changes you want to `uffizzi_app`, commit them, and push them to your fork.

- Create a pull request against main, and a maintainer will come by and review your inputs. They may ask for some changes or more information, and hopefully your contribution will be merged to the main branch!

## Communication:

If you need any help contributing, several maintainers are on the uffizzi users slack group https://join.slack.com/t/uffizzi/shared_invite/zt-ffr4o3x0-J~0yVT6qgFV~wmGm19Ux9A.

## Releases

We're using Semantic Versioning 2.0.0 to name our release tags: https://semver.org/

Be sure to update the `appVersion` within `charts/uffizzi-app/Chart.yaml` whenever you create a new release! And also update the tag for `image` within `charts/uffizzi-app/values.yaml`.

## Helm Chart Releases

When you change the Helm chart, even if it's just bumping the `appVersion` and `image` tag, also incrment the `version` within `charts/uffizzi-app/Chart.yaml`.  This version does not need to match the app version, and it's probably better if it does not.

When the new `Chart.yaml` makes it into the default branch, then the `chart-releaser` GitHub Action will create a new tag with a `uffizzi-app-` prefix. It will also update our Helm repo within the `gh-pages` branch. Let the automation handle this.
