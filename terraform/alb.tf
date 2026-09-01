resource "aws_lb" "random_cats_alb" {
  name               = "random-cats-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [aws_subnet.public_subnet.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "random-cats-alb"
  }
}

resource "aws_lb_target_group" "web-tg" {
  name        = "web-tg"
  port        = 8080
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.random-cats.id

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group" "server-tg" {
  name        = "server-tg"
  port        = 8000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.random-cats.id

  health_check {
    path = "/api/health"
  }
}

resource "aws_lb_listener" "random_cats_listener" {
  load_balancer_arn = aws_lb.random_cats_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-tg.arn
  }
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.random_cats_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.server-tg.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}
