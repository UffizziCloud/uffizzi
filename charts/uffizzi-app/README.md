# Uffizzi App Helm Chart

This chart installs [Uffizzi](https://uffizzi.com), the continuous previews application. This is just a standard open-source Uffizzi setup.

## Requirements

This chart requires a Kubernetes Cluster. While it will likely function on k8s >= 1.19, we have only tested upon k8s 1.21 - 1.23.

The Cluster must be capable of provisioning `Ingress` resources that obtain public IP addresses and/or hostnames.

We've briefly tested Uffizzi on:

- Google Kubernetes Engine (GKE)
- Azure Kubernetes Service (AKS)
- Amazon Elastic Kubernetes Service (EKS)

### Dependencies

This chart depends upon three subcharts:

- [`bitnami/postgresql`](https://artifacthub.io/packages/helm/bitnami/postgresql)
- [`bitnami/redis`](https://artifacthub.io/packages/helm/bitnami/redis)
- [`uffizzi-controller`](https://artifacthub.io/packages/helm/uffizzi-controller/uffizzi-controller)

You can disable the `bitnami` subcharts if you want to manage your own datastores.

## Configuration

This Helm chart requires integration with your DNS records and other services, so there are several required values. Create a YAML file with these values before installing this chart. There's an example below and you can read more about Helm Values Files here: https://helm.sh/docs/chart_template_guide/values_files/

### Controller

See the [Controller's Helm Chart](https://artifacthub.io/packages/helm/uffizzi-controller/uffizzi-controller) for its configuration, including its certificate authority.

The controller itself depends upon two other popular Helm charts:

- [`ingress-nginx`](https://kubernetes.github.io/ingress-nginx/)
- [`cert-manager`](https://cert-manager.io/docs/)

If you already have one or both of these applications installed, you may want to disable them for this Helm release. Specifically, your k8s Cluster may already have cert-manager's Custom Resource Definitions defined.

### Secrets

When installing Uffizzi in a sensitive or production environment, it's important to generate strong passwords. Provide new values for the `ChangeMeNow` values in the example below.

### Example Helm Values File
Example values file with required values:

```yaml
global:
  postgresql:
    auth:
      postgresPassword: ChangeMeNow
      password: ChangeMeNow
  redis:
    password: ChangeMeNow
  uffizzi:
    controller:
      password: ChangeMeNow
app_url: https://uffizzi.example.com
webHostname: uffizzi.example.com
allowed_hosts: uffizzi.example.com
managed_dns_zone_dns_name: uffizzi.example.com
uffizzi-controller:
  ingress:
    hostname: controller.uffizzi.example.com
  clusterIssuer: "letsencrypt"
  cert-email: admin@example.com
```

Edit these values and save them in a file named `myvals.yaml` or similar.

## Installation

If this is your first time using Helm, consult their documentation: https://helm.sh/docs/intro/quickstart/

Begin by adding our Helm repository:

```
helm repo add uffizzi-app https://uffizzicloud.github.io/uffizzi_app/
```

Then install the lastest version as a new release using the values you specified earlier. We recommend isolating Uffizzi in its own Namespace.

```
helm install my-uffizzi-app uffizzi-app/uffizzi-app --values myvals.yaml --namespace uffizzi --create-namespace
```

If you encounter any errors here, tell us about them in [our Slack](https://join.slack.com/t/uffizzi/shared_invite/zt-ffr4o3x0-J~0yVT6qgFV~wmGm19Ux9A).

You should then see the release is installed:
```
helm list --namespace uffizzi
```

### DNS

After the Helm release is installed, add DNS records for the hostnames you specified in your values file.  You can obtain the IP or hostname for Uffizzi's Ingress using `kubectl`:

```
kubectl get ingress --namespace uffizzi
```

Be sure to add a "wildcard" record for the domain specified in `managed_dns_zone_dns_name`. In the above example, that's `*.uffizzi.example.com`.

### Creating the first user

After installation, you'll need to create at least one User to access your Uffizzi installation. For now, the best way to do this is executing an interactive `rake` task within the application server container:

```
kubectl exec -it deploy/my-uffizzi-app-web --namespace uffizzi -- rake uffizzi_core:create_user
Enter User Email (default: user@example.com): user@example.com
Enter Password:
Enter Project Name (default: default):
```

## Usage

If everything went well, you can now connect to the Uffizzi API service and begin Continously Deploying Previews! Use [the Uffizzi CLI](https://github.com/UffizziCloud/uffizzi_cli) or [the Uffizzi GitHub Action](https://github.com/UffizziCloud/preview-action) or your own API client.

## More Info

See this project's main repository here: https://github.com/UffizziCloud/uffizzi_app

And explore Uffizzi https://uffizzi.com
