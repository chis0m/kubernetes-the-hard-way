resource "aws_lb" "nlb" {
  name               = "${local.base_name}-NetworkLoadBalancer"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.subnet.id]

  enable_deletion_protection = false

  tags = merge({ "Name" : "${local.base_name}-NetworkLoadBalancer" }, local.tags)
}


resource "aws_lb_target_group" "tg" {
  //  health_check {
  //    interval            = 10
  //    path                = "/"
  //    protocol            = "HTTPS"
  //    timeout             = 5
  //    healthy_threshold   = 5
  //    unhealthy_threshold = 2
  //  }
  name        = "${local.base_name}-TargetGroup"
  port        = 6443
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = aws_vpc.k8.id
}

resource "aws_lb_target_group_attachment" "tg_attachment" {
  count            = 3
  target_group_arn = aws_lb_target_group.tg.arn
  target_id        = "10.0.1.2${count.index}"
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = 6443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}


# k8 cluster dns name
output "k8_ip_dns_name" {
  description = "Kubernetes IP address"
  value       = aws_lb.nlb.dns_name
}
