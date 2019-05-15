terraform {
  backend "gcs" {}
}

variable "serviceaccount_key" {}
variable "project_id" {}
variable "infra_region" {}
variable "auth_user_email" {}
variable "organization_id" {}
variable "domain_name" {}
variable "cscc_source_id" {}

variable "server_grpc_allow_ranges" {
  default = "10.11.0.0/16"
}

variable "client_type" {
  default = "n1-standard-1"
}

provider "google" {
  credentials = "${var.serviceaccount_key}"
  project     = "${var.project_id}"
  region      = "${var.infra_region}"
}

module "forseti" {
  source = "./terraform-google-forseti-1.5.1"

  gsuite_admin_email = "${var.auth_user_email}"
  domain             = "${var.domain_name}"
  project_id         = "${var.project_id}"
  org_id             = "${var.organization_id}"
  network            = "forseti"
  subnetwork         = "forseti"

  composite_root_resources = ["organizations/${var.organization_id}"]
  server_grpc_allow_ranges = ["${var.server_grpc_allow_ranges}"]

  client_type = "${var.client_type}"

  cscc_violations_enabled = true
  cscc_source_id          = "${var.cscc_source_id}"
}

module "real_time_enforcer_roles" {
  source = "./terraform-google-forseti-1.5.1/modules/real_time_enforcer_roles"
  org_id = "${var.organization_id}"
  suffix = "${module.forseti.suffix}"
}

module "real_time_enforcer_organization_sink" {
  source            = "./terraform-google-forseti-1.5.1/modules/real_time_enforcer_organization_sink"
  pubsub_project_id = "${var.project_id}"
  org_id            = "${var.organization_id}"
}

module "real_time_enforcer" {
  source               = "./terraform-google-forseti-1.5.1/modules/real_time_enforcer"
  project_id           = "${var.project_id}"
  org_id               = "${var.organization_id}"
  topic                = "${module.real_time_enforcer_organization_sink.topic}"
  enforcer_viewer_role = "${module.real_time_enforcer_roles.forseti-rt-enforcer-viewer-role-id}"
  enforcer_writer_role = "${module.real_time_enforcer_roles.forseti-rt-enforcer-writer-role-id}"
  suffix               = "${module.forseti.suffix}"
}
