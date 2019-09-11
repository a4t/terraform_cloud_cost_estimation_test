terraform {
  backend "remote" {
    organization = "iwanomoto"
    workspaces {
      name = "terraform_cloud_cost_estimation_test"
    }
  }
}
