## Java System Property v.s. Spring Boot Property

To enable Reactor Netty access logs, set -Dreactor.netty.http.server.accessLogEnabled=true.
It must be a Java System Property, not a Spring Boot property.

## Commands

```
mvn spring-boot:run

# How to use maven plugin to pass command-line arguments to a Spring Boot application?
# Ref: https://www.baeldung.com/spring-boot-command-line-arguments
#
# For Spring Boot 1.x
mvn spring-boot:run -Drun.arguments=--customArgument=custom -Drun.jvmArguments=-Dfoo=bar

# Pass multiple parameters
mvn spring-boot:run -Drun.arguments=--spring.main.banner-mode=off,--customArgument=custom

# For Spring Boot 2.x, prefix `run` with `spring-boot.`.
mvn spring-boot:run -Dspring-boot.run.arguments=--spring.main.banner-mode=off,--customArgument=custom

# Disable debug
mvn spring-boot:run -Dspring-boot.run.arguments=--debug=false

# Pass jvm arguments
mvn spring-boot:run -Dspring-boot.run.arguments=--debug=false \
  -Dspring-boot.run.jvmArguments=-Dreactor.netty.http.server.accessLogEnabled=true

# Run spring cloud config server with local file system as backend.
mvn spring-boot:run -Dspring-boot.run.arguments=--spring.profiles.active=native,--spring.cloud.config.server.native.searchLocations=file:/path/to/your/local/folder
```

## Spring Initializr

```
curl https://start.spring.io

curl https://start.spring.io/starter.tgz \
  -d applicatioName=DemoApplication \
  -d groupId=com.example \
  -d artifactId=demo \
  -d baseDir=mydir \
  -d dependencies=cloud-gateway \
  | tar -xzvf -
```

## Spring Cloud Config Server

### How to use local git repo?

Use below application properties:

```
spring.cloud.config.server.git.uri=file:/path/to/your/git/repo
```

Note this way will reset your local changes.

Ref: https://stackoverflow.com/questions/53692384/how-to-prevent-spring-config-to-reset-my-local-git-repository-to-origin-master

### How to use local filesystem?

Use below configuration in application.yml:

```
spring:
  profiles:
    active: native
  cloud:
    config:
      server:
        native:
          searchLocations: file:/path/to/your/local/folder
```

## Spring Cloud Gateway

### Routes

```
curl http://localhost:8080/actuator/refresh
curl http://localhost:8080/actuator/gateway/routes
```
