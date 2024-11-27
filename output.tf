output "project_id" {
  value = module.project-factory.project_id
}

output "project_number" {
  value = module.project-factory.project_number
}

output "group_email" {
  value = googleworkspace_group.grp-wks.email
}

output "dataset_id" {
  value = var.dataset_name != null ? one(module.bigquery-dataset).dataset_id : null
}


output "notification_channels" {
  value = [google_monitoring_notification_channel.grp-wks.name]
}
