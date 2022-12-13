resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.k8.id
  tags   = merge({ "Name" : "${local.base_name}-RouteTable" }, local.tags)
}

resource "aws_route_table" "rt2" {
  vpc_id = aws_vpc.k8.id
  tags   = merge({ "Name" : "${local.base_name}-RouteTable2" }, local.tags)
}

# create route for the route table and attach the internet gateway
resource "aws_route" "route" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "subnets-assoc" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}
