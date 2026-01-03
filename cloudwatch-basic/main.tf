resource "aws_security_group" "cloudwatch-basic-sg" {
  name        = "cloudwatch-basic-sg"
  description = "Security group for cloudwatch-basic instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "cloudwatch-basic" {
  ami                         = "ami-078abd88811000d7e"
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.cloudwatch-basic-sg.id]
}

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_alarm" {
  alarm_name          = "High_CPU_Utilization_Alarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = "15"

  dimensions = {
    InstanceId = aws_instance.cloudwatch-basic.id
  }

  alarm_description = "This alarm triggers when CPU utilization exceeds 15% for 5 minutes."
}
