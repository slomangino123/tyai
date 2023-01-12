# ----- Elastic Beanstalk -----

variable "elasticapp" {
  default = "tyai"
}
variable "beanstalkappenv" {
  default = "tyai"
}
variable "solution_stack_name" {
  type = string
}
variable "tier" {
  type = string
  default = "WebServer"
}
variable "instance_type" {}
variable "min_size" {}
variable "max_size" {}
variable "vpc_id" {}
variable "public_subnets" {}
variable "elb_public_subnets" {}
variable "loadbalancer_certificate_arn" {
  type = string
  default = "arn:aws:acm:us-east-1:836386213271:certificate/cdc6b564-d078-47d9-9536-16b00aa34765"
}


# ----- Route53 -----

variable "hosted_zone_id" {}