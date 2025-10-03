# To attach to the EC2 instance

data "aws_iam_policy_document" "ec2-assume-role" {
  statement {
    sid     = "AssumeServiceRole"
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_ssm" {
  name               = "EC2SSMRole"
  description        = "Role to allow SSM"
  assume_role_policy = data.aws_iam_policy_document.ec2-assume-role.json
}

resource "aws_iam_instance_profile" "ec2_ssm" {
  name = "AllowSSM"
  role = aws_iam_role.ec2_ssm.name
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_maintenance" {
  role       = aws_iam_role.ec2_ssm.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMMaintenanceWindowRole"
}


resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


locals {
  patching = {
    amazon_linux = {
      tag         = "amazon-linux"
      description = "Security Patch Tag group to target Amazon Linux instances"
    }
  }
}

data "aws_ssm_parameter" "ami_id" {
  #  name = "/aws/service/ubuntu-minimal/images/ubuntu-jammy-22.04-arm64-minimal"
  #   name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}


resource "aws_instance" "ec2_test_server" {
  ami                         = data.aws_ssm_parameter.ami_id.insecure_value # Amazon Linux 2023 AMI 2023.2.20231113.0 x86_64 HVM kernel-6.1
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm.name
  associate_public_ip_address = true
  disable_api_termination     = false
  monitoring                  = false

  root_block_device {
    volume_type           = "standard"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(var.common_tags,
    { "Autopatch" = true }
  )
}