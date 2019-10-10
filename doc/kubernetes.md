## How to make deployment update image with latest tag?

### Method 1

For kubernetes >= 1.15, run `kubectl rollout restart deployment/deployment-name`

### Method 2

```
kubectl patch deployment deployment-name -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"
```

### Method 3

```
kubectl set image deployment deployment-name container-name=$(docker inspect --format='{{index .RepoDigests 0}}' image-name:latest)
```
