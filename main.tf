terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.29"
    }
  }
}

provider "aws" {
  region = data.terraform_remote_state.vpc.outputs.region
}

# Searches for a current version of CentOS 8 
data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS 8.*x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["125523088429"] 
}

# Passes Cloudinit for configuration of Minecraft server
data "template_file" "user_data" {
  template = file("${path.module}/scripts/cloudinit.yaml")
}

resource "aws_instance" "minecraft" {
  ami = data.aws_ami.centos.id
  instance_type = "t2.medium"
  subnet_id = data.terraform_remote_state.vpc.outputs.subnet_id
  vpc_security_group_ids = [var.sg_id]
  associate_public_ip_address = true
  user_data = data.template_file.user_data.rendered
  
  tags = {
    Application = "Minecraft"
    Terraform = "True"
    HashiCorpIsCool = "True"
	Environment = var.environment_tag
  }
}

# VPC workspace in Howes Org
data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "Howes"
    workspaces = {
      name = "AWS-Landing-Zone"
    }
  }
}
