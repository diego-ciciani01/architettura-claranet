packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "instance_type" {
  default = "t2.micro"
}
variable "ssh_username" {
  default = "ec2-user"
}
variable "ami_name" {
  default = "wordpress-snapshot"
}
variable "region" {
  default = "eu-west-1"
}
variable "owners" {
  default = "amazon"
}

variable "access_key" {
  default = "access_key"
}
variable "secret_key" {
  default = "secret_key"
}
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

variable "snapshot_name" {
  default = "snapshot-wordpress"
}


source "amazon-ebs" "image" {
  ami_name = "${var.ami_name}-${local.timestamp}"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "amzn2-ami-hvm-2.*.1-x86_64-gp2"
      root-device-type    = "ebs"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  instance_type = "${var.instance_type}"
  region        = "${var.region}"
  ssh_username  = "${var.ssh_username}"
  access_key    = var.access_key
  secret_key    = var.secret_key
}


build {
  name = "snapshot-wordpress-${local.timestamp}"
  
  sources = [
    "source.amazon-ebs.image"
  ]
  provisioner "shell" {
    script = "./provisioning-wordpress.sh"
  }

  provisioner "breakpoint" {
    note = "Waiting for your verification"
  }
} 