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

resource "aws_iam_role_policy_attachment" "ec2_ssm" {
  role       = aws_iam_role.ec2_ssm.id
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
