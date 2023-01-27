resource "aws_lb" "lb" {
  name               = local.prefix
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "tg" {
  #name        = local.prefix
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = data.aws_acm_certificate.issued.arn

  default_action {
    target_group_arn = aws_lb_target_group.tg.arn
    type             = "forward"
  }
}

# resource "aws_acm_certificate" "cert" {
#   private_key       = var.tls_key
#   certificate_body  = var.tls_certificate
#   certificate_chain = var.tls_chain
#   lifecycle {
#     ignore_changes = [
#       options["certificate_transparency_logging_preference "]
#     ]
#   }
# }

data "aws_acm_certificate" "issued" {
  domain   = "wells.ws"
  statuses = ["ISSUED"]
}
