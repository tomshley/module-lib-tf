module "platform_bootstrap_graph_core_graph_data" {
  source                   = "../../../bootstrap/graph/perimeters"
  platform_bootstrap_graph = var.platform_bootstrap_graph
}

locals {
  perimeters_map_values    = one(module.platform_bootstrap_graph_core_graph_data.perimeters[*])
  default_cidr_list_sliced = slice(var.default_cidr_block_pool, 0, length(local.perimeters_map_values))
  default_cidr_sliced_map  = {
    for t in local.default_cidr_list_sliced : t[0] => {
      public : t[1][0],
      private : t[1][1]
    }
  }
  perimeter_cidr_prep = zipmap(keys(local.perimeters_map_values), local.default_cidr_list_sliced)
  perimeter_cidr      = {
    for k, v in local.perimeter_cidr_prep : k => {
      fqdn : local.perimeters_map_values[k],
      cidr : v[0],
      subnets : {
        public : local.default_cidr_sliced_map[v[0]]["public"],
        private : local.default_cidr_sliced_map[v[0]]["private"]
      }
    }
  }
  public_subnets = {
    for v0 in flatten([
      for k1, v1 in local.perimeter_cidr : [for v2 in v1["subnets"]["public"] : { "${v2}" : k1 }]
    ]) : keys(v0)[0] => values(v0)[0]
  }
  private_subnets = {
    for v0 in flatten([
      for k1, v1 in local.perimeter_cidr : [for v2 in v1["subnets"]["private"] : { "${v2}" : k1 }]
    ]) : keys(v0)[0] => values(v0)[0]
  }
}

data "aws_region" "current" {}

resource "aws_servicequotas_service_quota" "vpc_quota" {
  quota_code   = "L-F678F1CE"
  service_code = "vpc"
  value        = 100
}

resource "aws_servicequotas_service_quota" "vpc_igw_quota" {
  quota_code   = "L-A4707A72"
  depends_on   = [aws_servicequotas_service_quota.vpc_quota]
  service_code = aws_servicequotas_service_quota.vpc_quota.service_code
  value        = aws_servicequotas_service_quota.vpc_quota.value
}

resource "aws_servicequotas_service_quota" "vpc_ipv4" {
  quota_code = "L-83CA0A9D"
  depends_on = [
    aws_servicequotas_service_quota.vpc_quota,
    aws_servicequotas_service_quota.vpc_igw_quota
  ]
  service_code = aws_servicequotas_service_quota.vpc_quota.service_code
  value        = 50
}


resource "aws_vpc" "vpc" {
  for_each             = local.perimeter_cidr
  enable_dns_hostnames = true
  cidr_block           = each.value["cidr"]
  instance_tenancy     = "default"
  tags = {
    Name = each.key
    FQDN = each.value["fqdn"]
  }
}

resource "aws_internet_gateway" "vpc_igw" {
  for_each = aws_vpc.vpc
  vpc_id   = each.value.id
}

resource "aws_subnet" "vpc_subnets_public" {
  for_each   = local.public_subnets
  vpc_id     = aws_vpc.vpc[each.value].id
  cidr_block = each.key
}

resource "aws_route_table" "vpc_route_table_public" {
  for_each = aws_internet_gateway.vpc_igw
  vpc_id   = each.value.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = each.value.id
  }
}
#
#resource "aws_eip" "vpc_eip" {
#  for_each   = aws_vpc.vpc
#  vpc        = true
#  depends_on = [aws_internet_gateway.vpc_igw]
#}
#
#resource "aws_nat_gateway" "vpc_nat_gw_public" {
#  for_each      = aws_subnet.vpc_subnets_public
#  allocation_id = aws_eip.vpc_eip[local.public_subnets[each.key]].id
#  subnet_id     = each.value.id
#  depends_on    = [aws_eip.vpc_eip]
#}
#
#
#resource "aws_route_table_association" "public-rt-association" {
#  for_each       = aws_subnet.vpc_subnets_public
#  subnet_id      = each.value.id
#  route_table_id = aws_route_table.vpc_route_table_public[local.public_subnets[each.key]].id
#}

#resource "aws_route_table" "vpc_route_table_public" {
#  for_each = aws_nat_gateway.vpc_nat_gw_public
#  vpc_id   = aws_subnet.vpc_subnets_public[each.key].vpc_id
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = each.value.id
#  }
#}



#resource "aws_subnet" "vpc_subnets_private" {
#  for_each   = local.private_subnets
#  vpc_id     = aws_vpc.vpc[each.value].id
#  cidr_block = each.key
#}
#resource "aws_nat_gateway" "vpc_nat_gw_private" {
#  for_each      = aws_subnet.vpc_subnets_private
#  allocation_id = aws_eip.vpc_eip.id
#  subnet_id     = each.value.id
#}
#
#resource "aws_route_table" "vpc_route_table_private" {
#  for_each = aws_nat_gateway.vpc_nat_gw_private
#  vpc_id   = aws_subnet.vpc_subnets_private[each.key].vpc_id
#  route {
#    cidr_block     = "0.0.0.0/0"
#    nat_gateway_id = each.value.id
#  }
#}

##Route table Association with Public Subnet's
#resource "aws_route_table_association" "PublicRTassociation" {
#  subnet_id      = aws_subnet.publicsubnets.id
#  route_table_id = aws_route_table.PublicRT.id
#}

##Route table Association with Private Subnet's
#resource "aws_route_table_association" "PrivateRTassociation" {
#  subnet_id      = aws_subnet.privatesubnets.id
#  route_table_id = aws_route_table.PrivateRT.id
#}

#resource "aws_eip" "vpc_eip" {
#  vpc = true
#}

#Creating the NAT Gateway using subnet_id and allocation_id
#resource "aws_nat_gateway" "vpc_nat_gw" {
#  allocation_id = aws_eip.vpc_eip.id
#  subnet_id     = aws_subnet.publicsubnets.id
#}

#resource "aws_route_table" "vpc_route_table_private" {
#  for_each = aws_internet_gateway.vpc_igw
#  vpc_id   = each.value.vpc_id
#  route {
#    cidr_block     = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
#    nat_gateway_id = aws_nat_gateway.NATgw.id
#  }
#}

#
#resource "aws_subnet" "public-subnet" {
#  depends_on = [aws_vpc.vpc]
#  for_each   = local.perimeter_subnets_public
#  vpc_id     = one([for k, v in aws_vpc.vpc : v.id if v.cidr_block == each.value])
#  cidr_block = each.key
#  assign_ipv6_address_on_creation = true
#}

#resource "aws_subnet" "private-subnet" {
#  for_each   = local.perimeter_subnets_private
#  vpc_id     = one([for k, v in aws_vpc.vpc : v.id if v.cidr_block == each.value])
#  cidr_block = each.key
#}

## Define the internet gateway
#resource "aws_internet_gateway" "gw" {
#  for_each = aws_vpc.vpc
#  vpc_id = each.value.id
#}

## Define the public route table
#resource "aws_route_table" "public-rt" {
#  for_each = aws_internet_gateway.gw
#  vpc_id = each.value.vpc_id
#  route {
#    cidr_block = "0.0.0.0/0"
#    gateway_id = each.value.id
#  }
#}

## Assign the public route table to the public subnet
#resource "aws_route_table_association" "public-rt-association" {
#  subnet_id      = aws_subnet.public-subnet.id
#  route_table_id = aws_route_table.public-rt.id
#}
