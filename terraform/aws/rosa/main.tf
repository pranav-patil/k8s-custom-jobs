
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.20.0"
    }
    rhcs = {
      version = ">= 1.6.3"
      source  = "terraform-redhat/rhcs"
    }
  }
}

# Export token using the RHCS_TOKEN environment variable
provider "rhcs" {}

data "aws_caller_identity" "current" {}

provider "aws" {
  region = var.aws_region
  ignore_tags {
    key_prefixes = ["kubernetes.io/"]
  }
  default_tags {
    tags = {
      Stack = var.stack_name
    }
  }
}

data "aws_availability_zones" "available" {}

locals {
  # Extract availability zone names for the specified region, limit it to 3 if multi az or 1 if single
  region_azs = var.multi_az ? slice([for zone in data.aws_availability_zones.available.names : format("%s", zone)], 0, 3) : slice([for zone in data.aws_availability_zones.available.names : format("%s", zone)], 0, 1)
}

resource "random_string" "random_name" {
  length  = 6
  special = false
  upper   = false
}

locals {
  worker_node_replicas = var.multi_az ? 3 : 2
  cluster_name = "${var.stack_name}-ocp-cluster"
}

# The network validator requires an additional 60 seconds to validate Terraform clusters.
resource "time_sleep" "wait_60_seconds" {
  depends_on = [module.vpc]
  create_duration = "60s"
}

module "rosa-hcp" {
  source                 = "terraform-redhat/rosa-hcp/rhcs"
  version                = "1.6.4"
  cluster_name           = local.cluster_name
  openshift_version      = var.openshift_version

  compute_machine_type   = var.compute_node_instance_type
  replicas               = local.worker_node_replicas
  aws_availability_zones = local.region_azs
  private                = var.private_cluster
  aws_subnet_ids         = var.private_cluster ? module.vpc.private_subnets : concat(module.vpc.public_subnets, module.vpc.private_subnets)
  properties             = { rosa_creator_arn = data.aws_caller_identity.current.arn }

  // STS configuration
  create_account_roles  = true
  account_role_prefix   = local.cluster_name
  create_oidc           = true
  create_operator_roles = true
  operator_role_prefix  = local.cluster_name

  disable_waiting_in_destroy          = false
  wait_for_create_complete            = true
  wait_for_std_compute_nodes_complete = true

# Optional: Configure a cluster administrator user
#
# Option 1: Default cluster-admin user
# Create an administrator user (cluster-admin) and automatically
# generate a password by uncommenting the following parameter:
#  create_admin_user = true
# Generated administrator credentials are displayed in terminal output.
#
# Option 2: Specify administrator username and password
# Create an administrator user and define your own password
# by uncommenting and editing the values of the following parameters:
#  admin_credentials_username = <username>
#  admin_credentials_password = <password>

  depends_on = [time_sleep.wait_60_seconds]
}

resource "random_password" "password" {
  length      = 14
  special     = true
  min_lower   = 1
  min_numeric = 1
  min_special = 1
  min_upper   = 1
}

# ROSA IdP (Htpasswd)
module "htpasswd_idp" {
  source  = "terraform-redhat/rosa-hcp/rhcs//modules/idp"
  version    = "1.6.4"

  cluster_id = module.rosa-hcp.cluster_id
  name       = "htpasswd-idp"
  idp_type   = "htpasswd"
  htpasswd_idp_users = [
    {
      username = var.htpasswd_username
      password = random_password.password.result
    }
  ]
}
