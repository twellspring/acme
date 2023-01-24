resource "aws_kms_key" "key" {
  description             = "${var.application} ecs kms key"
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "lg" {
  name = var.application
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
      "name": "${local.prefix}",
      "image": "${aws_ecr_repository.repo.repository_url}:latest",
      "memory":${var.ecs_memory},
      "cpu": ${var.ecs_cpu},
      "networkMode": "awsvpc",
      "portMappings": [
        {
          "containerPort": 3000,
          "hostPort": 3000
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
            "awslogs-create-group": "true",
            "awslogs-group": "${local.prefix}_logs",
            "awslogs-region": "us-west-2",
            "awslogs-stream-application": "${var.application}"
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
    container_port   = 3000
  }

  depends_on = [aws_lb.lb]
}
