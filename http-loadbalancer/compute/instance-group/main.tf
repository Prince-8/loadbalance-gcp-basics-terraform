resource "google_compute_instance" "vm_instance" {
  name         = "nginx-instance"
  machine_type = "f1-micro"

  tags = ["nginx-instance"]

  boot_disk {
    initialize_params {
      image = "centos-7-v20210420"
    }
  }

  metadata_startup_script = <<EOT
curl -fsSL https://get.docker.com -o get-docker.sh && 
sudo sh get-docker.sh && 
sudo service docker start && 
docker run -p 8080:80 -d nginxdemos/hello
EOT

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.private_network.self_link    
    # access_config {
    #   network_tier = "STANDARD"
    # }
  }
}

resource "google_compute_instance" "vm_instance_2" {
  name         = "nginx-instance-2"
  machine_type = "f1-micro"

  tags = ["nginx-instance"]

  boot_disk {
    initialize_params {
      image = "centos-7-v20210420"
    }
  }

  metadata_startup_script = <<EOT
curl -fsSL https://get.docker.com -o get-docker.sh && 
sudo sh get-docker.sh && 
sudo service docker start && 
docker run -p 8080:80 -d nginxdemos/hello
EOT

  network_interface {
    network = google_compute_network.vpc_network.self_link
    subnetwork = google_compute_subnetwork.private_network.self_link    
    # access_config {
    #   network_tier = "STANDARD"
    # }
  }
}

# resource "google_compute_firewall" "public_ssh" {
#   name    = "public-ssh"
#   network = google_compute_network.vpc_network.self_link

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }

#   direction = "INGRESS"
#   source_ranges = ["0.0.0.0/0"]
#   target_tags = ["nginx-instance"]
# }


resource "google_compute_instance_group" "webservers" {
  name        = "terraform-webservers"
  description = "Terraform test instance group"

  instances = [
    google_compute_instance.vm_instance.self_link,
    google_compute_instance.vm_instance_2.self_link
  ]

  named_port {
    name = "http"
    port = "8080"
  }
}