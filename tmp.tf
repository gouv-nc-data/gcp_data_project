variable "project_name" {
  type        = string
  description = "nom du projet"
}

variable "dataset_name" {
  type        = string
  description = "nom du projet"
}

variable "region" {
  type    = string
  default = "europe-west1"
}

variable "default_billing_account" {
  description = "Compte de facturation par défaut"
  type        = string
}

variable "direction" {
  description = "Direction du projet"
  type        = string
}

variable "primary_contact" {
  type = string
}

variable "secondary_contact" {
  type = string
}

variable "group_name" {
  type = string
}

variable "org_id" {
  description = "id de l'organisation"
  type        = number
}

output "project_id" {
  value = module.project-factory.project_id
}

output "group_email" {
  value = googleworkspace_group.grp-wks.email
}

output "dataset_id" {
  value = module.bigquery-dataset.dataset_id
}

output "notification_channels" {
  value = [google_monitoring_notification_channel.primary_contact.name, google_monitoring_notification_channel.secondary_contact.name]
}

locals {
  parent_folder_id = "658965356947" # production folder
  log_project_id   = "prj-p-log-and-monitor-ed1e"
}

module "project-factory" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 14.3"
  name                        = var.project_name
  org_id                      = var.org_id
  billing_account             = var.default_billing_account
  group_name                  = var.group_name
  random_project_id           = true
  budget_alert_spent_percents = [50, 75, 90]
  budget_amount               = 100
  create_project_sa           = false
  default_service_account     = "delete"
  folder_id                   = "folders/${local.parent_folder_id}"
  labels = {
    direction = var.direction
  }
  activate_apis = [
    "bigquery.googleapis.com",
  ]
}

module "bigquery-dataset" {
  source     = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/bigquery-dataset?ref=v26.0.0"
  project_id = module.project-factory.project_id
  id         = var.dataset_name
  location   = "EU"
}

###############################
# Groupe associé au projet
###############################

resource "googleworkspace_group" "grp-wks" {
  email       = "${var.group_name}@gouv.nc"
  description = "Groupe permettant la gestion des ressources du projet "
}

resource "googleworkspace_group_settings" "grp-wks" {
  email                 = googleworkspace_group.grp-wks.email
  allow_web_posting     = false
  who_can_post_message  = "ALL_MEMBERS_CAN_POST"
  who_can_contact_owner = "ALL_MEMBERS_CAN_CONTACT"
}

resource "googleworkspace_group_member" "grp-wks-member1" {
  group_id = googleworkspace_group.grp-wks.id
  email    = var.primary_contact
  role     = "OWNER"
}

resource "googleworkspace_group_member" "grp-wks-member2" {
  group_id = googleworkspace_group.grp-wks.id
  email    = var.secondary_contact
  role     = "OWNER"
}

###############################
# Droits sur bigquery
###############################

resource "google_project_iam_member" "main" {
  for_each = toset(["group:${googleworkspace_group.grp-wks.email}", ])
  project  = module.project-factory.project_id
  role     = "roles/bigquery.admin"
  member   = each.value
}

###############################
# Alertes
###############################

resource "google_monitoring_notification_channel" "primary_contact" {
  display_name = "Primary email contact for the project"
  type         = "email"
  project      = module.project-factory.project_id

  labels = {
    email_address = var.primary_contact
  }
}

resource "google_monitoring_notification_channel" "secondary_contact" {
  display_name = "Secondary email contact for the project"
  type         = "email"
  project      = module.project-factory.project_id

  labels = {
    email_address = var.secondary_contact
  }
}

resource "google_monitoring_notification_channel" "org_admin_contact" {
  display_name = "Organization admins email contact"
  type         = "email"
  project      = module.project-factory.project_id
  labels = {
    email_address = "gcp-organization-admins@gouv.nc"
  }
}

###############################
# Logging
###############################

resource "google_project_service" "monitoring-service-monlog" {
  project = module.project-factory.project_id
  service = "monitoring.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }
}

resource "google_monitoring_monitored_project" "projects_monitored" {
  metrics_scope = join("", ["locations/global/metricsScopes/", "${local.log_project_id}"])
  name          = module.project-factory.project_id
  depends_on    = [google_project_service.monitoring-service-monlog]
}


# ###############################
# # Supervision
# ###############################
# resource "google_monitoring_alert_policy" "errors" {
#   display_name = "Errors in logs alert policy"
#   project      = module.project-factory.project_id
#   combiner     = "OR"
#   conditions {
#     display_name = "Error condition"
#     condition_matched_log {
#       filter = "severity=ERROR"
#     }
#   }

#   notification_channels = [google_monitoring_notification_channel.primary_contact.name]
#   alert_strategy {
#     notification_rate_limit {
#       period = "300s"
#     }
#   }
# }
