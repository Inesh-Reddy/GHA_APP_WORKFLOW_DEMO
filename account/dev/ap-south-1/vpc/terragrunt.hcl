include "root" {
  path = find_in_parent_folders()
}


locals {  
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl"))
}

terraform {
    source = "git::git@github.com:infracloudio/terraform-aws-vpc.git?ref=terragrunt-integration"

    before_hook "checkev" {
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
            "CKV_AWS_23,CKV_AWS_108,CKV_AWS_109,CKV_AWS_49,CKV_AWS_21,CKV_AWS_19,CKV_AWS_145,CKV2_AWS_6,CKV_AWS_144,CKV_AWS_18,CKV2_AWS_5,CKV_AWS_111,CKV_AWS_107,CKV_AWS_110,CKV_AWS_1"
        ]
    }
}


inputs = {
    create_vpc = true
    region = local.region_vars.locals.aws_region
    azs = local.region_vars.locals.aws_region_azs
    name = "inception-infra-demo-dev"
    // vpc_cidr = "10.7.0.0/16"
    cidr = "10.7.0.0/16"
    private_subnets = ["10.7.0.0/19", "10.7.64.0/19", "10.7.128.0/19"]
    public_subnets = ["10.7.32.0/19", "10.7.96.0/19", "10.7.160.0/19"]
    enable_nat_gateway = true
    single_nat_gateway = true
    tags = {
      Owner     = "DhruvInception"
      terraform = true
    }
    enable_flow_log = false
    create_flow_log_cloudwatch_iam_role = false
    create_flow_log_cloudwatch_log_group = false
    flow_log_max_aggregation_interval = 60
    vpc_flow_log_tags = {
      Name = "vpc-flow-logs-cloudwatch-logs-default"
    }
    enable_public_dedicated_network_acl  = true
    enable_private_dedicated_network_acl = true
    public_inbound_acl_rules = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]

    public_outbound_acl_rules = [
      {
        rule_number = 130
        rule_action = "allow"
        protocol    = "all"
        cidr_block  = "0.0.0.0/0"
      },
    ]


    private_inbound_acl_rules = [
      {
        rule_number = 100
        rule_action = "allow"
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 110
        rule_action = "allow"
        from_port   = 443
        to_port     = 443
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
      {
        rule_number = 120
        rule_action = "allow"
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    private_outbound_acl_rules = [
      {
        rule_number = 130
        rule_action = "allow"
        protocol    = "all"
        cidr_block  = "0.0.0.0/0"
      },
    ]
    create_vpc_endpoints = false
    endpoint_subnet = "private"
}