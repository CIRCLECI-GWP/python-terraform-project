variable "project_name" {
  type = string
  default = "my-circleci-terraform-project"
}

variable "port_number" {
  type = string
  default = "5000"
}

variable "docker_image_tag" {
  description = "Docker image tag to deploy"
  type        = string
}


variable "boot_image_name" {
  type = string
  default = "projects/cos-cloud/global/images/cos-stable-69-10895-62-0"
}

data "google_compute_network" "default" {
  name = "default"
}

# Specify the provider (GCP, AWS, Azure)
provider "google"{
  project = var.project_name
  region = "us-central1"
}


resource "google_compute_firewall" "http-5000" {
  name    = "http-5000"
  network = data.google_compute_network.default.name

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = [var.port_number]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = data.google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_instance" "default" {
  name = "default"
  machine_type = "e2-small"
  zone = "us-central1-a"
  tags =[
      "name","default"
  ]

  boot_disk {
    auto_delete = true
    initialize_params {
      image = var.boot_image_name
      type = "pd-standard"
    }
  }

  metadata = {
    gce-container-declaration = <<EOT
spec:
  containers:
    - name: web
      image: "yemiwebby/python-cicd-terraform:${var.docker_image_tag}"
      stdin: false
      tty: false
      ports:
        - containerPort: 5000
          hostPort: 5000
  restartPolicy: Always
EOT
  }

  labels = {
    container-vm = "cos-stable-69-10895-62-0"
    deploy_id    = formatdate("20060102150405", timestamp())
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }
}

output "Public_IP_Address" {
  value = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}
