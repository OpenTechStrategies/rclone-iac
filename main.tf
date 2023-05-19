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

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "${file(var.PUBLIC_KEY)}"
}

resource "aws_instance" "rlcone_ec2" {
  ami           = "ami-0fcf52bcf5db7b003"
  instance_type = "t2.micro"
  key_name = aws_key_pair.deployer.key_name
  count = 4
  tags = {
    Name = "RcloneScaleTestingServer"
  }

  connection {
    type     = "ssh"
    host     = self.public_ip
    user     = "ubuntu"
    timeout  = "1m"
    private_key = "${file(var.PRIVATE_KEY)}"
  }

  provisioner "file" {
    source      = "rclone.conf"
    destination = ".config/rclone/rclone.conf"
  }

  provisioner "file" {
    source      = "provision"
    destination = "/tmp/provision"
  }

  # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision",
      "sudo /tmp/setup-lnxcfg-user",
    ]
  }

}
