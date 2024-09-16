
# locals {
#   #calculate the number of availability zones
#   azs = data.aws_availability_zones.available.names
# }



//create VPC
resource "aws_vpc" "hungnv-vpc" {
  cidr_block = var.cidrvpc

  tags = var.tag
}


//Create public subnet
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.hungnv-vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  count             = var.az_count
  cidr_block        = cidrsubnet(aws_vpc.hungnv-vpc.cidr_block, 8, count.index)
  tags = merge({
    Name = "${var.vpc_name}-public-subnet"
  }, var.tag)

}

//create internet gateway
resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.hungnv-vpc.id
  tags = merge({
    Name = "${var.vpc_name}-igw"
  }, var.tag)
}

resource "aws_route" "main_route" {
  route_table_id         = aws_vpc.hungnv-vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-igw.id
}

//associate route table with public subnet
resource "aws_route_table_association" "public_subnet_rtb" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_vpc.hungnv-vpc.main_route_table_id
}

//create eip 
resource "aws_eip" "nateip" {
  count = var.az_count
  tags = merge({
    ext-name = "${var.vpc_name}-eip-${count.index}"
  }, var.tag)
}

//create nat gateway
resource "aws_nat_gateway" "nat" {
  count         = var.az_count
  allocation_id = element(aws_eip.nateip.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  tags = merge({
    ext-name = "${var.vpc_name}-nat-${count.index}"
  }, var.tag)
}

//create private subnet
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.hungnv-vpc.id
  availability_zone = data.aws_availability_zones.available.names[count.index]
  count             = 3
  cidr_block        = cidrsubnet(aws_vpc.hungnv-vpc.cidr_block, 8, count.index + var.az_count)
  tags = merge({
    Name = "${var.vpc_name}-private-subnet"
  }, var.tag)

}


//create route table for private subnet
resource "aws_route_table" "private_rtb" {
  count  = var.az_count
  vpc_id = aws_vpc.hungnv-vpc.id

  #define route table for private subnet
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }
  tags = merge(
    {
      ext-name = "${var.vpc_name}-private-rtb-${count.index}"
    },
    var.tag
  )
}

//asoociate route table with private subnet
resource "aws_route_table_association" "private_subnet_rtb" {
  count          = var.az_count
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private_rtb.*.id, count.index)
}

