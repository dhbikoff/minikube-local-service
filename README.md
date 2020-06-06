# Local Service Helm Chart

A simple helm chart that will put a dev service, running on your host, behind a minikube ingress route.

`ex: myhost.dev/myservice/foo`

## Deploying the Helm chart
Your host service must be bound to 0.0.0.0, so that it's accessible from within the minikube vm.

The following script example will deploy a helm chart into k8s that wires up a local service, running on port 3000,
and makes it accessible at myhost.dev/myservice/*

`$ ./deploy.sh -n myservice -h myhost.dev -p 3000`

You can hit your endpoints. Note this curl example uses the `-L` flag, which follows redirects.
The k8s Nginx ingress controller redirects requests to your host service.

`$ curl -L myhost.dev/myservice/ping`

You can attach as many services as you like, just use a different `path-part` and `host-port` for each.

`$ ./deploy.sh -n myservice -h myhost.dev -p 3000`

`$ ./deploy.sh -n myservice-ui -h myhost.dev -p 3001`

## Deleting a local service

`$ ./deploy.sh -d myservice`
