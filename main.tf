module "ssm_patching" {
  count                    = var.ssm_patching ? 1 : 0
  source                   = "./modules/patch_on_demand"
  cloudwatch_log_retention = 365
}

module "scale_down_asg" {
  count  = var.scale_down_asg ? 1 : 0
  source = "./modules/scale_down_asg"
  #     cloudwatch_log_retention = 365
  user_data            = local.user_data
}
