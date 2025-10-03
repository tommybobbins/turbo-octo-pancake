
variable "common_tags" {
  description = "Common tags you want applied to all components."
  default = {
    Project   = "aws-autopatching-terraform",
    ManagedBy = "Terraform"
  }
}


variable "region" {
  default = "eu-west-2"
}

variable "prefix" {
  default = "dev1"
}

variable "project" {
  default = "turbo-octo-pancake"
}

variable "cloudwatch_log_retention" {
  description = "How long cloudwatch logs for SSM Patching are retained"
  default     = 7
}

variable "ssm_patching" {
  description = "Are we testing SSM patching ?"
  default     = false
}

variable "scale_down_asg" {
  description = "Scale down ASG nightly"
  default     = false
}
