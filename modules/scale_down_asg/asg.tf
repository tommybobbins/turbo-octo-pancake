data "aws_ssm_parameter" "ami_id" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}



resource "aws_launch_template" "template" {
  name_prefix   = "test"
  image_id      = data.aws_ssm_parameter.ami_id.insecure_value
  instance_type = "t2.micro"
  user_data            = var.user_data
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_ssm.name 
  }
}



resource "aws_autoscaling_group" "autoscale" {
  name                 = "test-autoscaling-group"
  availability_zones   = ["${var.region}a"]
  desired_capacity     = 1
  max_size             = 1
  min_size             = 0
  health_check_type    = "EC2"
  termination_policies = ["OldestInstance"]
  #   vpc_zone_identifier   = ["subnet-12345678"]

  launch_template {
    id      = aws_launch_template.template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  scheduled_action_name = "nightly-scale-down"
  min_size             = 0
  max_size             = 1 
  desired_capacity     = 0 
  recurrence           = try(var.recurrence, "0 20 * * *")
  #recurrence           = "0 20 * * *"
  #recurrence           = var.recurrence
  autoscaling_group_name = aws_autoscaling_group.autoscale.name
}
