resource "aws_ecr_repository" "skillboard_ui" {
  name         = "skillboard-nuxt-ui"
  force_delete = true
}
