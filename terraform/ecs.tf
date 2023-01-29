resource "aws_kms_key" "key" {
  description             = "${var.application} ecs kms key"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "lg" {
  name = local.prefix
}

resource "aws_ecs_cluster" "cluster" {
  name = local.prefix

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.key.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.lg.name
      }
    }
  }
}

resource "aws_ecs_task_definition" "definition" {
  family                   = local.prefix
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = var.ecs_memory
  cpu                      = var.ecs_cpu
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  container_definitions    = <<DEFINITION
  [
    {
      "name": "${var.application}",
      "image": "${aws_ecr_repository.repo.repository_url}:${var.release}",
      "memory": ${var.ecs_memory},
      "cpu": ${var.ecs_cpu},
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port}
        }
      ],
      "logConfiguration": {
          "logDriver": "awslogs",
          "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.lg.name}",
              "awslogs-region": "${var.aws_region}",
              "awslogs-stream-prefix": "${var.application}"
          }
      },
      "environment": []
    }
  ]
  DEFINITION
}

resource "aws_ecs_service" "service" {
  name            = local.prefix
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.definition.arn
  launch_type     = "FARGATE"
  desired_count   = 2

  network_configuration {
    subnets          = module.vpc.private_subnets
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = var.application
    container_port   = var.container_port
  }

  depends_on = [aws_lb.lb]
}
