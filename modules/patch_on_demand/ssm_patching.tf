resource "aws_ssm_patch_baseline" "ssm_patching" {
  name             = "patch-example-baseline"
  description      = "Amazon Linux 2023 Patch Baseline"
  operating_system = "AMAZON_LINUX_2023"
  approval_rule {
    enable_non_security = true # Set to true to install non-security updates
    approve_after_days  = 1
    patch_filter {
      key    = "CLASSIFICATION"
      values = ["*"]
    }
  }
}

resource "aws_ssm_patch_group" "ssm_patching" {
  baseline_id = aws_ssm_patch_baseline.ssm_patching.id
  patch_group = local.patching.amazon_linux.tag
}

resource "aws_ssm_maintenance_window" "patching" {
  name        = "patch-window"
  schedule    = "cron(0 11 ? * * *)" # Every Day at 11AM
  description = local.patching.amazon_linux.description
  duration    = 3
  cutoff      = 1
}

resource "aws_ssm_maintenance_window_target" "patching" {
  window_id     = aws_ssm_maintenance_window.patching.id
  resource_type = "INSTANCE"
  description   = local.patching.amazon_linux.description

  targets {
    key    = "tag:Autopatch"
    values = ["true"]
  }
}

resource "aws_ssm_maintenance_window_task" "patching" {
  name            = "EC2-Maintenance-Window"
  window_id       = aws_ssm_maintenance_window.patching.id
  description     = local.patching.amazon_linux.description
  task_type       = "RUN_COMMAND"
  task_arn        = "AWS-RunPatchBaseline"
  priority        = 1
  max_concurrency = "100%"
  max_errors      = "100%"

  targets {
    key    = "WindowTargetIds"
    values = [aws_ssm_maintenance_window_target.patching.id]
  }

  task_invocation_parameters {
    run_command_parameters {
      comment          = "Amazon Linux 2023 Patch Baseline Install"
      document_version = "$LATEST"
      timeout_seconds  = 3600
      cloudwatch_config {
        cloudwatch_log_group_name = aws_cloudwatch_log_group.patching.id
        cloudwatch_output_enabled = true
      }
      parameter {
        name   = "Operation"
        values = ["Install"]
      }
    }
  }
}

resource "aws_cloudwatch_log_group" "patching" {
  name              = "AL2023Patching"
  retention_in_days = var.cloudwatch_log_retention
}

# Auto Update SSM agents on existing instances
resource "aws_ssm_association" "update_ssm_agent" {
  name                = "AWS-UpdateSSMAgent"
  association_name    = "CustomAutoUpdateSSMAgent"
  schedule_expression = "cron(0 12 ? * * *)" // Every Day at 12 UTC */
  max_concurrency     = "100%"
  max_errors          = "100%"

  targets {
    key    = "tag:AutoPatch"
    values = ["true"]
  }
}