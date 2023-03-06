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
  storage_machine_type = "n2-standard-2"
  storage_os_image = "debian-cloud/debian-11"

  home_volume_size = 1024
  tools_volume_size = 1024
}

resource "google_compute_disk" "tools" {
  name  = "tools-volume"
  type  = "pd-ssd"
  zone  = var.zone
  size  = local.tools_volume_size
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}

resource "google_compute_disk" "home" {
  name  = "home-volume"
  type  = "pd-ssd"
  zone  = var.zone
  size  = local.home_volume_size
  labels = {
    environment = "dev"
  }
  physical_block_size_bytes = 4096
}

resource "google_compute_instance" "storage-node" {
  count        = 1
  name         = "storage-node-0"
  machine_type = local.storage_machine_type
  zone         = var.zone

  tags = var.tags

  boot_disk {
    initialize_params {
      image = local.storage_os_image

    }
  }
  attached_disk {
    source = google_compute_disk.tools.id
    device_name = "tools"
  }
  attached_disk {
    source = google_compute_disk.home.id
    device_name = "home"
  }
  metadata = {
    enable-oslogin = "TRUE"
  }

  network_interface {
    network = var.network
  }

  metadata_startup_script = templatefile("provision.sh.tmpl", {})

  service_account {
    scopes = ["userinfo-email", "compute-ro", "storage-full"]
    #scopes = ["cloud-platform"]  # too permissive for production
  }

  lifecycle {
    ignore_changes = [attached_disk]
  }

}
