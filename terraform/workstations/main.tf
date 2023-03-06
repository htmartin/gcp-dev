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
  #master_os_image = "ubuntu-os-cloud/ubuntu-2204-lts"
  master_os_image = "debian-cloud/debian-11"
  default_instance_type = "n2-standard-4"
}

data "terraform_remote_state" "storage" {
  backend = "gcs"
  config = {
    bucket = var.state_bucket
    prefix  = "terraform/storage/state"
  }
}

resource "google_compute_instance" "dev" {
  count        = 1
  name         = "dev-${count.index}"
  machine_type = local.default_instance_type
  zone         = var.zone

  tags = var.tags

  boot_disk {
    initialize_params {
      image = local.master_os_image

    }
  }
  scratch_disk {
    interface = "NVME" # Note: check if your OS image requires additional drivers or config to optimize NVME performance
  }
  metadata = {
    enable-oslogin = "TRUE"
  }

  network_interface {
    network = var.network
    #access_config {} # Ephemeral IP
  }

  #metadata_startup_script = file("provision.sh")
  metadata_startup_script = templatefile("provision.sh.tmpl", {
    home_ip = data.terraform_remote_state.storage.outputs.storage-node-ip-address,
    tools_ip = data.terraform_remote_state.storage.outputs.storage-node-ip-address,
  })

  service_account {
    #scopes = ["userinfo-email", "compute-ro", "storage-full"]
    scopes = ["cloud-platform"]  # too permissive for production
  }
}
