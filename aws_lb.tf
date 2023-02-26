# load balancer
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "internal" {
  name = "sbcntr-alb-internal"

  load_balancer_type = "application"
  internal           = true
  security_groups    = [aws_security_group.internal.id]
  subnets = [
    aws_subnet.application_1a.id,
    aws_subnet.application_1c.id,
  ]

  enable_deletion_protection = true


  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.id
  #     prefix  = "test-lb"
  #     enabled = true
  #   }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "blue" {
  name        = "sbcntr-tg-sbcntrdemo-blue"
  target_type = "ip"

  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    # INFO: traffic port is used as default setting
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    path                = "/healthcheck"
    matcher             = "200"
  }
}

resource "aws_lb_target_group" "green" {
  name        = "sbcntr-tg-sbcntrdemo-green"
  target_type = "ip"

  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    # INFO: traffic port is used as default setting
    enabled             = true
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    path                = "/healthcheck"
    matcher             = "200"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener
resource "aws_lb_listener" "internal" {
  load_balancer_arn = aws_lb.internal.arn
  port              = "10080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.green.arn
    order            = 1
  }
}
