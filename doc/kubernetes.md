# Kubernetes

## How to expose pod to be accessible directly out of cluster

```
kubectl port-forward --address 0.0.0.0 pod-name host-port:container-port
```

## How to make deployment update image with latest tag?

### Method 1

For kubernetes >= 1.15, run `kubectl rollout restart deployment/deployment-name`

### Method 2

```
kubectl patch deployment deployment-name -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
```

### Method 3

This method works by changing the image to a specific digest.

```
kubectl set image deployment deployment-name container-name=$(docker inspect --format='{{index .RepoDigests 0}}' image-name:latest)
```

## Multi pod and container log tailing for Kubernetes

Ref: https://github.com/wercker/stern

```
wget -O stern ...
chmod a+x stern
sudo mv stern /usr/loca/bin

stern kafka --tail 10
stern -l app.kubernetes.io/name=kafka --tail 10
```

## Megabyte v.s. Mebibyte

1 Megabyte (MB)  = (1000)^2 bytes
1 Mebibyte (MiB) = (1024)^2 bytes

## security context, root container, non-root container

fsGroup (volume ownership) isn't working as expected, so we need to use initContainer to fix file permissions.

https://github.com/kubernetes/minikube/issues/1990
https://github.com/kubernetes/examples/issues/260

https://kubernetes.io/docs/tasks/configure-pod-container/security-context/
https://github.com/elastic/helm-charts/blob/master/elasticsearch/values.yaml
https://engineering.bitnami.com/articles/the-road-to-production-ready-charts.html
https://engineering.bitnami.com/articles/running-non-root-containers-on-openshift.html


## kubectl exec as root

1. Use `kubectl describe pod <pod-name>` to find docker container id
1. SSH into the corresponding node
1. Exec `docker exec -it -u root <docker-container-id> bash`

# Helm

## deleting a default key

If you need to delete a key from the default values, you may override the value
of the key to be `null`, in which case Helm will remove the key from the overridden
values merge.

Ref: https://helm.sh/docs/chart_template_guide/values_files/#deleting-a-default-key

## Automatically roll

Add `alwaysRoll` to `values.yaml`, and update deployment to:

```
spec:
  template:
    metadata:
      annotations:
        {{- if .Values.alwaysRoll }}
        rollUUID: {{ uuidv4 }}
        {{- end }}
```

Then specify `--set alwaysRoll=true` when using helm command.

Ref: https://helm.sh/docs/howto/charts_tips_and_tricks/#automatically-roll-deployments
