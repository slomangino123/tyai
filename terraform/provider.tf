provider "aws" {
  region = "us-east-1"

  # https://support.hashicorp.com/hc/en-us/articles/360041289933-Using-AWS-AssumeRole-with-the-AWS-Terraform-Provider
  assume_role {
    role_arn = "arn:aws:iam::836386213271:role/AdminRole"
  }
}