locals {
  prefix = "${var.environment}-backend"
}


# Log group
resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${local.prefix}"
  retention_in_days = 7

  tags = merge(var.tags, {
    Name = "${local.prefix}-logs"
  })
}


# ECS Cluster
resource "aws_ecs_cluster" "this" {
  name = "${local.prefix}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(var.tags, {
    Name = "${local.prefix}-cluster"
  })
}


# Execution Role (pull image + write logs)
resource "aws_iam_role" "execution_role" {
  name = "${local.prefix}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution_role_policy" {
  role       = aws_iam_role.execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# Task Role (permite ECS Exec)
resource "aws_iam_role" "task_role" {
  name = "${local.prefix}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_role_ssm" {
  role       = aws_iam_role.task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}


# Security Group
resource "aws_security_group" "sg" {
  name        = "${local.prefix}-sg"
  description = "SG for backend service"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${local.prefix}-sg"
  })
}


# Task Definition
resource "aws_ecs_task_definition" "this" {
  family                   = "${local.prefix}-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_cpu
  memory                   = var.ecs_memory

  execution_role_arn = aws_iam_role.execution_role.arn
  task_role_arn      = aws_iam_role.task_role.arn

  container_definitions = jsonencode([
    {
      name  = "backend"
      image = var.container_image

      portMappings = [
        {
          containerPort = var.container_port
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region        = var.aws_region
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}


# ECS Service
resource "aws_ecs_service" "this" {
  name            = "${local.prefix}-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnets
    assign_public_ip = false
    security_groups  = [aws_security_group.sg.id]
  }

  tags = merge(var.tags, {
    Name = "${local.prefix}-service"
  })
}