resource "aws_security_group" "sg" {
  name        = "${local.base_name}-SecurityGroup"
  vpc_id      = aws_vpc.k8.id
  description = "Allow TLS inbound traffic"

  ingress {
    description = "Custom TCP"
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr, var.cluster_cidr]
  }

  ingress {
    description = "Custom TCP"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = [var.subnet_cidr, var.cluster_cidr]
  }

  ingress {
    description = "Custom TCP"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge({ "Name" : "${local.base_name}-SecurityGroup" }, local.tags)
}
