locals {
  common_tags = {
    Service = "cost-estimation-test"
    Env     = var.env
  }
  tag_name = {
    base = "${local.common_tags.Env}-${local.common_tags.Service}"
  }
  availability_zones = [
    "ap-northeast-1a",
    "ap-northeast-1c",
    "ap-northeast-1d",
  ]
}
