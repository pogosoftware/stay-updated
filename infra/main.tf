####################################################################################################
### AWS
####################################################################################################
resource "aws_dynamodb_table" "stay_updated" {
  name         = local.name
  billing_mode = var.billing_mode
  hash_key     = "Name"

  attribute {
    name = "Name"
    type = "S"
  }

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}

resource "aws_iam_user" "stay_updated" {
  name = local.name
  tags = {
    Name        = local.name
    Environment = local.environment
    Type        = "GitHub"
  }
}

resource "aws_iam_access_key" "stay_updated" {
  user = aws_iam_user.stay_updated.name
}

resource "aws_iam_user_policy" "stay_updated" {
  name   = local.name
  user   = aws_iam_user.stay_updated.name
  policy = data.aws_iam_policy_document.stay_updated.json
}

####################################################################################################
### GITHUB
####################################################################################################
resource "github_repository_environment" "main" {
  repository  = data.github_repository.stay_updated.name
  environment = local.environment

  deployment_branch_policy {
    custom_branch_policies = false
    protected_branches     = true
  }
}

resource "github_actions_environment_secret" "aws_access_key_id" {
  repository      = data.github_repository.stay_updated.name
  environment     = github_repository_environment.main.environment
  secret_name     = "AWS_ACCESS_KEY_ID"
  plaintext_value = aws_iam_access_key.stay_updated.id
}

resource "github_actions_environment_secret" "aws_secret_access_key" {
  repository      = data.github_repository.stay_updated.name
  environment     = github_repository_environment.main.environment
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  encrypted_value = aws_iam_access_key.stay_updated.encrypted_secret
}
