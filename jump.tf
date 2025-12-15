resource "aws_instance" "jump_server" {
  ami           = "ami-068c0051b15cdb816"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.subnet3.id
  associate_public_ip_address = true  # Assign a public IP to communicate with it bec it is in public subnet
  vpc_security_group_ids = [aws_security_group.jump_sg.id] # Attach the security group created for jump server
  key_name = "newkey"
  tags = {
    Name = "jump_server"
  }
}