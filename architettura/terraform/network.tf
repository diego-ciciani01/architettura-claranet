resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "network-resource"
  }
}

resource "aws_subnet" "subnets_Private" {
  count  = length(var.subnets_cidr_Private)
  vpc_id = aws_vpc.main.id

  cidr_block              = element(var.subnets_cidr_Private, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {

    Name = "My-Subnet-${count.index + 1}-private"
  }

}

resource "aws_subnet" "subnets_Pubblic" {
  count  = length(var.subnets_cidr_Pubblic)
  vpc_id = aws_vpc.main.id

  cidr_block              = element(var.subnets_cidr_Pubblic, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {

    Name = "My-Subnet-${count.index + 1}-pubblic"
  }
}



resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "gw-resorce"

  }
  depends_on = ["aws_vpc.main"]
}


resource "aws_route_table" "Public_Route_Table" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  depends_on = ["aws_internet_gateway.gw"]


  tags = {
    Name = "Public-route-table"
  }
}

resource "aws_route_table" "Private_Route_Table_A" {
  vpc_id     = aws_vpc.main.id
  depends_on = ["aws_instance.Nat_istance"]
  tags = {
    Name = "private-route-table"
  }
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.Nat_istance.0.id
  }
}

resource "aws_route_table" "Private_Route_Table_B" {
  vpc_id     = aws_vpc.main.id
  depends_on = ["aws_instance.Nat_istance"]
  tags = {
    Name = "private-route-table"
  }
  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.Nat_istance.1.id
  }
}



// NAT GATEWAY ISTANCE in ec2 istance 
resource "aws_instance" "Nat_istance" {
  count                  = length(var.subnets_cidr_Pubblic)
  ami                    = data.aws_ami.nat_comunity_ami.id
  instance_type          = var.instance_type_bastianHost
  subnet_id              = element(aws_subnet.subnets_Pubblic.*.id, count.index)
  availability_zone      = element(var.availability_zones, count.index)
  vpc_security_group_ids = [aws_security_group.nat_sg.id]
  tags = {
    Name = "my-nat-${count.index + 1}-az"
  }
}

data "aws_ami" "nat_comunity_ami" {
  most_recent = true
  # owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-vpc-nat*"]
  }
}


#attaching route table to subnets created in order to provide access to internet.
resource "aws_route_table_association" "association_for_publicTable" {

  count          = length(var.subnets_cidr_Pubblic)
  subnet_id      = element(aws_subnet.subnets_Pubblic.*.id, count.index)
  route_table_id = aws_route_table.Public_Route_Table.id

}

resource "aws_route_table_association" "association_for_privateTable_A" {

  subnet_id      = aws_subnet.subnets_Private.0.id
  route_table_id = aws_route_table.Private_Route_Table_A.id

}

resource "aws_route_table_association" "association_for_privateTable_B" {

  subnet_id      = aws_subnet.subnets_Private.1.id
  route_table_id = aws_route_table.Private_Route_Table_B.id

}