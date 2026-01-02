resource "aws_security_group" "ec2-basic-sg" {
  name        = "ec2-basic-sg"
  description = "Security group for ec2-basic instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2-basic" {
  ami                         = "ami-078abd88811000d7e"
  instance_type               = "t3.micro"
  key_name                    = "A4L"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2-basic-sg.id]
}
