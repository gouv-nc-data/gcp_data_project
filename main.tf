locals {
  parent_folder_id = "658965356947" # production folder
  log_project_id   = "prj-p-log-and-monitor-ed1e"
  pj_bq_viewer_ls  = var.pj_bq_viewer_ls == null ? var.pj_bq_adm_ls : var.pj_bq_viewer_ls
}

module "project-factory" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 14.3"
  name                        = var.project_name
  org_id                      = var.org_id
  billing_account             = var.default_billing_account
  group_name                  = var.group_name
  group_role                  = "roles/editor"
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
# Groupes associés au projet
###############################

# bq dataform nb admin
resource "googleworkspace_group" "grp-wks" {
  email       = "${var.group_name}@gouv.nc"
  description = "Groupe permettant la gestion des ressources du projet "
}

resource "googleworkspace_group_settings" "grp-wks" {
  email                 = googleworkspace_group.grp-wks.email
  allow_web_posting     = false
  who_can_post_message  = "ANYONE_CAN_POST"
  who_can_contact_owner = "ALL_MEMBERS_CAN_CONTACT"
}

resource "googleworkspace_group_member" "grp-wks-member" {
  count    = length(var.pj_bq_adm_ls)
  group_id = googleworkspace_group.grp-wks.id
  email = var.pj_bq_adm_ls[count.index]
  role = "OWNER"
}

# bq viewers
resource "googleworkspace_group" "grp-wks-viewer" {
  email       = "${var.group_name}-viewers@gouv.nc"
  description = "Groupe permettant d'ajouter des membres avec permissions en lecture BigQuery"
}

resource "googleworkspace_group_settings" "grp-wks-viewer" {
  email                 = googleworkspace_group.grp-wks-viewer.email
  allow_web_posting     = false
  who_can_post_message  = "ANYONE_CAN_POST"
  who_can_contact_owner = "ALL_MEMBERS_CAN_CONTACT"
}

resource "googleworkspace_group_member" "grp-wks-member-viewer" {
  count    = length(local.pj_bq_viewer_ls)
  group_id = googleworkspace_group.grp-wks-viewer.id
  email = local.pj_bq_viewer_ls[count.index]
  role = "OWNER"
}

###############################
# Droits sur bigquery
###############################

resource "google_project_iam_member" "main" {
  for_each = toset(["group:${googleworkspace_group.grp-wks.email}", ])
  project  = module.project-factory.project_id
  role     = "roles/bigquery.studioAdmin"
  member   = each.value
}

resource "google_project_iam_member" "main-viewer" {
  for_each = toset(["group:${googleworkspace_group.grp-wks-viewer.email}", ])
  project  = module.project-factory.project_id
  role     = "roles/bigquery.resourceViewer"
  member   = each.value
}

resource "google_project_iam_member" "main-jobuser" {
  for_each = toset(["group:${googleworkspace_group.grp-wks-viewer.email}", ])
  project  = module.project-factory.project_id
  role     = "roles/bigquery.jobUser"
  member   = each.value
}

###############################
# Droits de visu sur le projet pour permettre le partage
###############################
resource "google_project_iam_member" "project-viewer" {
  project  = module.project-factory.project_id
  role     = "roles/browser"
  member   = "group:allgouv@gouv.nc"
}

###############################
# Alertes
###############################

resource "google_monitoring_notification_channel" "grp-wks" {
  display_name = "grp-wks email contact for the project"
  type         = "email"
  project      = module.project-factory.project_id

  labels = {
    email_address = googleworkspace_group.grp-wks.email
  }
  force_delete = true
}


resource "google_monitoring_notification_channel" "org_admin_contact" {
  display_name = "Organization admins email contact"
  type         = "email"
  project      = module.project-factory.project_id
  labels = {
    email_address = "gcp-organization-admins@gouv.nc"
  }
  force_delete = true
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
