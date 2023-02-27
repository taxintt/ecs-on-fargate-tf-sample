#
# frontend
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
resource "aws_ecs_cluster" "frontend" {
  name = "sbcntr-ecs-frontend-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "frontend" {
  name            = "sbcntr-ecs-frontend-service"
  cluster         = aws_ecs_cluster.frontend.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = 2

  launch_type = "FARGATE"

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform-linux-fargate.html
  platform_version = "1.4.0"

  # INFO: work 1 task at least and work 2 tasks at most
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  enable_ecs_managed_tags = true
  network_configuration {
    security_groups = [aws_security_group.front_container.id]
    subnets = [
      aws_subnet.application_1a.id,
      aws_subnet.application_1c.id,
    ]
    assign_public_ip = false
  }

  health_check_grace_period_seconds = 120
  load_balancer {
    # INFO: ARN of the Load Balancer target group to associate with the service.
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "app"
    container_port   = 80
  }

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}

# ecs task definition
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "frontend" {
  family                   = "sbcntr-frontend-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = 512
  memory = 1024

  # INFO: execution_role_arn is not specified in default setting
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  # ref: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  container_definitions = jsonencode([
    {
      name  = "app"
      image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:v1"

      # TODO: if developer needs to use private repo, configure the below section
      # see https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/private-auth.html
      # "repositoryCredentials": {
      #       "credentialsParameter": "arn:aws:secretsmanager:region:aws_account_id:secret:secret_name"
      # }
      cpu       = 256
      memory    = 512
      essential = true

      # INFO: used for ECS exec
      # see https://toris.io/2021/06/using-ecs-exec-with-readonlyrootfilesystem-enabled-containers/
      readonlyRootFilesystem = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        { "name" : "SESSION_SECRET_KEY", "value" : "41b678c65b37bf99c37bcab522802760" },
        { "name" : "APP_SERVICE_HOST", "value" : "http://${aws_lb.internal.dns_name}" },
        { "name" : "NOTIF_SERVICE_HOST", "value" : "http://${aws_lb.internal.dns_name}" }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
            "awslogs-group": "${aws_cloudwatch_log_group.application.name}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "firelens"
        }
      }
    }
  ])
}

#
# backend
#
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster
resource "aws_ecs_cluster" "backend" {
  name = "sbcntr-ecs-backend-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service
resource "aws_ecs_service" "backend" {
  name            = "sbcntr-ecs-backend-service"
  cluster         = aws_ecs_cluster.backend.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = 2

  launch_type = "FARGATE"

  # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform-linux-fargate.html
  platform_version = "1.4.0"

  # INFO: work 1 task at least and work 2 tasks at most
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  enable_ecs_managed_tags = true
  network_configuration {
    security_groups = [aws_security_group.container.id]
    subnets = [
      aws_subnet.application_1a.id,
      aws_subnet.application_1c.id,
    ]
    assign_public_ip = false
  }

  health_check_grace_period_seconds = 120
  load_balancer {
    # INFO: ARN of the Load Balancer target group to associate with the service.
    # TODO: fix me and follow the content of book
    target_group_arn = aws_lb_target_group.green.arn
    container_name   = "app"
    container_port   = 80
  }

  deployment_circuit_breaker {
    enable   = false
    rollback = false
  }

  deployment_controller {
    type = "ECS"
  }

  service_registries {
    registry_arn = aws_service_discovery_service.backend.arn
  }

  lifecycle {
    ignore_changes = [task_definition, load_balancer]
  }
}

# service registry
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service.html
resource "aws_service_discovery_service" "backend" {
  name = "sbcntr-ecs-backend-service"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.local.id

    dns_records {
      ttl  = 60
      type = "A"
    }

    # TODO: check pros of "MULTIVALUE"
    # see https://christina04.hatenablog.com/entry/ecs-service-discovery
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace
resource "aws_service_discovery_private_dns_namespace" "local" {
  name = "local"
  vpc  = aws_vpc.main.id
}

# ecs task definition
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "sbcntr-backend-def"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"

  cpu    = 512
  memory = 1024

  # INFO: execution_role_arn is not specified in default setting
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  # ref: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html
  container_definitions = jsonencode([
    {
      name = "app"

      # INFO: pull docker hub image from ECR
      # https://aws.amazon.com/jp/blogs/containers/docker-official-images-now-available-on-amazon-elastic-container-registry-public/
      # https://gallery.ecr.aws/nginx/nginx
      image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1"

      # TODO: if developer needs to use private repo, configure the below section
      # see https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/private-auth.html
      # "repositoryCredentials": {
      #       "credentialsParameter": "arn:aws:secretsmanager:region:aws_account_id:secret:secret_name"
      # }
      cpu       = 2
      memory    = 512
      essential = true

      # INFO: used for ECS exec
      # see https://toris.io/2021/06/using-ecs-exec-with-readonlyrootfilesystem-enabled-containers/
      readonlyRootFilesystem = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
            "awslogs-group": "${aws_cloudwatch_log_group.application.name}",
            "awslogs-region": "${var.region}",
            "awslogs-stream-prefix": "firelens"
        }
      }
    }
  ])
}