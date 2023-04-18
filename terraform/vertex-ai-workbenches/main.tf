#
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

locals {
  workbench_count = 1
  default_instance_type = "n2-standard-4"
}

data "terraform_remote_state" "network" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix  = "terraform/network/state"
  }
}

# data "terraform_remote_state" "storage" {
#   backend = "gcs"
#   config = {
#     bucket = var.state_bucket
#     prefix  = "terraform/storage/state"
#   }
# }

#resource "google_compute_instance" "gnome_workstation" {
#  count        = local.workstation_count
#  name         = "workstation-${count.index}"
#  machine_type = "n2-standard-4"
#  zone         = var.zone

#  tags = var.tags

#  boot_disk {
#    initialize_params {
#      image = local.os_image
#    }
#  }
#  metadata = {
#    enable-oslogin = "TRUE"
#  }

#  network_interface {
#    network = var.network
#    access_config {} # Ephemeral IP
#  }

#  metadata_startup_script = templatefile("provision.sh.tmpl", {
#    home_ip = "", #data.terraform_remote_state.storage.outputs.home-volume-ip-addresses[0],
#    tools_ip = "", #data.terraform_remote_state.storage.outputs.tools-volume-ip-addresses[0],
#  })

#  service_account {
#    #scopes = ["userinfo-email", "compute-ro", "storage-full"]
#    scopes = ["cloud-platform"]  # too permissive for production
#  }
#}

#resource "google_storage_bucket_object" "startup_script" {
#  #name   = "provision.sh"
#  name  = "terraform/vertex-ai-workbenches/provision.sh"
#  #source = "/images/nature/garden-tiger-moth.jpg"
#  content = templatefile("provision.sh.tmpl", {
#    home_ip = data.terraform_remote_state.storage.outputs.storage-node-ip-address,
#    tools_ip = data.terraform_remote_state.storage.outputs.storage-node-ip-address,
#  })
#  bucket = var.state_bucket
#}

resource "google_notebooks_instance" "workbench" {
  count        = local.workbench_count
  name = "workbench-${count.index}"
  location = var.zone
  machine_type = local.default_instance_type

  vm_image {
    project      = "deeplearning-platform-release"
    image_family = "tf-latest-cpu"
  }

  #instance_owners = ["admin@hashicorptest.com"]
  #service_account = "emailAddress:my@service-account.com"

  install_gpu_driver = false
  boot_disk_type = "PD_SSD"
  boot_disk_size_gb = 110

  no_public_ip = true
  #no_proxy_access = true

  network = data.terraform_remote_state.network.outputs.network_id
  subnet = data.terraform_remote_state.network.outputs.subnet_id

  labels = {
    k = "val"
  }
  tags = var.tags

  metadata = {
    terraform = "true"
    #enable-oslogin = "TRUE"
  }

  #post_startup_script = "gs://bucket/path/script"
  # so maybe
  #post_startup_script = google_storage_bucket_object.startup_script.media_link
  # or
  #post_startup_script = google_storage_bucket_object.startup_script.output_name
  # or
  #post_startup_script = "gs://${var.state_bucket}/${google_storage_bucket_object.startup_script.output_name}"

}
