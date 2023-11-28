<div align="center" style="border-bottom: none">
  <h1>
    <div>
        <a href="https://www.uffizzi.com">
            <img src="misc/uffizzi-icon.png" width="80" />
            <br>
            Uffizzi
        </a>
    </div>
    Environments-as-a-Service <br>
    <a href="https://opensource.org/licenses/Apache-2.0">
        <img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg">
    </a>
  </h1>
    <p align="center">
        <a href="http://www.uffizzi.com"><b>Website</b></a> •
        <a href="https://join.slack.com/t/uffizzi/shared_invite/zt-ffr4o3x0-J~0yVT6qgFV~wmGm19Ux9A"><b>Slack</b></a> •
        <a href="https://uffizzi.com/blog"><b>Blog</b></a> •
        <a href="https://twitter.com/_Uffizzi"><b>Twitter</b></a> •
        <a href="https://docs.uffizzi.com/"><b>Documentation</b></a>
    </p>
</div align="center" style="border-bottom: none">

Uffizzi helps teams build [internal developer platforms (IDPs)](/core-concepts/internal-developer-platform) in minutes, not months, by providing out-of-the-box [Kubernetes multi-tenancy](https://www.uffizzi.com/kubernetes-multi-tenancy), [virtual clusters](/core-concepts/ephemeral-environments/virtual-clusters), cloud-based [dev environments](/core-concepts/ephemeral-environments/dev-clusters), customizable templating, and more.

Uffizzi provides a foundation for building IDPs, so platform teams can build end-to-end workflows, giving every developer access to self-service, [ephemeral environments](/core-concepts/ephemeral-environments) for development, testing, PRs, staging and more. Use Uffizzi environments to preview pull requests before merging or integrate with your CI pipeline for automated, end-to-end testing.  
&nbsp;  
&nbsp;  

<hr>

<h3 align="center" style="border-bottom: none">
 <div>
   Trusted by top teams
 </div>  
</h3>
   <p align="center">
    <a href="https://backstage.spotify.com"><b>Backstage</b></a> •
    <a href="https://www.nocodb.com"><b>NocoDB</b></a> •
    <a href="https://www.forem.com"><b>Forem</b></a> •
    <a href="https://github.com/jesseduffield/lazygit"><b>Lazygit</b></a> •
    <a href="https://d2iq.com"><b>D2IQ</b></a> •
    <a href="https://github.com/parse-community/parse-dashboard"><b>ParseDashboard</b></a> •
    <a href="https://fonoster.com/"><b>Fonoster</b></a>
   </p>

  <p align="center">
    <a href="https://answer.dev/"><b>Answer</b></a> •
    <a href="https://www.windmill.dev/"><b>Windmill</b></a> •
    <a href="https://flagsmith.com/"><b>Flagsmith</b></a> •
    <a href="https://usememos.com/"><b>Memos</b></a> •
    <a href="https://craterapp.com/"><b>Crater</b></a> •
    <a href="https://livebook.dev/"><b>Livebook</b></a> •
    <a href="https://online-go.com/"><b>OnlineGo</b></a> •
    <a href="https://boxyhq.com/"><b>BoxyHQ</b></a>
  </p>

&nbsp;
Teams like [Backstage](https://github.com/backstage/backstage/tree/master/.github/uffizzi), [NocoDB](https://github.com/nocodb/nocodb/tree/develop/.github/uffizzi), and [Forem](https://github.com/forem/forem/blob/main/.github/workflows/uffizzi-preview.yml) have adopted Uffizzi because it's lightweight, fast, scalable, and more cost effective than competing solutions. Did you know that Spotify's Backstage team achieves rapid releases at scale using nearly 400 ephemeral environments per month? [Learn how →](https://www.uffizzi.com/ephemeral-environments)

<hr>

![github-banner](https://user-images.githubusercontent.com/7218230/191119628-4d39c65d-465f-4011-9370-d53d7b54d8cc.png)


## Quickstart (~2 minute)

Go to the [Quickstart Guide](https://docs.uffizzi.com/quickstart) to get started creating ephemeral environments.

## How it works
Spin up ephemeral environments on demand from the CLI, web dashboard, or from a CI pipeline. Each ephemeral environment is continually refreshed when you push new commits. Uffizzi also handles clean up, so your environments last only as long as you need them.  

Uffizzi's modular design works with GitHub, GitLab, BitBucket, and any CI provider.

<img width="600" alt="preview-url" src="https://user-images.githubusercontent.com/7218230/194924634-391aff82-8adf-473b-800e-a20dcdab82dd.png">

## Give us a star ⭐️
If you're interested in Uffizzi, give us a star. It helps others discover the project.

## Use cases

Uffizzi is designed to integrate with any CI platform as a step in your pipeline. You can use Uffizzi to rapidly create:  

- Cloud dev environments with hot reloading of deployed services
- On-demand test environments for Kubernetes applications
- Pull request environments  
- Debugging environments  
- Hotfix environments  
- Demo environments  
- Release environments
- Staging environments  

## What types of apps are supported by Uffizzi?

Uffizzi supports application configurations in Kubernetes manifests, Helm, kustomize, or Docker Compose. See [Using Uffizzi](https://docs.uffizzi.com/usage) to learn about the ways you can use Uffizzi.

## Why Uffizzi?

Uffizzi provides a foundation for building IDPs, so platform teams can build end-to-end workflows, giving every developer access to self-service, ephemeral environments for development, testing, PRs, staging and more.

Uffizzi is also useful for helping busy open source project leaders approve pull requests faster. Testing a live preview provides a more holistic way to assess a new feature or bug fix, rather than simply reviewing code changes. Uffizzi also removes the added step of pulling down the branch to test it locally: Uffizzi seamlessly integrates with CI providers like GitHub Actions and posts comments directly to pull request issues, so there is no additional step for the maintainer or the contributor. Learn how Uffizzi is helping [Backstage accelerate their development velocity by 20%](https://www.uffizzi.com/ephemeral-environments).

## Set up ephemeral environments for your application

(If you haven't completed the [quickstart guide](https://docs.uffizzi.com/quickstart), we recommend starting there to understand how Uffizzi works and how it's configured.)  

There are three options to get Uffizzi:  

1. **[Uffizzi Cloud](https://docs.uffizzi.com/cloud) (SaaS)** - This is fastest and easiest way to get started. Uffizzi Cloud is our fully managed option, so you don't have to worry about managing any infrastructure. You can get two concurrent environments for free, or unlock unlimited ephemeral environments with Uffizzi Pro. See our [Pricing page](https://www.uffizzi.com/pricing) for details. 
2. **[Uffizzi Enterprise](https://docs.uffizzi.com/enterprise)** - Uffizzi Enterprise provides the option to run workloads on your own infrastucture, along with more flexibility in customizing your ephemeral environments experience.   
3. **[Uffizzi Open Source](https://docs.uffizzi.com/open-source)** - Alternatively, you can install the open source version of Uffizzi on your own cluster by following the [self-hosted installation guide](INSTALL.md).

## Documentation

- [Main documentation](https://docs.uffizzi.com)
- [Docker Compose for Uffizzi ](https://docs.uffizzi.com/compose)
- [Quickstart guide](https://docs.uffizzi.com/quickstart)

## Community

- [Slack channel](https://join.slack.com/t/uffizzi/shared_invite/zt-ffr4o3x0-J~0yVT6qgFV~wmGm19Ux9A) - Get support or discuss the project  
- [Subscribe to our newsletter](https://www.linkedin.com/build-relation/newsletter-follow?entityUrn=7011448505391042560) - Receive monthly updates about new features and special events  
- [Contributing to Uffizzi](CONTRIBUTING.md) - Start here if you want to contribute
- [Code of Conduct](CODE_OF_CONDUCT.md) - Let's keep it professional

## FAQs

<details><summary><b>My team tests locally. Why do I need Ephemeral Environments?</b></summary>
<ol>
  <li>Ephemeral Environments <a href="https://docs.uffizzi.com/core-concepts/production-like">more closely resemble production</a>. Uffizzi deploys images built from your CI pipeline—similar to the ones deployed to a production environment. Uffizzi Ephemeral Environments also include a full network stack, including a domain and TLS certificate.</li>
  <li>Ephemeral Environments provide many benefits including standardizing development configurations, avoiding the bottleneck of a single test/staging environment, acting as a quality gate to help keep dirty code out of your main branch. Teams can develop and test new features or bug fixes in clean, isolated environments.</li>
  <li>Public preview URLs allow every stakeholder on a team to review features and bug fixes. This helps shorten the feedback loop between developer and reviewer/tester, resulting in faster releases.</li>
</ol>
</details>

<details><summary><b>How is Uffizzi different from Codespaces, Gitpod, etc.?</b></summary>
<p>Codespaces, Gitpod, and similar tools focus soley on providing development environments hosted in the cloud. They let you code locally (or in a browser-emulated editor) and see your changes in a live deployed environments. They can also provide developers access to more powerful machines than typically available on a laptop or desktop.</p>

<p>Uffizzi is a more full-featured platform designed for building self-serve developer platforms and for standardizing end-to-end developer workflows through on-demand dev, test, CI, and staging environments. Similar to Codespaces and Gitpod, Uffizzi offers cloud-based dev environments, but unlike these tools, Uffizzi users have access to the underlying Kubernetes clusters, enabling more complex configurations and customization via kubectl and similar tools. Uffizzi also supports creating virtual clusters for ephemeral test environments, as well as, CI integrations for pull request previews.</p>

See <a href="https://docs.uffizzi.com">our documentation</a> for other common uses and guides.

</details>

<details><summary><b>How is Uffizzi different from GitHub Actions (or other CI providers)?</b></summary>
Uffizzi does not replace GitHub Actions or any other CI provider. Uffizzi can be added as a step in your existing CI pipeline, after your container images are built and pushed to a container registry. For example, when you open a pull request, a GitHub Actions workflow can trigger the creation of new virtual cluster on Uffizzi and deploy that branch onto it. See our <a href="https://docs.uffizzi.com/ci">CI Recipes</a> for configuration help.
</details>

<details><summary><b>What about my database?</b></summary>
<p>All services deployed to Uffizzi ephemeral environments are deployed as containers—this includes databases, caches, and other stateful services This means that even if you use a managed database service like Amazon RDS for production, you should use a database <i>image</i> in your configuration (See our <a href="https://docs.uffizzi.com/handbook/database-seeding">Ephemeral Environments Handbook</a> for strategies on managing stateful services on Uffizzi.</p>
</details>

<details><summary><b>What do you mean by "environments"?</b></summary>
See <a href="https://docs.uffizzi.com/core-concepts/ephemeral-environments">our documentaion</a> for what we mean.
</details>

<details><summary><b>Does Uffizzi support monorepos/polyrepos?</b></summary>
Yes. Whether created via you're creating ephemeral environments from the CLI, dashboard, or CI pipeline, Uffizzi can deploy applications from one source or many. If you're using Uffizzi virtual clusters, you should define the sources in your Helm Charts, kustomizations, or manifests. For Docker Compose users, Uffizzi just needs to know the fully qualified container registry URL for where to find these built images. See the <a href="https://docs.uffizzi.com/compose/reference">Uffizzi Compose reference</a> for details.
</details>

<details><summary><b>Does Uffizzi support _____________?</b></summary>
In general, if your application can be containerized, described with Kubernetes, Helm, kustomize, or Docker Compose, then it is likely compatible with Uffizzi. The one notable exception to this is that Uffizzi does not support Node-level access, such as Kubernetes DaemonSets.  
</details>

<details><summary><b>How can my application services communicate?</b></summary>
See <a href="https://docs.uffizzi.com/architecture/networking">Uffizzi Networking</a> for details.
</details>

<details><summary><b>Is Uffizzi open source?</b></summary>
Yes. If you have access to a Kubernetes cluster, you can install Uffizzi via Helm. Follow the <a href="INSTALL.md">self-hosted installation guide</a>.
</details>

## License

This library is licensed under the [Apache License, Version 2.0](LICENSE).

## Security

If you discover a security related issues, please do **not** create a public github issue. Notify the Uffizzi team privately by sending an email to `security@uffizzi.com`.
