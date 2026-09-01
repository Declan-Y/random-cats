resource "aws_security_group" "alb-sg" {
  name        = "alb-sg"
  description = "Security group for the ALB"
  vpc_id      = aws_vpc.random-cats.id
}

resource "aws_security_group" "web-sg" {
  name        = "web-sg"
  description = "Security group for the web server"
  vpc_id      = aws_vpc.random-cats.id
}

resource "aws_security_group" "server-sg" {
  name        = "server-sg"
  description = "Security group for the server"
  vpc_id      = aws_vpc.random-cats.id
}

resource "aws_vpc_security_group_ingress_rule" "alb_from_internet" {
  security_group_id = aws_security_group.alb-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_to_web" {
  security_group_id            = aws_security_group.alb-sg.id
  referenced_security_group_id = aws_security_group.web-sg.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

resource "aws_vpc_security_group_egress_rule" "alb_to_server" {
  security_group_id            = aws_security_group.alb-sg.id
  referenced_security_group_id = aws_security_group.server-sg.id
  from_port                    = 8000
  ip_protocol                  = "tcp"
  to_port                      = 8000
}

resource "aws_vpc_security_group_ingress_rule" "web_from_alb" {
  security_group_id            = aws_security_group.web-sg.id
  referenced_security_group_id = aws_security_group.alb-sg.id
  from_port                    = 8080
  ip_protocol                  = "tcp"
  to_port                      = 8080
}

resource "aws_vpc_security_group_egress_rule" "web_egress_all" {
  security_group_id = aws_security_group.web-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_ingress_rule" "server_from_alb" {
  security_group_id            = aws_security_group.server-sg.id
  referenced_security_group_id = aws_security_group.alb-sg.id
  from_port                    = 8000
  ip_protocol                  = "tcp"
  to_port                      = 8000
}

resource "aws_vpc_security_group_egress_rule" "server_egress_all" {
  security_group_id = aws_security_group.server-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
