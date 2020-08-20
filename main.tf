variable "github_oauth_token_id" {
  type = string
}

variable "tfe_token" {
  type = string
}

terraform {
  required_version = "~> 0.13.0"

  backend "remote" {
    organization = "VoxPupuli"

    workspaces {
      name = "terraform_cloud"
    }
  }
}

provider "tfe" {
  version  = "~> 0.21.0"
  hostname = "app.terraform.io"
  token    = var.tfe_token
}

resource "tfe_organization" "voxpupuli" {
  name  = "VoxPupuli"
  email = "pmc@voxpupuli.org"
}

resource "tfe_workspace" "voxpupuli" {
  name         = "github-voxpupuli"
  organization = "VoxPupuli"
  operations   = false
}

resource "tfe_workspace" "secpupuli" {
  name         = "github-secpupuli"
  organization = "VoxPupuli"
  operations   = false
}

resource "tfe_workspace" "terraform_cloud" {
  name              = "terraform_cloud"
  organization      = "VoxPupuli"
  operations        = true
  terraform_version = "0.13.0"
  vcs_repo {
    identifier     = "secpupuli/tf-terraform-cloud"
    branch         = "main"
    oauth_token_id = var.github_oauth_token_id
  }
}
