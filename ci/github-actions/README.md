# Use Uffizzi with GitHub Actions

You can configure Uffizzi to create, update, and delete on-demand test environments with the GitHub Actions [reusable workflow](https://github.com/UffizziCloud/preview-action/blob/master/.github/workflows/reusable.yaml). This reusable workflow will execute the [Uffizzi CLI](https://github.com/UffizziCloud/uffizzi_cli) on a GitHub Actions runner, which then opens a connection to the Uffizzi API.

## Example usage

The following example application demonstrates how to use Uffizzi with GitHub Actions:

[Example voting app](https://github.com/UffizziCloud/example-voting-app/blob/main/.github/workflows/uffizzi-previews.yml)

