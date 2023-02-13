resource "datadog_dashboard" "api_gw_dashboard" {
  title       = "API ${var.api_id} Dashboard"
  layout_type = "ordered"

  widget {
    timeseries_definition {
      title = "4xxerror.p95"
      request {
        q            = "avg:aws.apigateway.4xxerror.p90{apiid:${var.api_id},$resource,$method}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "API GW 5xxerror.p95"
      request {
        q            = "avg:aws.apigateway.5xxerror.p90{apiid:${var.api_id},$resource,$method}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.apigateway.latency.p95{apiid:${var.api_id},$resource,$method}"
        display_type = "line"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      title = "API GW Latency p95"
    }
  }

  widget {
    timeseries_definition {
      request {
        q            = "avg:aws.apigateway.integration_latency.p95{apiid:${var.api_id},$resource,$method}"
        display_type = "line"
        style {
          palette    = "dog_classic"
          line_type  = "solid"
          line_width = "normal"
        }
      }
      title = "API GW Integration_Latency p95."
    }
  }


  template_variable {
    name    = "resource"
    prefix  = "resource"
    default = "*"
  }

  template_variable {
    name    = "method"
    prefix  = "method"
    default = "*"
  }
}
