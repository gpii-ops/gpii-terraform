resource "google_monitoring_alert_policy" "compute_instances_insert" {
  display_name = "GCE audit log does not contain non-GKE instance creation events"
  combiner     = "OR"

  conditions {
    condition_threshold {
      filter          = "metric.type=\"logging.googleapis.com/user/compute.instances.insert\" resource.type=\"gce_instance\""
      comparison      = "COMPARISON_GT"
      threshold_value = 0.0
      duration        = "0s"

      trigger {
        count   = 0
        percent = 0
      }

      aggregations {
        alignment_period     = "600s"
        per_series_aligner   = "ALIGN_SUM"
        cross_series_reducer = "REDUCE_NONE"
        group_by_fields      = []
      }

      denominator_filter       = ""
      denominator_aggregations = []
    }

    display_name = "Non-GKE instance creation event found in GCE audit log"
  }

  documentation = {
    content   = "[Use this link to explore policy events in Logs Viewer](https://console.cloud.google.com/logs/viewer?project=${project_id}&minLogLevel=0&expandAll=false&interval=PT1H&advancedFilter=resource.type%3D%22gce_instance%22%20AND%20(protoPayload.methodName%3D%22beta.compute.instances.insert%22%20OR%20protoPayload.methodName%3D%22compute.instances.insert%22)%20AND%20protoPayload.authenticationInfo.principalEmail!%3D%${var.organization_id}@cloudservices.gserviceaccount.com%22)"
    mime_type = "text/markdown"
  }

  notification_channels = []
  user_labels           = {}
  enabled               = "true"
}
