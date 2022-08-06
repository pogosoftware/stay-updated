terraform {
  required_version = "1.2.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.25.0"
    }
    github = {
      source  = "integrations/github"
      version = "4.28.0"
    }
  }
}
