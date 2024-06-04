variable "project_name" {
  type        = string
  description = "nom du projet"
}

variable "dataset_name" {
  type        = string
  description = "nom du projet"
  default     = null
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

variable "group_name" {
  type = string
}

variable "org_id" {
  description = "id de l'organisation"
  type        = number
}

variable "pj_bq_adm_ls" {
  type    = list(string)
  default = null
}

variable "pj_bq_viewer_ls" {
  description = "liste des membres du groupe editor gérés par terraform"
  type        = list(string)
  default     = null
}

variable "pj_bq_editor_ls" {
  description = "liste des membres du groupe editor gérés par terraform"
  type        = list(string)
  default     = null
}
