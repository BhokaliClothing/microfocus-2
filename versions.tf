terraform {
  required_version = ">= 0.12"
  
  backend "s3" {
    encrypt = true
    bucket = "ies-asean-terraform-state-bucket"
    region = "ap-southeast-1"
    key    = "microfocus/malaysia-demo.tfstate"
    dynamodb_table = "terraform_state_lock_dynamodb_table" 
  }
}