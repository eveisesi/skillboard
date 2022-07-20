provider "aws" {
  region  = "us-east-1"
  profile = "ots"
  default_tags {
    tags = {
      Project = "Skillboard.Evie"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "skillboard-terraform-state-development"
    region         = "us-east-1"
    key            = "skillboard.tfstate"
    dynamodb_table = "skillboard-terraform-state-development"
    profile        = "ots"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}


resource "aws_dynamodb_table" "terraform_state" {
  name         = "skillboard-terraform-state-development"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "skillboard-terraform-state-development"
  lifecycle {
    prevent_destroy = true
  }
}
