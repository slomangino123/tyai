# Create elastic beanstalk application
resource "aws_elastic_beanstalk_application" "elasticapp" {
  name = var.elasticapp
}

# TODO: Add database security group access to Elastic beanstalk environment
# Create elastic beanstalk Environment
resource "aws_elastic_beanstalk_environment" "tyai" {
  name                = var.beanstalkappenv
  application         = aws_elastic_beanstalk_application.elasticapp.name
  solution_stack_name = var.solution_stack_name
  tier                = var.tier
 
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = var.vpc_id
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     =  "aws-elasticbeanstalk-ec2-role"
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     =  true
  }
 
  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", var.public_subnets)
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "MatcherHTTPCode"
    value     = "200"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "LoadBalancerType"
    value     = "application"
  }
  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = var.instance_type
  }
  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internet facing"
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MinSize"
    value     = var.min_size
  }
  setting {
    namespace = "aws:autoscaling:asg"
    name      = "MaxSize"
    value     = var.max_size
  }
  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "SystemType"
    value     = "enhanced"
  }
#   Environment Variable
#   setting {
#     namespace = "aws:elasticbeanstalk:application:environment"
#     name      = "ASPNETCORE_ENVIRONMENT"
#     value     = "Production"
#   }
  # https://github.com/cloudposse/terraform-aws-elastic-beanstalk-environment/blob/master/main.tf
  setting {
    namespace = "aws:elbv2:listener:default"
    name      = "ListenerEnabled"
    value     = false
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "ListenerEnabled"
    value     = "true"
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "Protocol"
    value     = "HTTPS"
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLCertificateArns"
    value     = var.loadbalancer_certificate_arn
  }
  setting {
    namespace = "aws:elbv2:listener:443"
    name      = "SSLPolicy"
    value     = "ELBSecurityPolicy-2016-08"
  }
  setting {
    namespace = "aws:elasticbeanstalk:environment:process:default"
    name      = "HealthCheckPath"
    value     = "/health/get"
  }
}

# Create Route53 Record
# https://github.com/hashicorp/terraform/issues/7071#issuecomment-409880845

data "aws_elastic_beanstalk_hosted_zone" "current" {}

resource "aws_route53_record" "api_alias" {
  zone_id = var.hosted_zone_id
  name    = "api"
  type    = "A"
  alias {
    name                   = "${aws_elastic_beanstalk_environment.tyai.cname}"
    zone_id                = "${data.aws_elastic_beanstalk_hosted_zone.current.id}"
    evaluate_target_health = false
  }
}