resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.k8.id
  cidr_block = "10.0.1.0/24"

  tags = merge({ "Name" = "${local.base_name}-Subnet" }, local.tags)
}
