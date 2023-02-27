resource "aws_cloudwatch_log_group" "application" {
  name              = "/ecs/sbcntr-firelens-container"
  retention_in_days = 14

  tags = {
    Name = "sbcntr-firelens-log"
  }
}