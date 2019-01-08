terraform {
  backend "s3" {
    # TODO: Replace REGION with the region you're deploying the stack to
    # TODO: Replace NAME with the name of the stack, ie clientname-production
    # Interpolation isn't supported in `terraform` blocks, otherwise we could use
    # variables/locals

    key    = "state/ap-southeast-2/apps/mai-trial-dev"

    # Don't change these
    bucket = "hmn-terraform"
    region = "us-west-2"
  }
}

locals {
  # TODO: Change this to the name of the stack, ie clientname-production
  name = "mais-trial-dev1"

  # TODO: Likely doesn't need to change, unless the deployment repo is owned by the Client
  repo_owner = "humanmade"
}

provider "aws" {
  # TODO: Change me to the region you're launching the stack in
  region = "ap-southeast-2"
}

# Doesn't need to change!
provider "github" {
  organization = "${local.repo_owner}"
}

# Doesn't need to change!
module "region" {
  source = "git@github.com:humanmade/terraform-region-vars.git?ref=0.1.1"
}

module "app" {
  source = "git@github.com:humanmade/terraform-app-stack.git?ref=0.2.0"
  name   = "${local.name}"

  # TODO Update these values with the information you retrieved in "Preflight"
  ec2_cluster_ami                 = "ami-0ab515330b4500f3b"
  ecs_php_image_version           = "6bf9f84"
  ecs_nginx_image_version         = "8e9707c"
  cloudfront_domains              = ["mais-test.aws.hmn.md", "${local.name}.aws.hmn.md"]
  alb_acm_certificate_arn         = "arn:aws:acm:ap-southeast-2:577418818413:certificate/a09d6350-780e-4118-9666-ea2f922ce04e"
  cloudfront_acm_certificate_arn  = "arn:aws:acm:ap-southeast-2:577418818413:certificate/a09d6350-780e-4118-9666-ea2f922ce04e"
  deploy_github_repository_owner  = "${local.repo_owner}"
  deploy_github_repository_name   = "hm-base-ecs"

  # These are set and forget because they're pulled from the above "region" module
  alarm_sns_topic_arn          = "${module.region.alarm_sns_topic_arn}"
  asset_build_image_arn        = "${module.region.asset_build_image_arn}"
  asset_build_image_url        = "${module.region.asset_build_image_url}"
  bastion_security_group_id    = "${module.region.bastion_security_group_id}"
  ec2_cluster_key_name         = "${module.region.ec2_key_name}"
  ecs_nginx_image_url          = "${module.region.ecs_nginx_image_url}"
  ecs_php_image_url            = "${module.region.ecs_php_image_url}"
  s3_uploads_bucket            = "${module.region.s3_uploads_bucket}"
  tachyon_api_gateway_endpoint = "${module.region.tachyon_api_gateway_endpoint}"
  vpc_id                       = "${module.region.vpc_id}"
}
