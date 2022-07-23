resource "aws_dynamodb_table" "users" {
  name         = "skillboard-users-development"
  hash_key     = "UserID"
  range_key    = "UpdatedAt"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "UserID"
    type = "S"
  }
  attribute {
    name = "UpdatedAt"
    type = "S"
  }
}