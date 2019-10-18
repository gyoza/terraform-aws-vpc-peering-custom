/* pgi custom items */

/* acceptor details */

variable acceptor_region {
  type        = string
  description = "the region that which will be accepting the peer connection"
}

variable acceptor_route_tables {
  type        = list
  description = "list of route tables on the acceptor VPC of which routes will be added"
}
/* requestor details */

variable requestor_region {
  type        = string
  description = "the region that which will be requesting the peer connection"
}

variable requestor_route_tables {
  type        = list
  description = "list of route tables on the requesting VPC of which routes will be added"
}

variable new_route_cidr_block {
  type        = string
  description = "created specified routes using supplied CIDR block"
  default     = null
}

/* original module items */

variable peer_vpc_id {
  type        = string
  description = "Peer VPC ID: string"
}

variable this_vpc_id {
  type        = string
  description = "This VPC ID: string"
}

variable auto_accept_peering {
  description = "Auto accept peering connection: bool"
  default     = false
}

variable tags {
  description = "Tags: map"
  type        = map
}

variable peer_dns_resolution {
  description = "Indicates whether a local VPC can resolve public DNS hostnames to private IP addresses when queried from instances in a peer VPC"
  default     = false
}

variable peer_link_to_peer_classic {
  description = "Indicates whether a local ClassicLink connection can communicate with the peer VPC over the VPC Peering Connection"
  default     = false
}

variable peer_link_to_local_classic {
  description = "Indicates whether a local VPC can communicate with a ClassicLink connection in the peer VPC over the VPC Peering Connection"
  default     = false
}

variable this_dns_resolution {
  description = "Indicates whether a local VPC can resolve public DNS hostnames to private IP addresses when queried from instances in a this VPC"
  default     = false
}

variable this_link_to_peer_classic {
  description = "Indicates whether a local ClassicLink connection can communicate with the this VPC over the VPC Peering Connection"
  default     = false
}

variable this_link_to_local_classic {
  description = "Indicates whether a local VPC can communicate with a ClassicLink connection in the this VPC over the VPC Peering Connection"
  default     = false
}
