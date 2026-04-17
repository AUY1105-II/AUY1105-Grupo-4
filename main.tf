# Modulo terraform vpc
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "AUY1105-${var.project_name}-vpc"
  cidr = "10.1.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}


resource "aws_security_group" "ec2_sg" {
  name        = "AUY1105-${var.project_name}-${var.environment}-ec2-sg"
  description = "EC2 SG"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Permitir SSH desde IP especifica autorizada"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }
  egress {
    description = "Permitir salida a internet para actualizaciones"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 6.1"

  name = "AUY1105-${var.project_name}-ec2"
  ami  = "ami-0ec10929233384c7f"

  instance_type = "t2.micro"
  key_name      = "vockey"
  monitoring    = true
  subnet_id     = module.vpc.public_subnets[0]

  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  tags = {
    Terraform   = "true"
    Environment = var.environment
  }
}
