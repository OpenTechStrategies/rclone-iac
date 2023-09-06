terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

variable "PUBLIC_KEY" {
    type = string
}

variable "PRIVATE_KEY" {
    type = string
}

variable "NUMBER_OF_MACHINES" {
    type = number
    default = 1
}

variable "SSH_USER" {
    type = string
    default = "ubuntu"
}

resource "aws_vpc" "mainvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.mainvpc.id
  cidr_block = "10.0.0.0/24"
  availability_zone = "us-west-2a"
  tags = {
    Name = "Default subnet for us-west-2a"
  }
}

resource "aws_internet_gateway" "my_vpc_igw" {
  vpc_id = aws_vpc.mainvpc.id
  tags = {
    Name = "Internet Gateway"
  }
}

# Routes table, accept traffic from the outside world
resource "aws_route_table" "my_vpc_us_west_2a_public" {
    vpc_id = aws_vpc.mainvpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my_vpc_igw.id
    }
    tags = {
        Name = "Public Subnet Route Table."
    }
}
resource "aws_route_table_association" "my_vpc_us_west_2a_public" {
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.my_vpc_us_west_2a_public.id
}


resource "aws_security_group" "ingress-all" {
  name = "allow-all-sg"
  vpc_id = "${aws_vpc.mainvpc.id}"
  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }

  // Terraform removes the default rule
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

 }

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file(var.PUBLIC_KEY)}"
}

resource "aws_instance" "rlcone_ec2" {
  ami           = "ami-0fcf52bcf5db7b003"
  count         = var.NUMBER_OF_MACHINES
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer.key_name
  vpc_security_group_ids = ["${aws_security_group.ingress-all.id}"]
  subnet_id = aws_subnet.public.id
  associate_public_ip_address = true
  tags = {
    Name = "RcloneScaleTestingServer"
  }

  connection {
    type     = "ssh"
    host     = self.public_ip
    user     = var.SSH_USER
    timeout  = "1m"
    private_key = "${file(var.PRIVATE_KEY)}"
  }

  provisioner "file" {
    source      = "provision"
    destination = "/tmp/provision"
  }

  provisioner "file" {
    source      = "local-provision"
    destination = "/tmp/local-provision"
  }

  # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision",
      "sudo -u ${var.SSH_USER} /tmp/provision",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/local-provision",
      "sudo -u ${var.SSH_USER} /tmp/local-provision",
    ]
  }

  provisioner "file" {
    source      = "rclone.conf"
    destination = "/home/${var.SSH_USER}/.config/rclone/rclone.conf"
  }

}
