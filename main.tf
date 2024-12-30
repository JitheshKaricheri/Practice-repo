terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.82.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"

}

resource "aws_vpc" "practice-vpc" {
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "vpc-practice"
  }

}

resource "aws_subnet" "pub-sub" {
  vpc_id            = aws_vpc.practice-vpc.id
  cidr_block        = "10.0.0.0/25"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pub-sub"
  }


}

resource "aws_subnet" "priv-sub" {
  vpc_id            = aws_vpc.practice-vpc.id
  cidr_block        = "10.0.0.128/25"
  availability_zone = "us-east-1a"
  tags = {
    Name = "priv-subnt"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.practice-vpc.id

  tags = {
    Name = "pub-rt"
  }

}
resource "aws_route_table" "prv-rt" {
  vpc_id = aws_vpc.practice-vpc.id

  tags = {
    Name = "priv-rt"
  }
}

resource "aws_route_table_association" "pub-ass" {
  route_table_id = aws_route_table.pub-rt.id
  subnet_id      = aws_subnet.pub-sub.id


}
resource "aws_route_table_association" "priv-ass" {
  route_table_id = aws_route_table.prv-rt.id
  subnet_id      = aws_subnet.priv-sub.id


}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.practice-vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route" "public-route" {
  route_table_id         = aws_route_table.pub-rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id


}
resource "aws_security_group" "sg-practice" {
  name   = "allowed-traffic"
  vpc_id = aws_vpc.practice-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "all-allow"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "sg-practice"
  }

}

resource "aws_instance" "pub-inst" {
ami = "ami-01816d07b1128cd2d"
instance_type = "t2.micro"
subnet_id = aws_subnet.pub-sub.id
associate_public_ip_address = "true"
security_groups = [aws_security_group.sg-practice.id]

tags = {
  Name = "pub-instance"
}

}
resource "aws_instance" "priv-inst" {
    ami = "ami-01816d07b1128cd2d"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.priv-sub.id
    associate_public_ip_address = "true"
    security_groups = [aws_security_group.sg-practice.id]

    tags = {
      Name = "priv-instance"
    }
  
}