
![banner](docs/images/banner.png)

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

## What is Uffizzi?

Uffizzi is a cloud-native REST API for managing lightweight, event-driven test environments on Kubernetes. It provides Development teams with an environments-as-a-service capability, while eliminating the need for Operations teams to configure and manage test infrastructure and tooling. 

## Use cases
Uffizzi is designed to integrate with any CI/CD platform as a step in your pipeline. Example use cases include rapidly creating PR environments, preview environments, release environments, demo environments, and staging environments. 

## Why Uffizzi?

- **👩‍💻 Developer-friendly** - The Uffizzi API provides a simplified interface to Kubernetes, allowing you to define your application with Docker Compose.

- **🪶 Lightweight** - Uffizzi test environments are isolated namespaces within a single cluster. This level of abstraction helps improve performance and use compute resources more efficiently.

- **🔁 Event-driven** - Designed to integrate with any CI/CD system, Uffizzi environments are created, updated, or deleted via triggering events, such as pull requests or new release tags. Uffizzi generates a secure HTTPS URL for each environment, which is continually refreshed in response to new events.

- **🧼 Clean** - The ephermeral nature of Uffizzi test environments means your team can test new features or release candidates in clean, parallel environments before merging or promoting to production.


## Project roadmap

See our high-level project roadmap, including already delivered milestones.

- [See the roadmap](https://github.com/orgs/UffizziCloud/projects/2/views/1?layout=board)

## Getting started

The quickest and easiest way to get started with Uffizzi is by using the managed API service. Alternatively, you can install Uffizzi on your own cluster.

- [Managed service guide]() (recommended to start here) - TODO 
- [Self-hosted installation guide]() - TODO  


## Documentation
- [Main documentation]() -  TODO
- [Swagger API documentation]() - TODO
- [Architecture]() - TODO
- [CI/CD integration guide]() - TODO 
- [Docker Compose for Uffizzi ]() - TODO

## Community

- [Slack channel](https://join.slack.com/t/uffizzi/shared_invite/zt-ffr4o3x0-J~0yVT6qgFV~wmGm19Ux9A) - Get support or discuss the project  
- [Contributing to Uffizzi](https://github.com/UffizziCloud/uffizzi_app/blob/feature/update-readme/CONTRIBUTING.md) - Start here if you want to contribute
- [FAQ](https://uffizzi.com/#faqs) - Frequently Asked Questions
- [Code of Conduct](CODE_OF_CONDUCT.md) - Let's keep it professional
- [Engineering Blog](https://docs.uffizzi.com/engineeringblog/ci-cd-registry/) - Lessons learned and best practices from Uffizzi maintainers
- Give us a star ⭐️ - If you are using Uffizzi or think it's an interesting project, star this repo! This helps others find out about our project.

## License

This library is licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0

## Security

If you discover a security related issues, please do **not** create a public github issue. Notify the Uffizzi team privately by sending an email to security@uffizzi.com.