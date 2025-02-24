data "aws_ecr_repository" "this" {
  name = var.app_name
}

resource "aws_ecs_cluster" "this" {
  name = var.app_name
}

resource "aws_ecs_capacity_provider" "this" {
  name = "${var.app_name}-cp"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.this.arn

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 1
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "this" {
  cluster_name = aws_ecs_cluster.this.name

  capacity_providers = [aws_ecs_capacity_provider.this.name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_ecs_capacity_provider.this.name
  }
}

resource "aws_iam_role" "execution" {
  name = "${var.app_name}ExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role" "task" {
  name = "${var.app_name}TaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.app_name}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  depends_on = [ aws_nat_gateway.this ]
  family = var.app_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu = 1024
  memory = 1024

  task_role_arn = aws_iam_role.task.arn
  execution_role_arn = aws_iam_role.execution.arn

  container_definitions = jsonencode([{
    name  = var.app_name
    image = "${data.aws_ecr_repository.this.repository_url}:0.0.5"
    essential = true
    portMappings = [{
      containerPort = var.backstage_port
      hostPort      = var.backstage_port
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.this.name
        "awslogs-region"        = var.aws_region
        "awslogs-stream-prefix" = "ecs"
      }
    }
    environment = [
      {
        name  = "APP_DOMAIN"
        value = "https://${var.app_domain}"
      },
      {
        name  = "BACKSTAGE_PORT"
        value = tostring(var.backstage_port)
      },
      {
        name  = "AZ_DEVOPS_HOST"
        value = var.az_devops_host
      },
      {
        name  = "AZ_DEVOPS_ORG"
        value = var.az_devops_org
      },
      {
        name  = "AZ_DEVOPS_IDP_PROJECT"
        value = var.az_devops_project
      },
      {
        name  = "AZ_DEVOPS_ACCESS_TOKEN"
        value = var.az_devops_access_token
      },
      {
        name  = "GITHUB_OAUTH_ID"
        value = var.github_oauth_id
      },
      {
        name  = "GITHUB_OAUTH_SECRET"
        value = var.github_oauth_secret
      }
    ]
  }])
}


resource "aws_ecs_service" "this" {
  name            = "${var.app_name}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1

  # Due to small EC2 constraints, remove or set to 100 if using a bigger instance
  deployment_minimum_healthy_percent = 0

  network_configuration {
    subnets         = [data.aws_subnets.private.ids[0]]
    security_groups = [aws_security_group.app.id]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.this.name
    weight            = 100
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name = jsondecode(aws_ecs_task_definition.this.container_definitions)[0].name
    container_port   = var.backstage_port
  }

  depends_on = [aws_autoscaling_group.this]
}
