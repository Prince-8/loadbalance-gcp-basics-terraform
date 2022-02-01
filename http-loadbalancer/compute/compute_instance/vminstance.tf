 # google_compute_instance.default:
  resource "google_compute_instance" "default" {
     machine_type         = var.machinetype
     name                 = var.name
     project              = var.project_id
     tags                 = []
     zone                 = var.zone

      boot_disk {

         initialize_params {
         image  = "https://www.googleapis.com/compute/v1/projects/centos-cloud/global/images/centos-7-v20210701"
         size   = 20
         type   = "pd-balanced"
        }
      }


network_interface {
    network            = "default"
    subnetwork         = "default"
    
}
  }