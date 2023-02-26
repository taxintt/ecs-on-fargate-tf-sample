# load balancer : internal
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

  enable_deletion_protection = false
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

# load balancer : frontend
resource "aws_lb" "frontend" {
  name               = "sbcntr-alb-ingress-frontend"
  internal           = false
  load_balancer_type = "application"

  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id,
  ]

  security_groups = [
    aws_security_group.ingress.id,
  ]
}

resource "aws_lb_target_group" "frontend" {
  name        = "sbcntr-tg-frontend"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/healthcheck"
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 15
    matcher             = 200

  }
}

resource "aws_lb_listener" "frontend" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}