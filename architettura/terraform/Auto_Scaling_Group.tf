// modello di avvio
resource "aws_launch_configuration" "wordpress-config" {
  name_prefix     = "terraform-template"
  image_id        = data.aws_ami.wordpress-ami.id
  instance_type   = var.instance_type_tamplate_ami
  security_groups = [aws_security_group.sg-wordpress-istance.id]
  key_name        = aws_key_pair.generated_key_lunchconfig.key_name
  lifecycle {
    create_before_destroy = true
  }

  
}

// Prendi la ami creata da packer
data "aws_ami" "wordpress-ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["wordpress-snapshot-*"]
  }
}

resource "tls_private_key" "private_key_lanchconfig" {

  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_lunchconfig" {
  key_name   = var.key_name_lunchconfig
  public_key = tls_private_key.private_key_lanchconfig.public_key_openssh
  # salva la chiave ssh creata e la salva in locale 
  provisioner "local-exec" {
    command = <<-EOT
      echo '${tls_private_key.private_key_lanchconfig.private_key_pem}' > aws_keys_pairs_lunchconfig.pem
      chmod 600 aws_keys_pairs_lunchconfig.pem
    EOT
  }

}

resource "aws_autoscaling_group" "asg" {
  name                      = "autoscalegroup"
  max_size                  = 2
  min_size                  = 1
  desired_capacity          = 2
  health_check_grace_period = 30
  health_check_type         = "EC2"
  force_delete              = true
  termination_policies      = ["OldestInstance"]
  launch_configuration      = aws_launch_configuration.wordpress-config.name
  vpc_zone_identifier       = [for subnet in aws_subnet.subnets_Private : subnet.id]
}

resource "aws_autoscaling_attachment" "asg_attachment_tg" {
  autoscaling_group_name = aws_autoscaling_group.asg.id
  lb_target_group_arn    = aws_lb_target_group.my_wordpress_istance_group.arn
}


# resource "aws_autoscaling_policy" "mygroup_policy" {
#   name = "autoscalegroup_policy"
#   # il numero di istanze da scalare
#   scaling_adjustment = 2
#   adjustment_type    = "ChangeInCapacity"
#   // il numero di secondi dopo uno scaling completato e per il prossimo
#   cooldown               = 300
#   autoscaling_group_name = aws_autoscaling_group.asg.name
# }

# #allarme cloudwatch per scalre imbase al consumo di CPU
# resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
#   alarm_name          = "web_cpu_alarm_up"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "2"
#   # metrica utilizzata 
#   metric_name = "CPUUtilization"
#   # namespace utilizzato
#   namespace = "AWS/EC2"
#   # tempo atteso dopo per scalare
#   period    = "60"
#   statistic = "Average"
#   # utilizzo CPU threshold
#   threshold = "10"
#   alarm_actions = [
#     "${aws_autoscaling_policy.mygroup_policy.arn}"
#   ]
#   dimensions = {
#     AutoScalingGroupName = "${aws_autoscaling_group.asg.name}"
#   }
# }
