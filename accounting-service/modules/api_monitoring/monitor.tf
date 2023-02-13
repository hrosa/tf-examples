resource "datadog_monitor" "api_latency" {
  name    = "API ${var.api_id} Latency p90"
  type    = "metric alert"
  message = "High response latency over an extended period of time"
  query   = "max(last_30m):aws.apigateway.latency.p90{apiid:${var.api_id}} by {method,resource} > 10000"
}