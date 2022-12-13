resource "aws_vpc" "k8" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags                 = merge({ "Name" = "${local.base_name}-Cluster-VPC" }, local.tags)
}

//resource "aws_vpc_dhcp_options" "option_set" {
//  domain_name         = "mc.compute.internal"
//  domain_name_servers = ["AmazonProvidedDNS"]
//  tags                = merge({ "Name" = "${local.base_name}-OptionSet" }, local.tags)
//}
//
//resource "aws_vpc_dhcp_options_association" "dns_resolver" {
//  vpc_id          = aws_vpc.k8.id
//  dhcp_options_id = aws_vpc_dhcp_options.option_set.id
//}
//
//output "dhcp_options" {
//  value = aws_vpc_dhcp_options.option_set.id
//}

resource "aws_default_vpc_dhcp_options" "default" {

}

output "dhcp_options" {
  value = aws_default_vpc_dhcp_options.default.domain_name
}
