data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
resource "aws_launch_template" "lt" {
  name_prefix   = "${var.project}-${var.environment}-lt"
  image_id      = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [var.ec2_sg_id]

  user_data = base64encode(file("${path.module}/userdata.sh"))

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project}-${var.environment}-ec2"
    }
  }
}
resource "aws_autoscaling_group" "asg" {
  name = "${var.project}-${var.environment}-asg"

  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  target_group_arns = [var.target_group_arn]

  health_check_type         = "EC2"
  health_check_grace_period = 60

  tag {
    key                 = "Name"
    value               = "${var.project}-${var.environment}-asg-instance"
    propagate_at_launch = true
  }
}
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.project}-${var.environment}-scale-out"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.project}-${var.environment}-scale-in"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.asg.name
}
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project}-${var.environment}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70

  alarm_actions = [aws_autoscaling_policy.scale_out.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}
resource "aws_cloudwatch_metric_alarm" "low_cpu" {
  alarm_name          = "${var.project}-${var.environment}-low-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 30

  alarm_actions = [aws_autoscaling_policy.scale_in.arn]

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
}
