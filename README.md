# Bashgress

## Quick start

Requirements:
- pkl
- kubectl

```shell
> terraform -chdir=azure apply -auto-approve
Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

> terraform -chdir=azure output -raw kube_config > my-cluster.yaml
> export KUBECONFIG=$PWD/my-cluster.yaml

> kubectl apply -k bashgress/
namespace/bashgress-system created
serviceaccount/bashgress created
role.rbac.authorization.k8s.io/bashgress created
rolebinding.rbac.authorization.k8s.io/bashgress created
configmap/bashgress-t56fh5f525 created
service/bashgress created
deployment.apps/bashgress created

> cd apps/
> pkl eval --format yaml *.pkl | kubectl apply -f -
deployment.apps/chocolux created
service/chocolux created
ingress.networking.k8s.io/chocolux created
deployment.apps/antique created
service/antique created
ingress.networking.k8s.io/antique created

> sudo kubectl port-forward --address 127.0.0.1 service/bashgress 80 9901 --namespace bashgress-system
Forwarding from 127.0.0.1:80 -> 8080
Forwarding from 127.0.0.1:9901 -> 9901
```

http://localhost:9901
http://antique.online
http://chocolux.online

## Cleanup

```shell
> terraform -chdir=azure destroy -auto-approve
```
