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

variable "group_name" {
  type = string
}

variable "org_id" {
  description = "id de l'organisation"
  type        = number
}

variable "pj_contact_list" {
  type    = list(string)
  default = null
}
