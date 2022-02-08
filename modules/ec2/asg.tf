# Launch config for ASG
resource "aws_launch_configuration" "asg_conf" {
  name            = "ASG-Conf-${var.env}"
  image_id        = data.aws_ami.ubuntu.id                # Get AMI from data
  instance_type   = var.instance_type                     # As default, instance type t2.micro
  security_groups = [var.sg_app.id, var.sg_alb.id]        # Security Group for APP (open 80 port)
  key_name        = aws_key_pair.asg_ec2_key.key_name     # SSH key for connection to EC2 in Auto Scaling Group
  user_data       = file("./modules/ec2/shell/apache.sh") # install apache
  # Give IAM

  lifecycle {
    create_before_destroy = true
  }

  #   tag {
  #     Name        = "Launch-Config-${var.env}"
  #     Environment = var.env
  #   }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "asg" {
  count                = length(var.private_subnet_id) # count numbers of private subnets
  name                 = "ASG-${var.env}-${count.index + 1}"
  vpc_zone_identifier  = [var.private_subnet_id[count.index]]
  launch_configuration = aws_launch_configuration.asg_conf.name
  target_group_arns    = [var.alb_target.arn]

  min_size         = 1 # Min size of creating EC2
  max_size         = 2 # Max size of creating EC2
  desired_capacity = 1 # How many instance ASG predict right now

  health_check_grace_period = 120
  health_check_type         = "ELB" # Type of helth check. Can be 'EC2' or 'ELB'
  force_delete              = true  # Delete EC2 w/o waiting all

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "Webserver-ec2-${count.index + 1}"
    propagate_at_launch = true
  }

  depends_on = [var.alb_target]
}

resource "aws_autoscaling_attachment" "asg_attachment" {
  count                  = length(aws_autoscaling_group.asg.*.id)
  autoscaling_group_name = aws_autoscaling_group.asg[count.index].name
  alb_target_group_arn   = var.alb_target.arn
}
