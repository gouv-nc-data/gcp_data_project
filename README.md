# Projet d'infrastructure GCP

## Introduction
Ce module vise à provisionner un projet sur Google Cloud Platform (GCP) en utilisant Terraform. 

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | n/a |
| <a name="provider_googleworkspace"></a> [googleworkspace](#provider\_googleworkspace) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_bigquery-dataset"></a> [bigquery-dataset](#module\_bigquery-dataset) | git::https://github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/bigquery-dataset | v26.0.0 |
| <a name="module_project-factory"></a> [project-factory](#module\_project-factory) | terraform-google-modules/project-factory/google | ~> 14.3 |

## Resources

| Name | Type |
|------|------|
| [google_monitoring_monitored_project.projects_monitored](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_monitored_project) | resource |
| [google_monitoring_notification_channel.org_admin_contact](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_notification_channel) | resource |
| [google_monitoring_notification_channel.primary_contact](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_notification_channel) | resource |
| [google_monitoring_notification_channel.secondary_contact](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/monitoring_notification_channel) | resource |
| [google_project_iam_member.main](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_service.monitoring-service-monlog](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource |
| [googleworkspace_group.grp-wks](https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/group) | resource |
| [googleworkspace_group_member.grp-wks-member1](https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/group_member) | resource |
| [googleworkspace_group_member.grp-wks-member2](https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/group_member) | resource |
| [googleworkspace_group_settings.grp-wks](https://registry.terraform.io/providers/hashicorp/googleworkspace/latest/docs/resources/group_settings) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_dataset_name"></a> [dataset\_name](#input\_dataset\_name) | nom du projet | `string` | n/a | yes |
| <a name="input_default_billing_account"></a> [default\_billing\_account](#input\_default\_billing\_account) | Compte de facturation par défaut | `string` | n/a | yes |
| <a name="input_direction"></a> [direction](#input\_direction) | Direction du projet | `string` | n/a | yes |
| <a name="input_group_name"></a> [group\_name](#input\_group\_name) | n/a | `string` | n/a | yes |
| <a name="input_org_id"></a> [org\_id](#input\_org\_id) | id de l'organisation | `number` | n/a | yes |
| <a name="input_primary_contact"></a> [primary\_contact](#input\_primary\_contact) | n/a | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | nom du projet | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | `"europe-west1"` | no |
| <a name="input_secondary_contact"></a> [secondary\_contact](#input\_secondary\_contact) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dataset_id"></a> [dataset\_id](#output\_dataset\_id) | n/a |
| <a name="output_group_email"></a> [group\_email](#output\_group\_email) | n/a |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | n/a |
<!-- END_TF_DOCS -->