# Providers are required because of cross-region
provider aws {
  alias = "this"
}

provider aws {
  alias = "peer"
}

# Local Values required for inter-region peering workaround
# See https://github.com/terraform-providers/terraform-provider-aws/issues/6730
locals {
  this_region                = data.aws_region.this.name
  peer_region                = data.aws_region.peer.name
  name                       = format("vpc-peer-%s-to-%s", var.requestor_region, var.acceptor_region)
  requestor_route_tables     = var.requestor_route_tables
  acceptor_route_tables      = var.acceptor_route_tables
  
  requestor_cidr_block_regex = regex("^(.*)(?:\\/[0-9]{1,2})", data.aws_vpc.this_vpc.cidr_block)[0]
  requestor_route_cidr_block = (var.new_route_cidr_block != null ? format("%s%s", local.requestor_cidr_block_regex, var.new_route_cidr_block) : "")

  acceptor_cidr_block_regex  = regex("^(.*)(?:\\/[0-9]{1,2})", data.aws_vpc.peer_vpc.cidr_block)[0]
  acceptor_route_cidr_block  = (var.new_route_cidr_block != null ? format("%s%s", local.acceptor_cidr_block_regex, var.new_route_cidr_block) : "")

  requestor_cidr_block_route = (var.new_route_cidr_block != null ? local.requestor_route_cidr_block : data.aws_vpc.this_vpc.cidr_block)
  acceptor_cidr_block_route  = (var.new_route_cidr_block != null ? local.acceptor_route_cidr_block : data.aws_vpc.peer_vpc.cidr_block)

}

##########################
# VPC peering connection #
##########################
resource aws_vpc_peering_connection this {
  provider      = "aws.this"
  peer_owner_id = data.aws_caller_identity.peer.account_id
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = var.this_vpc_id
  peer_region   = data.aws_region.peer.name
  tags          = merge(var.tags, map("Name", local.name))
}

######################################
# VPC peering accepter configuration #
######################################
resource aws_vpc_peering_connection_accepter peer_accepter {
  provider                  = "aws.peer"
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
  auto_accept               = var.auto_accept_peering
  tags                      = merge(var.tags, map("Name", local.name))
}

#######################
# VPC peering options #
#######################
resource aws_vpc_peering_connection_options this {
  provider                  = "aws.this"
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer_accepter.id

  requester {
    allow_remote_vpc_dns_resolution  = var.this_dns_resolution
    allow_classic_link_to_remote_vpc = var.this_link_to_peer_classic
    allow_vpc_to_remote_classic_link = var.this_link_to_local_classic
  }
}

resource aws_vpc_peering_connection_options accepter {
  provider                  = "aws.peer"
  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.peer_accepter.id

  accepter {
    allow_remote_vpc_dns_resolution  = var.peer_dns_resolution
    allow_classic_link_to_remote_vpc = var.peer_link_to_peer_classic
    allow_vpc_to_remote_classic_link = var.peer_link_to_local_classic
  }
}

###################
# This VPC Routes #
###################
resource aws_route this_routes_region {
  provider                  = "aws.this"
  count                     = length(local.requestor_route_tables)
  route_table_id            = local.requestor_route_tables[count.index]
  destination_cidr_block    = local.acceptor_cidr_block_route
  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}

###################
# Peer VPC Routes #
###################
resource aws_route peer_routes_region {
  provider                  = "aws.peer"
  count                     = length(local.acceptor_route_tables)
  route_table_id            = local.acceptor_route_tables[count.index]  
  destination_cidr_block    = local.requestor_cidr_block_route

  vpc_peering_connection_id = aws_vpc_peering_connection.this.id
}
