
![github-banner](https://user-images.githubusercontent.com/7218230/191119628-4d39c65d-465f-4011-9370-d53d7b54d8cc.png)


[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## What is Uffizzi?

Uffizzi is a platform that let's you preview pull requests before merging. Create on-demand Preview Environments for APIs, frontends, backends, databases, and microservices. Each Preview Environment gets a secure HTTPS URL that is continually refreshed when you push new commits. Uffizzi also handles clean up, so your environments last only as long as you need them.  

Uffizzi is an open-source, off-the-shelf, cross-platform solution that works with any version control system, container registry, or CI platform.

## Use cases

Uffizzi is designed to integrate with any CI platform as a step in your pipeline. Example use cases include rapidly creating PR environments, preview environments, release environments, demo environments, debugging environments, and staging environments. 

Uffizzi is a tool that improves development velocity by removing the bottleneck of a shared test environment, where buggy or conflicting commits from multiple developers often cause an environment to break. Uffizzi Preview Environments enable teams to test the functionality of each branch in clean, production-like environments before merging. Uffizzi also facilitates test parallelization and helps shift testing to the left, where it's easier to catch and fix bugs. 

## What types of apps are supported by Uffizzi?

Uffizzi is designed for full-stack web applications and containerized services, including APIs, backends, frontends, databases, and microservices. Currently, application configurations must be defined via Docker Compose. Support for Helm and other configuration formats are on our [public roadmap](https://github.com/orgs/UffizziCloud/projects/2/views/1?layout=board). See [Docker Compose for Uffizzi ](https://docs.uffizzi.com/references/compose-spec/) to learn more about supported syntax.

## Why Uffizzi?

- **👩‍💻 Developer-friendly** - Uffizzi is configured via Docker Compose, the same tool many teams use for local development.

- **🪶 Lightweight** - Uffizzi Preview Environments are isolated Pods/Namespaces deployed to a Kubernetes cluster. This level of abstraction helps reduce a team's infrastructure footprint and associated overhead.

- **🔁 Event-driven** - Designed to integrate with any CI system, Uffizzi environments are created, updated, or deleted via triggering events, such as pull requests or new release tags. Uffizzi generates a secure HTTPS URL for each environment, which is continually refreshed in response to new events.

- **🧼 Clean** - The ephemeral nature of Uffizzi test environments means your team can test new features or release candidates in clean, parallel environments before merging or promoting to production.

## Project roadmap

See our high-level [project roadmap](https://github.com/orgs/UffizziCloud/projects/2/views/1?layout=board), including already delivered milestones.

## Getting started

The easiest way to get started with Uffizzi is via the managed API service provided by Uffizzi Cloud, as describe in the [quickstart guide](docs.uffizzi.com). This option is free for small teams and is recommended for those who are new to Uffizzi. Alternatively, you can get started creating on-demand test environments on your own cluster by following the [self-hosted installation guide](INSTALL.md).

## Documentation
- [Main documentation](https://docs.uffizzi.com)
- [Docker Compose for Uffizzi ](https://docs.uffizzi.com/references/compose-spec/)

## Community

- [Slack channel](https://join.slack.com/t/uffizzi/shared_invite/zt-ffr4o3x0-J~0yVT6qgFV~wmGm19Ux9A) - Get support or discuss the project  
- [Subscribe to our newsletter](http://eepurl.com/hsws0b) - Receive monthly updates about new features and special events  
- [Contributing to Uffizzi](CONTRIBUTING.md) - Start here if you want to contribute
- [FAQ](https://uffizzi.com/#faqs) - Frequently Asked Questions
- [Code of Conduct](CODE_OF_CONDUCT.md) - Let's keep it professional
- [Engineering Blog](https://docs.uffizzi.com/engineeringblog/ci-cd-registry/) - Lessons learned and best practices from Uffizzi maintainers
- Give us a star ⭐️ - If you are using Uffizzi or just think it's an interesting project, star this repo! This helps others find out about our project.

## License

This library is licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0

## Security

If you discover a security related issues, please do **not** create a public github issue. Notify the Uffizzi team privately by sending an email to security@uffizzi.com.
