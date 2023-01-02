resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.k8.id
  cidr_block = var.subnet_cidr

  tags = merge({ "Name" = "${local.base_name}-Subnet" }, local.tags)
}
