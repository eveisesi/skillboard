##################################
######                      ######
######  Github Action OIDC  ######
######                      ######
##################################
resource "aws_iam_role" "github_actions_oidc" {
  name                 = "SkillboardGithubActionOIDC"
  description          = "Role Used by Github OIDC Provider for Skillboard Repository"
  max_session_duration = "3600"
  assume_role_policy   = data.aws_iam_policy_document.github_actions_oidc_assume_role.json
  managed_policy_arns  = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

data "aws_iam_policy_document" "github_actions_oidc_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    condition {
      test     = "StringLike"
      values   = ["repo:eveisesi/skillboard:*"]
      variable = "token.actions.githubusercontent.com:sub"
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.github.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_openid_connect_provider" "github" {
  client_id_list = concat(
    ["https://github.com/eveisesi"],
    ["sts.amazonaws.com"]
  )

  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
  url             = "https://token.actions.githubusercontent.com"
}