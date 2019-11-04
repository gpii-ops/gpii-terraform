resource "google_logging_metric" "compute_firewalls_modify" {
  depends_on = ["null_resource.destroy_old_stackdriver_resources"]
  name       = "compute.firewalls.modify"
  filter     = "resource.type=\"gce_firewall_rule\" AND (protoPayload.methodName:\"compute.firewalls.insert\" OR protoPayload.methodName:\"compute.firewalls.patch\" OR protoPayload.methodName:\"compute.firewalls.update\" OR protoPayload.methodName:\"compute.firewalls.delete\")"

  metric_descriptor {
    metric_kind = "DELTA"
    value_type  = "INT64"
  }
}
