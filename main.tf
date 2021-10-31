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

data "template_file" "user_data" {
  template = file("cloudinit.yaml")
}

resource "aws_instance" "minecraft" {
  ami = data.aws_ami.centos.id
  instance_type = "t2.medium"
  subnet_id = data.terraform_remote_state.vpc.outputs.vpc_id
  vpc_security_group_ids = [aws_security_group.sg_minecraft.id]
  associate_public_ip_address = true
  user_data = data.template_file.user_data.rendered
  
  tags = {
    Application = "Minecraft"
    Terraform = "True"
    HashiCorpIsCool = "True"
	Environment = var.environment_tag
  }
}

data "terraform_remote_state" "vpc" {
  backend = "remote"
  config = {
    organization = "Howes"
    workspaces = {
      name = "AWS-Landing-Zone"
    }
  }
}
