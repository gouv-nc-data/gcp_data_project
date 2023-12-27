from constructs import Construct
from cdktf import VariableType, TerraformVariable, TerraformOutput, Fn, Token, TerraformIterator
#
# Provider bindings are generated by running `cdktf get`.
# See https://cdk.tf/provider-generation for more details.
#
from imports.google.monitoring_monitored_project import MonitoringMonitoredProject
from imports.google.monitoring_notification_channel import MonitoringNotificationChannel
from imports.google.project_iam_member import ProjectIamMember
from imports.google.project_service import ProjectService
from imports.googleworkspace.group import Group
from imports.googleworkspace.group_member import GroupMember
from imports.googleworkspace.group_settings import GroupSettings
import imports.GoogleCloudPlatform.cloud_foundation_fabric.modules.bigquery_dataset as BigqueryDataset
import imports.terraform_google_modules.google.project_factory as ProjectFactory
class MyConvertedCode(Construct):
    def __init__(self, scope, name):
        super().__init__(scope, name)
        # The following providers are missing schema information and might need manual adjustments to synthesize correctly: google, googleworkspace.
        #     For a more precise conversion please use the --provider flag in convert.
        # Terraform Variables are not always the best fit for getting inputs in the context of Terraform CDK.
        #     You can read more about this at https://cdk.tf/variables
        dataset_name = TerraformVariable(self, "dataset_name",
            description="nom du projet",
            type=VariableType.STRING
        )
        default_billing_account = TerraformVariable(self, "default_billing_account",
            description="Compte de facturation par défaut",
            type=VariableType.STRING
        )
        direction = TerraformVariable(self, "direction",
            description="Direction du projet",
            type=VariableType.STRING
        )
        group_name = TerraformVariable(self, "group_name",
            type=VariableType.STRING
        )
        org_id = TerraformVariable(self, "org_id",
            description="id de l'organisation",
            type=VariableType.NUMBER
        )
        primary_contact = TerraformVariable(self, "primary_contact",
            type=VariableType.STRING
        )
        project_name = TerraformVariable(self, "project_name",
            description="nom du projet",
            type=VariableType.STRING
        )
        secondary_contact = TerraformVariable(self, "secondary_contact",
            type=VariableType.STRING
        )
        log_project_id = "prj-p-log-and-monitor-ed1e"
        parent_folder_id = "658965356947"
        project_factory = ProjectFactory.ProjectFactory(self, "project-factory",
            activate_apis=["bigquery.googleapis.com"],
            billing_account=default_billing_account.value,
            budget_alert_spent_percents=[50, 75, 90],
            budget_amount=100,
            create_project_sa=False,
            default_service_account="delete",
            folder_id="folders/${" + parent_folder_id + "}",
            group_name=group_name.value,
            labels=[{
                "direction": direction.value
            }
            ],
            name=project_name.value,
            org_id=org_id.value,
            random_project_id=True
        )
        MonitoringNotificationChannel(self, "org_admin_contact",
            display_name="Organization admins email contact",
            labels=[{
                "email_address": "gcp-organization-admins@gouv.nc"
            }
            ],
            project=project_factory.project_id_output,
            type="email"
        )
        google_monitoring_notification_channel_primary_contact =
        MonitoringNotificationChannel(self, "primary_contact_10",
            display_name="Primary email contact for the project",
            labels=[{
                "email_address": primary_contact.value
            }
            ],
            project=project_factory.project_id_output,
            type="email"
        )
        # This allows the Terraform resource name to match the original name. You can remove the call if you don't need them to match.
        google_monitoring_notification_channel_primary_contact.override_logical_id("primary_contact")
        google_monitoring_notification_channel_secondary_contact =
        MonitoringNotificationChannel(self, "secondary_contact_11",
            display_name="Secondary email contact for the project",
            labels=[{
                "email_address": secondary_contact.value
            }
            ],
            project=project_factory.project_id_output,
            type="email"
        )
        # This allows the Terraform resource name to match the original name. You can remove the call if you don't need them to match.
        google_monitoring_notification_channel_secondary_contact.override_logical_id("secondary_contact")
        monitoring_service_monlog = ProjectService(self, "monitoring-service-monlog",
            project=project_factory.project_id_output,
            service="monitoring.googleapis.com",
            timeouts=[{
                "create": "30m",
                "update": "40m"
            }
            ]
        )
        grp_wks = Group(self, "grp-wks",
            description="Groupe permettant la gestion des ressources du projet ",
            email="${" + group_name.value + "}@gouv.nc"
        )
        GroupMember(self, "grp-wks-member1",
            email=primary_contact.value,
            group_id=grp_wks.id,
            role="OWNER"
        )
        GroupMember(self, "grp-wks-member2",
            email=secondary_contact.value,
            group_id=grp_wks.id,
            role="OWNER"
        )
        googleworkspace_group_settings_grp_wks = GroupSettings(self, "grp-wks_16",
            allow_web_posting=False,
            email=grp_wks.email,
            who_can_contact_owner="ALL_MEMBERS_CAN_CONTACT",
            who_can_post_message="ALL_MEMBERS_CAN_POST"
        )
        # This allows the Terraform resource name to match the original name. You can remove the call if you don't need them to match.
        googleworkspace_group_settings_grp_wks.override_logical_id("grp-wks")
        TerraformOutput(self, "group_email",
            value=grp_wks.email
        )
        TerraformOutput(self, "notification_channels",
            value=[google_monitoring_notification_channel_primary_contact.name, google_monitoring_notification_channel_secondary_contact.name
            ]
        )
        TerraformOutput(self, "project_id",
            value=project_factory.project_id_output
        )
        bigquery_dataset = BigqueryDataset.BigqueryDataset(self, "bigquery-dataset",
            id=dataset_name.value,
            location="EU",
            project_id=project_factory.project_id_output
        )
        MonitoringMonitoredProject(self, "projects_monitored",
            depends_on=[monitoring_service_monlog],
            metrics_scope=Fn.join("",
                Token.as_list(["locations/global/metricsScopes/", log_project_id])),
            name=project_factory.project_id_output
        )
        # In most cases loops should be handled in the programming language context and
        #     not inside of the Terraform context. If you are looping over something external, e.g. a variable or a file input
        #     you should consider using a for loop. If you are looping over something only known to Terraform, e.g. a result of a data source
        #     you need to keep this like it is.
        main_for_each_iterator = TerraformIterator.from_list(
            Token.as_any(Fn.toset(["group:${" + grp_wks.email + "}"])))
        ProjectIamMember(self, "main",
            member=main_for_each_iterator.value,
            project=project_factory.project_id_output,
            role="roles/bigquery.admin",
            for_each=main_for_each_iterator
        )
        TerraformOutput(self, "dataset_id",
            value=bigquery_dataset.dataset_id_output
        )
