data "aws_iam_policy_document" "stay_updated" {
  statement {
    actions = [
      "dynamodb:GetItem",
      "dynamodb:UpdateItem"
    ]

    resources = [
      aws_dynamodb_table.stay_updated.arn
    ]
  }
}

data "github_repository" "stay_updated" {
  full_name = "pogosoftware/stay-updated"
}
