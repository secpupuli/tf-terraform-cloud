variable "github_oauth_token_id" {
  type = string
}

variable "tfe_token" {
  type = string
}

variable "team_email_addresses" {
  type = list(string)
}

# 'owners' is a special team that can't be altered.
# It will always exist.
data "tfe_team" "voxpupuli-owners" {
  name         = "owners"
  organization = "VoxPupuli"
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
  name                     = "VoxPupuli"
  email                    = "pmc@voxpupuli.org"
  collaborator_auth_policy = "two_factor_mandatory"
}

resource "tfe_organization_membership" "voxpupuli_members" {
  for_each = toset(var.team_email_addresses)

  organization = "VoxPupuli"
  email        = each.key
}

resource "tfe_team_organization_member" "voxpupuli_owner_member" {
  for_each = toset(var.team_email_addresses)

  team_id                    = data.tfe_team.voxpupuli-owners.id
  organization_membership_id = tfe_organization_membership.voxpupuli_members[each.key].id
}

resource "tfe_workspace" "voxpupuli" {
  name              = "github-voxpupuli"
  organization      = "VoxPupuli"
  operations        = true
  terraform_version = "0.13.0"
  vcs_repo {
    identifier     = "secpupuli/tf-voxpupuli"
    branch         = "main"
    oauth_token_id = var.github_oauth_token_id
  }
}

resource "tfe_workspace" "secpupuli" {
  name              = "github-secpupuli"
  organization      = "VoxPupuli"
  operations        = true
  terraform_version = "0.13.0"
  vcs_repo {
    identifier     = "secpupuli/tf-secpupuli"
    branch         = "main"
    oauth_token_id = var.github_oauth_token_id
  }
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
