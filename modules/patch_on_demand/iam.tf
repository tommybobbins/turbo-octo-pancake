
data "aws_iam_policy_document" "ssm_send_command" {
  statement {
    actions   = ["ssm:SendCommand"]
    effect    = "Allow"
    resources = ["arn:aws:ssm:${var.region}::document/AWS-RunRemoteScript"]
  }
}

resource "aws_iam_role_policy" "ssm_send" {
  name   = "PatchExampleSsmSendCommandRolePolicy"
  role   = aws_iam_role.ec2_ssm.id
  policy = data.aws_iam_policy_document.ssm_send_command.json
}