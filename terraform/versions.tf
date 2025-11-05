terraform {
  required_version = ">= 1.0"
  
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Remote state backend configuration
  backend "gcs" {
    bucket = "mp-ai-video-terraform-state"
    prefix = "terraform/storycraft"
  }
}