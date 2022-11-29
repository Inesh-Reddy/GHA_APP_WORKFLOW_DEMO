include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::git@github.com:infracloudio/terraform-aws-eks.git//modules/managed-nodegroup?ref=terragrunt-integration-2"
before_hook "checkov" {
        commands = ["plan"]
        execute = [
            "checkov",
            "-d",
            ".",
            "--quiet",
            "--skip-path",
            "/*/examples/*",
            "--framework",
            "terraform",
            "--skip-check",
            "CKV_AWS_79,CKV_AWS_23,CKV_AWS_108,CKV_AWS_109,CKV_AWS_49,CKV_AWS_21,CKV_AWS_19,CKV_AWS_145,CKV2_AWS_6,CKV_AWS_144,CKV_AWS_18,CKV2_AWS_5,CKV_AWS_111,CKV_AWS_107,CKV_AWS_110,CKV_AWS_1"
        ]
    }
}

locals {  
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

dependency "vpc" {
  config_path = "${get_terragrunt_dir()}/../vpc"

  mock_outputs = {
    vpc_id                        = "vpc-efgh5678"
    vpc_enable_dns_support        = "fd00:ec2::253"
    vpc_enable_dns_hostnames      = "www.thousandeyes.com"
    private_subnets               = ["subnet-abcd1234", "subnet-bcd1234a", ]
    public_subnets                = ["subnet-abcd12345b", "subnet-bcd12345b", ]
    nat_ids                       = "nat-abcd4321"
    nat_public_ips                = ["192.0.0.0", "192.0.0.1",]
    natgw_ids                     = "natgw-abcd2341"
    igw_id                        = "igw-lmnop4235"
    vpc_flow_log_id               = "vpc"
    vpc_flow_log_destination_arn  = "arn:aws:logs:us-east-2:919611311137:log-group:/aws/vpc-flow-log/vpc-efgh5678:*"
    vpc_flow_log_destination_type = "cloud-watch-logs"
    vpc_cidr_block                = "0.0.0.0/0"
    private_subnets_cidr_blocks   = ["0.0.0.0/0", "0.0.0.0/0"]
    public_subnets_cidr_blocks   = ["0.0.0.0/0", "0.0.0.0/0"]
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
}

inputs = {
  cluster_name                    = "inception-eks-managednode"
  eks_version                     = "1.23"
  region                          = local.region_vars.locals.aws_region
  instance_types                  = ["t3.small"]
  number_of_azs                   = 3
  desired_size                    = 1
  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  eks_read_write_role_creation    = false #creates read-write access role to cluster
  eks_read_only_role_creation     = false #creates read-only access role to cluster
  vpc_cidr                        = dependency.vpc.outputs.vpc_cidr_block
  control_plane_subnet_ids        = dependency.vpc.outputs.private_subnets
  vpc_id                          = dependency.vpc.outputs.vpc_id
  private_subnets                 = dependency.vpc.outputs.private_subnets
  public_subnets                  = dependency.vpc.outputs.public_subnets_cidr_blocks
}
