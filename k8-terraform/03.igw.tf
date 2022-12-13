resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.k8.id
  tags   = merge({ "Name" : "${local.base_name}-IGW" }, local.tags)
}
