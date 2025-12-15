resource "aws_alb" "app_lb" {
  name               = "app-lb"
  internal           = false # to be accessible from the internet not from inside vpc 
  load_balancer_type = "application"
  subnets            = [aws_subnet.subnet3.id, aws_subnet.subnet4.id]
  security_groups   = [aws_security_group.alb_sg.id]

  tags = {
    Name = "app_lb"
  }
}

resource "aws_alb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app_tg"
  }
}

resource "aws_alb_listener" "app_lb_listener" {
  load_balancer_arn = aws_alb.app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.app_tg.arn
  }
}

