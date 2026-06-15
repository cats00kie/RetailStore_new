environment  = "prod"
cluster_name = "retailstore-prod"
vpc_name     = "retailstore-vpc-prod"

vpc_cidr_block       = "10.2.0.0/16"
public_subnet_cidrs  = ["10.2.1.0/24", "10.2.2.0/24"]
private_subnet_cidrs = ["10.2.3.0/24", "10.2.4.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]

desired_count = 2

# db_password se pasa como variable de entorno TF_VAR_db_password
