resource "aws_security_group" "alb" {
  name   = "${var.app_name}-alb-sg"
  vpc_id = data.aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "to_backstage" {
  security_group_id = aws_security_group.alb.id

  from_port   = 7007
  ip_protocol = "tcp"
  to_port     = 7007
  referenced_security_group_id = aws_security_group.app.id
}

# resource "aws_vpc_security_group_egress_rule" "alb_all" {
#   security_group_id = aws_security_group.alb.id
#
#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = -1
# }
#
# resource "aws_vpc_security_group_ingress_rule" "alb_all" {
#   security_group_id = aws_security_group.alb.id
#
#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = -1
# }

resource "aws_security_group" "app" {
  name   = "${var.app_name}-sg"
  vpc_id = data.aws_vpc.this.id
}

resource "aws_vpc_security_group_ingress_rule" "from_alb" {
  security_group_id = aws_security_group.app.id

  from_port   = 7007
  ip_protocol = "tcp"
  to_port     = 7007
  referenced_security_group_id = aws_security_group.alb.id
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.app.id

  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

# resource "aws_vpc_security_group_ingress_rule" "app_all" {
#   security_group_id = aws_security_group.app.id
#
#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = -1
# }

# resource "aws_vpc_security_group_egress_rule" "app_all" {
#   security_group_id = aws_security_group.app.id
#
#   cidr_ipv4   = "0.0.0.0/0"
#   ip_protocol = -1
# }
