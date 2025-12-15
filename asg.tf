# Create Launch Template (instead of Launch Configuration)
resource "aws_launch_template" "app_lt" {
  name_prefix   = "app-lt-"
  image_id      = "ami-068c0051b15cdb816"
  instance_type = "t3.micro"
  key_name      = "newkey"

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y python3
              echo "Hello, World from ASG, $(hostname -f)" > /home/ec2-user/index.html
              cd /home/ec2-user
              python3 -m http.server 80 &
              EOF
  )

  lifecycle {
    create_before_destroy = true
  }
}

# Create Auto Scaling Group
resource "aws_autoscaling_group" "app_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 2
  vpc_zone_identifier = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  target_group_arns   = [aws_alb_target_group.app_tg.arn]

  launch_template {
    id      = aws_launch_template.app_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "app_server"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}