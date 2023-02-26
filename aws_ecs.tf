# resource "aws_kms_key" "example" {
#   description             = "example"
#   deletion_window_in_days = 7
# }

# resource "aws_cloudwatch_log_group" "example" {
#   name = "example"
# }

# resource "aws_ecs_cluster" "test" {
#   name = "example-cluster"

#   configuration {
#     execute_command_configuration {
#       kms_key_id = aws_kms_key.example.arn
#       logging    = "OVERRIDE"

#       log_configuration {
#         cloud_watch_encryption_enabled = true
#         cloud_watch_log_group_name     = aws_cloudwatch_log_group.example.name
#       }
#     }
#   }
# }

# resource "aws_ecs_service" "example" {
#   name            = "example-app"
#   cluster         = aws_ecs_cluster.test.id
#   task_definition = aws_ecs_task_definition.service.arn
#   desired_count   = 3
#   iam_role        = aws_iam_role.foo.arn
#   depends_on      = [aws_iam_role_policy.foo]

#   ordered_placement_strategy {
#     type  = "binpack"
#     field = "cpu"
#   }

#   load_balancer {
#     target_group_arn = aws_lb_target_group.foo.arn
#     container_name   = "mongo"
#     container_port   = 8080
#   }

#   placement_constraints {
#     type       = "memberOf"
#     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
#   }
# }

# # TODO
# resource "aws_ecs_task_definition" "service" {
#   family = "service"
#   container_definitions = jsonencode([
#     {
#       name      = "first"
#       image     = "service-first"
#       cpu       = 10
#       memory    = 512
#       essential = true
#       portMappings = [
#         {
#           containerPort = 80
#           hostPort      = 80
#         }
#       ]
#     },
#     {
#       name      = "second"
#       image     = "service-second"
#       cpu       = 10
#       memory    = 256
#       essential = true
#       portMappings = [
#         {
#           containerPort = 443
#           hostPort      = 443
#         }
#       ]
#     }
#   ])

#   volume {
#     name      = "service-storage"
#     host_path = "/ecs/service-storage"
#   }

#   placement_constraints {
#     type       = "memberOf"
#     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
#   }
# }