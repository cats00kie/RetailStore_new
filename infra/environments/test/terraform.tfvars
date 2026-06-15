environment  = "test"
cluster_name = "retailstore-test"
vpc_name     = "retailstore-vpc-test"

vpc_cidr_block       = "10.1.0.0/16"
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.3.0/24", "10.1.4.0/24"]
availability_zones   = ["us-east-1a", "us-east-1b"]

desired_count = 1

# db_password se pasa como variable de entorno TF_VAR_db_password
