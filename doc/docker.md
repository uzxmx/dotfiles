## Docker commands

### Run a container

```
# Start a container and publish container port 8080 to host port 3000.
docker run -p "3000:8080" image-name

# We can also start an interactive shell and execute command, so we can use `docker exec -it container-id bash` to update codes and restart process.
# When building the start command, remember to check if there is an entrypoint file or cmd for that dockerfile.
docker run -p "3000:8080" -it image-name bash
```

## How to build a docker image with http proxy?

```
docker build . -f docker/Dockerfile --build-arg http_proxy=http://192.168.1.5:8123
```

## `docker exec -it some-container bash` results in `stty -a` with 0 cols and 0 rows

Upgrade docker-ce to 18.09

## Mirror sites

### For images from docker.io

```
Example: docker pull mysql:5.0.0

Using a mirror like:
docker pull docker.mirrors.ustc.edu.cn/library/mysql:5.0.0
docker pull dockerhub.azk8s.cn/library/mysql:5.0.0

Example: docker pull foo/bar:v1.0.0

Using a mirror like:
docker pull docker.mirrors.ustc.edu.cn/foo/bar:v1.0.0
docker pull dockerhub.azk8s.cn/foo/bar:v1.0.0
```

### For images from gcr.io

```
Example: docker pull gcr.io/foo/bar:v1.0.0

Using a mirror like:
docker pull gcr.mirrors.ustc.edu.cn/foo/bar:v1.0.0
docker pull gcr.azk8s.cn/foo/bar:v1.0.0
```

### For images from k8s.gcr.io

```
Example: docker pull k8s.gcr.io/foo:v1.0.0

Using a mirror like:
docker pull gcr.mirrors.ustc.edu.cn/google-containers/foo:v1.0.0
docker pull gcr.azk8s.cn/google-containers/foo:v1.0.0
```

### For images from quay.io
```
Example: docker pull quay.io/coreos/etcd:v1.0.0

Using a mirror like:
docker pull quay.mirrors.ustc.edu.cn/coreos/etcd:v1.0.0
docker pull quay.azk8s.cn/coreos/etcd:v1.0.0
```
