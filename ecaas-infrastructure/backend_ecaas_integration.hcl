encrypt = true
bucket  = "epbr-ecaas-integration-terraform-state"
region  = "eu-west-2"
key     = "epb-ecaas-aws.tfstate"
# dynamodb_table is deprecated from Terraform 1.11.0 - replaced by use_lockfile for s3 locking
# for now we will double up and have both
dynamodb_table = "epbr-ecaas-integration-terraform-state"
use_lockfile   = true
