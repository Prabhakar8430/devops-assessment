resource "aws_security_group" "alb_sg" {

  name        = "${var.environment}-alb-sg"
  description = "ALB Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-alb-sg"
  }

}
resource "aws_security_group" "ecs_sg" {

  name   = "${var.environment}-ecs-sg"
  vpc_id = var.vpc_id

  ingress {

    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    security_groups = [
      aws_security_group.alb_sg.id
    ]

  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]

  }

}
resource "aws_ecs_cluster" "cluster" {

  name = "${var.environment}-cluster"

}
resource "aws_iam_role" "ecs_task_execution_role" {

  name = "${var.environment}-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Action = "sts:AssumeRole"

        Effect = "Allow"

        Principal = {

          Service = "ecs-tasks.amazonaws.com"

        }

      }

    ]

  })

}
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {

  role = aws_iam_role.ecs_task_execution_role.name

  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

}
resource "aws_ecs_task_definition" "task" {

  family = "${var.environment}-task"

  requires_compatibilities = ["FARGATE"]

  network_mode = "awsvpc"

  cpu = 256

  memory = 512

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([

    {

      name = "nginx"

      image = "nginx:latest"

      essential = true

      portMappings = [

        {

          containerPort = 80

          hostPort = 80

        }

      ]

    }

  ])

}
resource "aws_lb" "alb" {

  name = "${var.environment}-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [

    aws_security_group.alb_sg.id

  ]

  subnets = var.public_subnet_ids

}
resource "aws_lb_target_group" "tg" {

  name = "${var.environment}-tg"

  port = 80

  protocol = "HTTP"

  target_type = "ip"

  vpc_id = var.vpc_id

  health_check {

    path = "/"

    protocol = "HTTP"

  }

}
resource "aws_lb_listener" "listener" {

  load_balancer_arn = aws_lb.alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.tg.arn

  }

}
resource "aws_ecs_service" "service" {

  name = "${var.environment}-service"

  cluster = aws_ecs_cluster.cluster.id

  task_definition = aws_ecs_task_definition.task.arn

  desired_count = 2

  launch_type = "FARGATE"

  network_configuration {

    assign_public_ip = false

    security_groups = [

      aws_security_group.ecs_sg.id

    ]

    subnets = var.private_subnet_ids

  }

  load_balancer {

    target_group_arn = aws_lb_target_group.tg.arn

    container_name = "nginx"

    container_port = 80

  }

  depends_on = [

    aws_lb_listener.listener

  ]

}
