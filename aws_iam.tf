resource "aws_iam_role" "codedeploy" {
  name        = "escCodeDeployRole"
  description = "Allows CodeDeploy to read S3 objects..."

  assume_role_policy = data.aws_iam_policy_document.codedeploy.json
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment
resource "aws_iam_role_policy_attachment" "codedeploy" {
  role       = aws_iam_role.codedeploy.id

  # ref: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/codedeploy_IAM_role.html
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

data "aws_iam_policy_document" "codedeploy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }
  }
}