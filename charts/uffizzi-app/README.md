# Uffizzi App Helm Chart

This chart installs [Uffizzi](https://uffizzi.com), the continuous previews application. This is just a standard open-source Uffizzi setup.

### Dependencies

This chart depends upon three subcharts:

- [`bitnami/postgresql`](https://artifacthub.io/packages/helm/bitnami/postgresql)
- [`bitnami/redis`](https://artifacthub.io/packages/helm/bitnami/redis)
- [`uffizzi-controller`](https://artifacthub.io/packages/helm/uffizzi-controller/uffizzi-controller)

You can disable the `bitnami` subcharts if you want to manage your own datastores.

## Configuration

### DNS

You'll want to configure the following values to include a hostname you control:

- `app_url`
- `webHostname`
- `managed_dns_zone_dns_name`
- `uffizzi-controller.ingress.hostname`

### Controller

See the Controller's Helm Chart for it's configuration, including its certificate authority.

### Secrets

The following secrets are configurable:

- `global.uffizzi.controller.username`
- `global.uffizzi.controller.password`

## More Info

See this project's main repository here: https://github.com/UffizziCloud/uffizzi_app

And explore Uffizzi https://uffizzi.com
