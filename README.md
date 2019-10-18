forked from https://github.com/grem11n/terraform-aws-vpc-peering

## INPUTS

__designed for terragrunt__

route table id inputs can be 1 or many.


```
  tags                   = <TAGS>

  auto_accept_peering    = true
  requestor_region       = "us-east-1"
  this_vpc_id            = "vpc-1234ab"
  requestor_route_tables = ["rtb-1234abd", "rtb-abd123", "rtb-abd123f"]

  acceptor_region        = "us-east-1"
  peer_vpc_id            = "vpc-abc12de"
  acceptor_route_tables  = ["rtb-abd123"]
```

## CREATE CUSTOM ROUTES (OPTIONAL)

  new route cidr block OPTIONAL - if not specified 
  will use the VPC CIDR block for the new routes


```  
  new_route_cidr_block = "/24"

```
