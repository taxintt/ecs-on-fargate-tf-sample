provider "aws" {
  # Configuration options
  region     = "ap-northeast-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key

  default_tags {
    tags = {
      env = "dev"
    }
  }
}

data "aws_caller_identity" "self" {}
