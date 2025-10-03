
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


variable "cloudwatch_log_retention" {
  description = "How long cloudwatch logs for SSM Patching are retained"
  default     = 7
}

variable "user_data" {
  description = "base64encoded userdata"
  default = null
}

variable "recurrence" {
  description = "Cron for reducing ASG to zero"
  default = "0 20 * * *"
}
