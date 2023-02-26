# aws_ecr_repository
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
resource "aws_ecr_repository" "sbcntr_frontend" {
  name                 = "sbcntr-frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "KMS"
    # INFO: KMS default key is used if not specified
  }
}

resource "aws_ecr_repository" "sbcntr_backend" {
  name                 = "sbcntr-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "KMS"
    # INFO: KMS default key is used if not specified
  }
}