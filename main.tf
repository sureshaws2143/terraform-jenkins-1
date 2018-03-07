variable "jenkins_password" {
    default = "password"
    description = "Admin password for Jenkins master"
}

variable "project_id" {
    description = "the ID of Google Cloud project"
}

provider "google" {
    credentials = "${file("account.json")}"
    project = "${var.project_id}"
}

resource "google_compute_instance" "master" {
    name = "jenkins-master"
    machine_type = "n1-standard-1"
    zone = "asia-southeast1-a"

    tags = ["jenkins"]

    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-1604-lts"
        }
    }

    network_interface {
        network = "${google_compute_network.jenkins.name}"
        access_config {
        }
    }

    metadata_startup_script = "${data.template_file.master.rendered}"
}

resource "google_compute_firewall" "default" {
    name = "firewall-jenkins-master"
    network = "${google_compute_network.jenkins.name}"

    allow {
        protocol = "tcp"
        ports = ["22", "8000", "8080"]
    }

    target_tags = ["jenkins"]
}

resource "google_compute_network" "jenkins" {
    name = "network-jenkins"
}

resource "google_compute_instance" "slave" {
    name = "jenkins-slave"
    machine_type = "n1-standard-1"
    zone = "asia-southeast1-a"

    tags = ["jenkins"]

    boot_disk {
        initialize_params {
            image = "ubuntu-os-cloud/ubuntu-1604-lts"
        }
    }

    network_interface {
        network = "${google_compute_network.jenkins.name}"
        access_config {
        }
    }

    metadata_startup_script = "${data.template_file.slave.rendered}"
}

data "template_file" "master" {
    template = "${file("jenkins-master.tpl")}"

    vars {
        jenkins_password = "${var.jenkins_password}"
    }
}

data "template_file" "slave" {
    template = "${file("jenkins-slave.tpl")}"

    vars {
        jenkins_ip = "${google_compute_instance.master.network_interface.0.access_config.0.assigned_nat_ip}"
        jenkins_password = "${var.jenkins_password}"
    }
}

output "jenkins_ip" {
    value = "${google_compute_instance.master.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "jenkins_password" {
    value = "${var.jenkins_password}"
}