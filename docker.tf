terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Pulls the image
resource "docker_image" "ubuntu" {
  name = "ubuntu:latest"
}

# Create a container
resource "docker_container" "foo" {
  count = 3
  image = docker_image.ubuntu.image_id
  name  = "foo-${count.index}"
  command = [
    "sleep",
    "infinity",
  ]
  ports {
    internal = 80
    # external = tonumber("8080${count.index}")
    external = 8080 + count.index
  }
}


# output "docker_ip" {
#   value = docker_container.foo[*].network_data[0].ip_address
# }

output "container_info" {
  value = [
    for container in docker_container.foo :
    {
      name      = container.name
      ip_address = container.network_data[0].ip_address
    }
  ]
}
