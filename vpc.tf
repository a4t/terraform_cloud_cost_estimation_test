resource "aws_vpc" "main" {
  cidr_block           = "${var.vpc_cidr_prefix}.0.0/16"
  enable_dns_hostnames = true
  tags = merge(local.common_tags, {
    Name : "vpc-${local.tag_name.base}"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name : "igw-${local.tag_name.base}"
  })
}

resource "aws_subnet" "public" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(local.availability_zones, count.index)
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + length(local.availability_zones) * 0)
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name : "${local.tag_name.base}-public-${element(local.availability_zones, count.index)}"
  })
}

resource "aws_subnet" "private" {
  count             = length(local.availability_zones)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(local.availability_zones, count.index)
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + length(local.availability_zones) * 1)

  tags = merge(local.common_tags, {
    Name : "${local.tag_name.base}-private-${element(local.availability_zones, count.index)}",
    Hoge : "fuga"
  })
}

resource "aws_subnet" "bastion" {
  count                   = length(local.availability_zones)
  vpc_id                  = aws_vpc.main.id
  availability_zone       = element(local.availability_zones, count.index)
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + length(local.availability_zones) * 2)
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name : "${local.tag_name.base}-bastion-${element(local.availability_zones, count.index)}"
  })
}

#resource "aws_eip" "nat" {
#  vpc = true
#}
#
#resource "aws_nat_gateway" "ngw" {
#  allocation_id = aws_eip.nat.id
#  subnet_id     = aws_subnet.bastion[0].id
#
#  tags = merge(local.common_tags, {
#    Name : "ngw-${local.tag_name.base}"
#  })
#}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name : "${local.tag_name.base}-public"
  })
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  #  route {
  #    cidr_block     = "0.0.0.0/0"
  #    nat_gateway_id = aws_nat_gateway.ngw.id
  #  }

  tags = merge(local.common_tags, {
    Name : "${local.tag_name.base}-private"
  })
}

resource "aws_route_table" "bastion" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, {
    Name : "${local.tag_name.base}-bastion"
  })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "bastion" {
  count          = length(aws_subnet.bastion)
  subnet_id      = element(aws_subnet.bastion.*.id, count.index)
  route_table_id = aws_route_table.bastion.id
}
