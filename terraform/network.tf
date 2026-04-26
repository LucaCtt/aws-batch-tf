data "aws_vpc" "default" {
  count   = local.use_default_network ? 1 : 0
  default = true
}

data "aws_subnets" "default" {
  count = local.use_default_network ? 1 : 0

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}

data "aws_security_group" "default" {
  count = local.use_default_security_group ? 1 : 0

  filter {
    name   = "group-name"
    values = ["default"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default[0].id]
  }
}


locals {
  use_default_network = var.subnet_ids == null
  use_default_security_group = var.security_group_ids == null

  effective_subnet_ids         = local.use_default_network ? data.aws_subnets.default[0].ids : var.subnet_ids
  effective_security_group_ids = local.use_default_security_group ? [data.aws_security_group.default[0].id] : var.security_group_ids
}
