## Install brigade

```
helm repo add brigade https://brigadecore.github.io/charts

# Install brigade chart under brigade namespace
helm install brigade/brigade -n brigade --namespace brigade --set genericGateway.enabled=true
```

## Install brig

```
wget -O brig https://github.com/brigadecore/brigade/releases/download/v1.2.0/brig-linux-amd64
chmod +x brig
mv brig ~/bin
```

## Create a project

```
brig create project -n brigade
```

## Install brigade-k8s-gateway

```
helm inspect values brigade/brigade-k8s-gateway >myvalues.yaml

# The role specified in brigade/brigade-k8s-gateway chart can only watch kubernetes events under the namespace of the chart release.
# The generated worker will be in the same namespace as brigade core.
helm install brigade/brigade-k8s-gateway -f myvalues.yaml -n brigade-k8s-gateway
helm install brigade/brigade-k8s-gateway -f myvalues.yaml -n brigade-k8s-gateway --namespace brigade
```
