terraform {
  # backend "s3" {
  #   bucket = "ecs-on-fargate-taxin-sample"
  #   key    = "terraform.tfstate"
  #   region = "ap-northeast-1"
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.55.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.4.3"
    }
  }
}