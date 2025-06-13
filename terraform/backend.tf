terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "devops-project-tf-state-1749758850" # This is the name of the bucket you created Jenkins
    key            = "eks-cluster/terraform.tfstate"
    region         = "us-east-1"           # ← literal string here
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}