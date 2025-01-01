resource "aws_iam_role" "buildkit" {
  name = "buildkit"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "secrets_access" {
  name = "buildkit-secrets-access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
        ]
        Resource = "arn:aws:secretsmanager:north-eu-1:*:secret:buildkit*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "buildkit_instance_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
  role       = aws_iam_role.buildkit.name
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  policy_arn = aws_iam_policy.secrets_access.arn
  role       = aws_iam_role.buildkit.name
}

resource "aws_iam_instance_profile" "buildkit" {
  name = "buildkit"
  role = aws_iam_role.buildkit.name
}
