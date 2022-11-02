resource "aws_lb" "main_balancer" {
  name                             = "main-balancer-wordpress"
  internal                         = false
  load_balancer_type               = var.type_balancing
  security_groups                  = [aws_security_group.sg-load-balancer.id]
  subnets                          = [for subnet in aws_subnet.subnets_Private : subnet.id]
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.bucket
  #   prefix  = "test-lb"
  #   enabled = true
  # }

  tags = {
    Environment = "dev"
  }
}
#creazione target group 
resource "aws_lb_target_group" "my_wordpress_istance_group" {
  name        = "tf-wordpress-lb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  health_check {
    path                = "/wp-admin/setup-config.php"
    port                = 80
    interval            = var.interva_time
    timeout             = var.timeout_tg
    unhealthy_threshold = var.unhealthy_threshold_tg
    matcher             = var.status_code_sg
  }
}

resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.main_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.my_wordpress_istance_group.arn
    type             = "forward"
  }
}

