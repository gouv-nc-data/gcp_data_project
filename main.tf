locals {
  parent_folder_id = "658965356947" # production folder
  log_project_id   = "prj-p-log-and-monitor-ed1e"
  pj_bq_viewer_ls  = var.pj_bq_viewer_ls == null ? var.pj_bq_adm_ls : var.pj_bq_viewer_ls
  pj_bq_editor_ls  = var.pj_bq_editor_ls == null ? var.pj_bq_adm_ls : var.pj_bq_editor_ls
}

module "project-factory" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 14.3"
  name                        = var.project_name
  org_id                      = var.org_id
  billing_account             = var.default_billing_account
  group_name                  = "${var.group_name}-admin"
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
    "logging.googleapis.com"
  ]
  # deletion_policy = "DELETE" # compatibility update 16>17
}

module "bigquery-dataset" {
  count = var.dataset_name != null ? 1 : 0

  source     = "git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/bigquery-dataset?ref=v26.0.0"
  project_id = module.project-factory.project_id
  id         = var.dataset_name
  location   = "EU"
}

#---------------------------------------------------------
# Groupes associés au projet
#---------------------------------------------------------

# admin
#----------------------------------
resource "googleworkspace_group" "grp-wks" {
  email       = "${var.group_name}-admin@gouv.nc"
  name        = "${var.group_name}-admin"
  description = "Groupe editeur sur le projet et admin des ressources bigquery"
}

resource "googleworkspace_group_settings" "grp-wks" {
  email                 = googleworkspace_group.grp-wks.email
  allow_web_posting     = false
  who_can_post_message  = "ANYONE_CAN_POST"
  who_can_contact_owner = "ALL_MEMBERS_CAN_CONTACT"
  primary_language      = "en_US"
}

resource "googleworkspace_group_member" "grp-wks-member" {
  count    = length(var.pj_bq_adm_ls)
  group_id = googleworkspace_group.grp-wks.id
  email    = var.pj_bq_adm_ls[count.index]
  role     = "OWNER"
}

resource "google_project_iam_member" "main" {
  for_each = toset(["group:${googleworkspace_group.grp-wks.email}", ]) # depreciate mais plante si on change
  project  = module.project-factory.project_id
  role     = "roles/bigquery.studioAdmin"
  member   = each.value
}

# editor
#----------------------------------
resource "googleworkspace_group" "grp-wks-editor" {
  email       = "${var.group_name}-editor@gouv.nc"
  description = "Groupe avec permissions en écriture BigQuery"
}

resource "googleworkspace_group_settings" "grp-wks-editor" {
  email                 = googleworkspace_group.grp-wks-editor.email
  allow_web_posting     = false
  who_can_post_message  = "ANYONE_CAN_POST"
  who_can_contact_owner = "ALL_MEMBERS_CAN_CONTACT"
  primary_language      = "en_US"
}

resource "googleworkspace_group_member" "grp-wks-member-editor" {
  count    = length(local.pj_bq_editor_ls)
  group_id = googleworkspace_group.grp-wks-editor.id
  email    = local.pj_bq_editor_ls[count.index]
  role     = "OWNER"
}

resource "google_project_iam_member" "main-editor" {
  for_each = toset(["roles/bigquery.dataEditor", "roles/bigquery.jobUser"])
  project  = module.project-factory.project_id
  role     = each.value
  member   = "group:${googleworkspace_group.grp-wks-editor.email}"
}

# viewers
#----------------------------------
resource "googleworkspace_group" "grp-wks-viewer" {
  email       = "${var.group_name}-viewers@gouv.nc"
  description = "Groupe avec permissions en lecture BigQuery"
}

resource "googleworkspace_group_settings" "grp-wks-viewer" {
  email                  = googleworkspace_group.grp-wks-viewer.email
  allow_web_posting      = false
  allow_external_members = true
  who_can_post_message   = "ANYONE_CAN_POST"
  who_can_contact_owner  = "ALL_MEMBERS_CAN_CONTACT"
  primary_language       = "en_US"
}

resource "googleworkspace_group_member" "grp-wks-member-viewer" {
  count    = length(local.pj_bq_viewer_ls)
  group_id = googleworkspace_group.grp-wks-viewer.id
  email    = local.pj_bq_viewer_ls[count.index]
  role     = "OWNER"
}

resource "google_project_iam_member" "main-viewer" {
  for_each = toset(["roles/bigquery.dataViewer", "roles/bigquery.jobUser"])
  project  = module.project-factory.project_id
  role     = each.value
  member   = "group:${googleworkspace_group.grp-wks-viewer.email}"
}

#---------------------------------------------------------
# Droits sur le projet entier pour tout le GNC
#---------------------------------------------------------
resource "google_project_iam_member" "project-viewer" {
  project = module.project-factory.project_id
  role    = "roles/browser"
  member  = "group:allgouv@gouv.nc"
}

resource "google_project_iam_member" "project-jobUser" {
  project = module.project-factory.project_id
  role    = "roles/bigquery.jobUser" # pour avoir jobs.create, n'est pas permissif tant que l'user n'est pas viewer de la donnée
  member  = "group:allgouv@gouv.nc"
}

#---------------------------------------------------------
# Alertes
#---------------------------------------------------------

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

#---------------------------------------------------------
# Logging
#---------------------------------------------------------

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
