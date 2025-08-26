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


# WARNING: old no longer needed
# resource "null_resource" "python_image_build" {
#   provisioner "local-exec" {
#     command = "docker buildx build -t mycustom/python:latest ."
#   }
# }

# resource "docker_image" "openssh-server" { 
#   name = "linuxserver/openssh-server:latest"
#   # WARNING: old no longer needed
#   # depends_on = [null_resource.python_image_build]
# }


resource "docker_image" "openssh-server" {
  name = "openssh-linux"
  # https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/image#build
  build {
    context = "."
    tag     = ["openssh_server:develop"]
    build_args = {
      foo : "zoo"
    }
    label = {
      author : "zoo"
    }
  }
}

resource "docker_container" "open_ssh_containers" { 
  # count = 1
  image = docker_image.openssh-server.image_id
  name = "openssh_server"
  env = [
    "SUDO_ACCESS=true",
    "PASSWORD_ACCESS=true",

    "USER_NAME=linux",
    "USER_PASSWORD=test",
  ]
  command = [
    "sleep",
    "infinity",
  ]
  ports {
    internal = 2222
    external = 2222
  }
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


output "ssh_server" {
  value = docker_container.open_ssh_containers.name
}

output "container_info" {
  value = [
    for container in docker_container.foo :
    {
      name      = container.name
      ip_address = container.network_data[0].ip_address
    }
  ]
}
