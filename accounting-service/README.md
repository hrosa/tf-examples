# Accounting Service

Producer writes accounting data which is stored in ElasticSearch cluster.

## Design

```plantuml
@startuml

node "EC2" as ec2 {
 agent "producer" as producer
 agent "kinesis-agent" as kagent
 file "records-*.log" as records
 
 producer ..> records : write
 records <.. kagent : read
}

package "Data Broker" {
 component "Kinesis Stream" as broker
}

actor "HTTP Client" as client_http
package "Accounting API" {
 component "API GW" as api
 component "Lambda" as lambda_query
 component "OpenSearch" as db
 component "Kinesis Firehose" as firehose_api
 
 api --> lambda_query : HTTP GET
 lambda_query --> db : query
 firehose_api -left-> db : write
}

kagent --> broker : push
firehose_api -> broker : poll

client_http --> api : HTTP GET
@enduml
```
