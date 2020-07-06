## Docker commands

### Run a container

```
# Start a container and publish container port 8080 to host port 3000.
docker run -p "3000:8080" image-name

# We can also start an interactive shell and execute command, so we can use `docker exec -it container-id bash` to update codes and restart process.
# When building the start command, remember to check if there is an entrypoint file or cmd for that dockerfile.
docker run -p "3000:8080" -it image-name bash
```

### Show node labels

```
docker node ls -q | xargs docker node inspect \
  -f '{{ .ID }} [{{ .Description.Hostname }}]: {{ .Spec.Labels }}'

docker node ls -q | xargs docker node inspect \
  -f '{{ .ID }} [{{ .Description.Hostname }}]: {{ range $k, $v := .Spec.Labels }}{{ $k }}={{ $v }} {{end}}'
```

### Swarm network

```
https://stackoverflow.com/questions/52665442/docker-swarm-host-cannot-resolve-hosts-on-other-nodes
```

## Ctrl-p behaving unexpectedly under Docker

The command sequence to detach from a docker container is ctrl-p ctrl-q, which is why ctrl-p doesn't
work as expected. When you hit ctrl-p, docker is waiting on ctrl-q, so nothing happens.

You can use the new --detach-keys argument to docker run to override this sequence to be something other than ctrl-p:

```
docker run -ti --detach-keys="ctrl-@" ubuntu:14.04 bash
```

If you want, you can add this to your ~/.docker/config.json file to persist this change:

```
{
  ...
  "detachKeys": "ctrl-@",
  ...
}
```

Ref: https://stackoverflow.com/questions/41820108/ctrl-p-and-ctrl-n-behaving-unexpectedly-under-docker

## How to build a docker image with http proxy?

```
docker build . -f docker/Dockerfile --build-arg http_proxy=http://192.168.1.5:8123
```

## `docker exec -it some-container bash` results in `stty -a` with 0 cols and 0 rows

Upgrade docker-ce to 18.09

## Mirror sites

### For images from docker.io

* docker.mirrors.ustc.edu.cn
* hub-mirror.c.163.com
* <ali-allocated-prefix>.mirror.aliyuncs.com

```
# Example: docker pull mysql:5.0.0
#
# Using a mirror like:
docker pull docker.mirrors.ustc.edu.cn/library/mysql:5.0.0
docker pull dockerhub.azk8s.cn/library/mysql:5.0.0
docker pull hub-mirror.c.163.com/library/mysql:5.0.0

# Example: docker pull foo/bar:v1.0.0
#
# Using a mirror like:
docker pull docker.mirrors.ustc.edu.cn/foo/bar:v1.0.0
docker pull dockerhub.azk8s.cn/foo/bar:v1.0.0
```

### For images from gcr.io

```
# Example: docker pull gcr.io/foo/bar:v1.0.0
#
# Using a mirror like:
docker pull gcr.mirrors.ustc.edu.cn/foo/bar:v1.0.0
docker pull gcr.azk8s.cn/foo/bar:v1.0.0
```

### For images from k8s.gcr.io

```
# Example: docker pull k8s.gcr.io/foo:v1.0.0
#
# Using a mirror like:
docker pull gcr.mirrors.ustc.edu.cn/google-containers/foo:v1.0.0
docker pull gcr.azk8s.cn/google-containers/foo:v1.0.0
```

### For images from quay.io
```
# Example: docker pull quay.io/coreos/etcd:v1.0.0
#
# Using a mirror like:
docker pull quay.mirrors.ustc.edu.cn/coreos/etcd:v1.0.0
docker pull quay.azk8s.cn/coreos/etcd:v1.0.0
```
