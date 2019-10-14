## Groovy api doc

http://docs.groovy-lang.org/latest/html/groovy-jdk/

## In groovy script, we can use `assert` directive to debug

## REST API

### cat

```
GET http://$ES_URL/_cat

/_cat/allocation
/_cat/shards
/_cat/shards/{index}
/_cat/master
/_cat/nodes
/_cat/indices
/_cat/indices/{index}
/_cat/segments
/_cat/segments/{index}
/_cat/count
/_cat/count/{index}
/_cat/recovery
/_cat/recovery/{index}
/_cat/health
/_cat/pending_tasks
/_cat/aliases
/_cat/aliases/{alias}
/_cat/thread_pool
/_cat/plugins
/_cat/fielddata
/_cat/fielddata/{fields}
/_cat/nodeattrs
/_cat/repositories
/_cat/snapshots/{repository}
```

#### Common parameters

* v(verbose): Show column headers

GET http://$ES_URL/_cat/master?v

* help: Show available columns

GET http://$ES_URL/_cat/master?help

* h(headers): Select columns to be displayed

GET http://$ES_URL/_cat/master?v&h=id,node

* format: Change the output format. The available formats are text, json, smile, yaml or cbor.

GET http://$ES_URL/_cat/master?format=json

* sort: Sort output by column

GET http://$ES_URL/_cat/allocation?sort=shards,desc&h=shards,disk.indices

#### cat nodes

```
curl 'http://$ES_URL/_cat/nodes?v&h=name,host,master,heap.percent,heap.current,heap.max,ram.percent,ram.current,ram.max'
```

### misc

```
# Get license information
curl http://$ES_URL/_xpack
```

## How to resolve unassigned shards?

### Solution 1

For an index, if the number of replicas plus 1 is greater than the number of data nodes, then we can reduce the number of replicas to solve.

```
curl http://$ES_URL/_cat/indices

# Get the number of replicas
curl http://$ES_URL/index_name/_settings?pretty

# Set number_of_replicas 0
curl http://$ES_URL/index_name/_settings?pretty -XPUT -H 'Content-Type: application/json' -d'
{
  "index": {
    "number_of_replicas": 0
  }
}
'

# Set number_of_replicas 0 for all indices
curl http://$ES_URL/*/_settings?pretty -XPUT -H 'Content-Type: application/json' -d'
{
  "index": {
    "number_of_replicas": 0
  }
}
'
```

### Solution 2

Assign unassigned shard to a node

```
curl http://$ES_URL/_cluster/reroute?pretty -XPOST -H 'Content-Type: application/json' -d'
{
  "commands" : [
    {
      "allocate_stale_primary" : {
        "index": "index_name",
        "shard": 0,
        "node": "atlas-elasticsearch-data-0",
        "accept_data_loss": true
      }
    }
  ]
}
'
```

### Solution 3

If the index is unimportant, then we can delete it so all shards will be deleted.

```
curl -XDELETE http://$ES_URL/index_name
```
