// # Indicate what region to deploy the resources into
// generate "provider" {
//   path = "provider.tf"
//   if_exists = "overwrite_terragrunt"
//   contents = <<EOF
// provider "aws" {
//   region = "us-east-1"  
// }
// EOF
// }


generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket         = "inception-terragrunt-2022"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
    dynamodb_table = "my-lock-table"
  }
}
EOF
}