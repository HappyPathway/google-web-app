//--------------------------------------------------------------------
// Variables

variable "dynamic_server_pool_CHEF_CLIENT_NAME" {}
variable "dynamic_server_pool_CHEF_SERVER_URL" {}
variable "dynamic_server_pool_CHEF_VALIDATION_KEY" {}
variable "dynamic_server_pool_dns_managed_zone" {}
variable "dynamic_server_pool_domain" {}
variable "dynamic_server_pool_gc_region" {}
variable "dynamic_server_pool_gc_zone" {}

//--------------------------------------------------------------------
// Modules
module "dynamic_network" {
  source  = "app.terraform.io/Darnold-Hashicorp/dynamic-network/google"
  version = "1.0.0"

  cluster_size = 3
  role         = "consul"
}

module "dynamic_server_pool" {
  source  = "app.terraform.io/Darnold-Hashicorp/dynamic-server-pool/google"
  version = "1.2.0"

  CHEF_CLIENT_NAME    = "${var.CHEF_CLIENT_NAME}"
  CHEF_SERVER_URL     = "${var.CHEF_SERVER_URL}"
  CHEF_VALIDATION_KEY = "${var.CHEF_VALIDATION_KEY}"
  chef_env            = "_default"
  cluster_name        = "${var.chef_role}"
  cluster_size        = "${var.cluster_size}"
  hostname            = "${var.chef_role}"
  role                = "${var.chef_role}"
  subnet              = "${module.dynamic_network.subnet}"
}

module "firewall" {
  source  = "app.terraform.io/Darnold-Hashicorp/firewall/google"
  version = "1.0.0"

  network        = "${module.dynamic_network.network}"
  gc_region      = "${module.dynamic_network.gc_region}"
  google_project = "${module.dynamic_network.google_project}"
  ports          = ["80", "8000"]
  source_region  = "0.0.0.0/0"
}
