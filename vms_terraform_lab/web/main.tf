
# Joseph Stitt Terraform File
# USERNAME: jdstitt_stanford_edu
# XX: 10

# Define the network 
resource "google_compute_network" "vpc_network" {
  name                    = "jdstitt-stanford-edu-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "jdstitt-stanford-edu-subnet"
  ip_cidr_range = "10.0.10.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.id
}

# Define the instance 
resource "google_compute_instance" "default" {
  name         = "flask-jdstitt-stanford-edu-vm"
  machine_type = "f1-micro"
  zone         = "us-central1-a"
  tags         = ["ssh"]
  
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

resource "google_compute_firewall" "flask" {
  name = "flask-app-jdstitt-stanford-edu-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

output "Web-server-URL" {
 value = join("",["http://",google_compute_instance.default.network_interface.0.access_config.0.nat_ip,":22"])
}

