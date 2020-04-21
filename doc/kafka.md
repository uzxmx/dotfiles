# Kafka

## Use SASL/PLAIN to manage users

A new pair of username and password can be added in `config/kafka_server_jaas.conf`.

The configurations in `config/client-ssl.properties` should be like below:

```
sasl.mechanism=PLAIN
security.protocol=SASL_SSL
ssl.truststore.location=<path-to-server-truststore-jks>
ssl.truststore.password=<password>
ssl.endpoint.identification.algorithm=

# Change username and password based on your need.
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required \
    username="admin" \
    password="<admin-password>";
```

Ref: https://kafka.apache.org/documentation/#security_sasl_plain

## Use SCRAM to manage users dynamically

```
kafka-configs.sh --zookeeper kafka-zookeeper:2181 --alter \
  --add-config 'SCRAM-SHA-256=[iterations=8192,password=YOUR_PASSWORD],SCRAM-SHA-512=[password=YOUR_PASSWORD]' \
  --entity-type users --entity-name YOUR_USERNAME

# Show a user
kafka-configs.sh --zookeeper kafka-zookeeper:2181 --describe \
  --entity-type users --entity-name YOUR_USERNAME

# Delete a user
kafka-configs.sh --zookeeper kafka-zookeeper:2181 --alter \
  --delete-config 'SCRAM-SHA-512' --entity-type users --entity-name YOUR_USERNAME
```

Client config properties:

```
sasl.mechanism=SCRAM-SHA-512
security.protocol=SASL_SSL
ssl.truststore.location=config/kafka.truststore.jks
ssl.truststore.password=9107790e420c4a
ssl.endpoint.identification.algorithm=

# Change username and password based on your need.
sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required \
    username="alice" \
    password="alice-secret";
```

Ref: http://kafka.apache.org/documentation/#security_sasl_scram

## Topic

### Create a topic

```
# --zookeeper option is deprecated, use --bootstrap-server instead.
# Using --bootstrap-server, you may need to specify --command-config, but
# you don't need when using --zookeeper.
./bin/kafka-topics.sh --zookeeper localhost:2181 --create --topic $TOPIC --partitions 1 \
  --replication-factor 3 --config max.message.bytes=64000 --config flush.messages=1
```

### Show a topic

```
./bin/kafka-topics.sh --zookeeper localhost:2181 --describe --topic topic_name

BOOTSTRAP_SERVER=localhost:9093
./bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER \
  --command-config ./config/client-ssl.properties \
  --describe --topic topic_name
```

### List topics

```
./bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER \
  --command-config ./config/client-ssl.properties --list
```

### Delete a topic

```
./bin/kafka-topics.sh --bootstrap-server $BOOTSTRAP_SERVER \
  --command-config ./config/client-ssl.properties \
  --delete --topic topic_name
```

## ACLs

### List ACLs

```
./bin/kafka-acls.sh --authorizer-properties zookeeper.connect=127.0.0.1:2181 --list
```

### Allow/Deny/Remove a user to produce messages to a topic

```
USER=username
TOPIC=topic
./bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --allow-principal User:$USER --producer --topic $TOPIC

./bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add --deny-principal User:$USER --producer --topic $TOPIC

./bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --remove --allow-principal User:$USER --producer --topic $TOPIC
```

### Allow a user to consume messages from a topic

```
USER=username
TOPIC=topic
GROUP=group
./bin/kafka-acls.sh --authorizer-properties zookeeper.connect=localhost:2181 --add \
  --allow-principal User:$USER --consumer --topic $TOPIC --group $GROUP
```

## Consumer

```
./bin/kafka-console-consumer.sh --from-beginning \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --topic $TOPIC --consumer.config config/client-ssl.properties

./bin/kafka-console-consumer.sh --from-beginning \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --topic $TOPIC --consumer.config config/client-ssl.properties --group $GROUP

# Without config properties file
./bin/kafka-console-consumer.sh --from-beginning --bootstrap-server $BOOTSTRAP_SERVER --topic $TOPIC --group $GROUP \
  --consumer-property sasl.mechanism=SCRAM-SHA-512 \
  --consumer-property security.protocol=SASL_SSL \
  --consumer-property ssl.truststore.location=path-to-truststore \
  --consumer-property ssl.truststore.password=password \
  --consumer-property ssl.endpoint.identification.algorithm= \
  --consumer-property 'sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="username" password="password";'
```

## Producer

```
./bin/kafka-console-producer.sh --broker-list $BOOTSTRAP_SERVER \
  --topic $TOPIC --producer.config config/client-ssl.properties

# Without config properties file
./bin/kafka-console-producer.sh --broker-list $BOOTSTRAP_SERVER --topic $TOPIC \
  --producer-property sasl.mechanism=SCRAM-SHA-512 \
  --producer-property security.protocol=SASL_SSL \
  --producer-property ssl.truststore.location=path-to-truststore \
  --producer-property ssl.truststore.password=password \
  --producer-property ssl.endpoint.identification.algorithm= \
  --producer-property 'sasl.jaas.config=org.apache.kafka.common.security.scram.ScramLoginModule required username="username" password="password";'
```
