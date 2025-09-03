terraform{
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 6.0"
        }
    }
}

terraform {
    backend "s3" {
        bucket         = "aws-homestack-terraform-state"
        key            = "prod/terraform.tfstate"
        region         = "us-east-1"
        encrypt        = true
        use_lockfile   = true
    }
}

provider "aws" {
    region = "us-east-1"
}