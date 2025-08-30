terraform {
  required_version = "1.12"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}


# variable "ssh_pub_key" {
# https://spacelift.io/blog/terraform-path
# This dosen't work because of path filename only work for current pwd, but you can change it apprently.
# from doc:
# #data "local_file" "foo" {
#   filename = "${path.module}/foo.bar"
# }
# https://developer.hashicorp.com/terraform/language/expressions/references#filesystem-and-workspace-info

# https://discuss.hashicorp.com/t/accessing-a-file-from-outside-terraform/6294/2
data "local_file" "ssh_pub_key" {
  filename = "${path.module}/../../../.ssh/your_key_name.pub"
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "alpine_ssh" {
  name = "alpine-ssh"  # Ensure correct image name or local build tag
  build {
    context    = "."
    dockerfile = "alpine_ssh"  # Ensure the correct Dockerfile path
    build_args = {
      ssh_pub_key = data.local_file.ssh_pub_key.content
    }
    tag        = ["alpine-ssh"]  # Ensure correct tagging
  }
}

resource "docker_container" "foo" {
  count = 3
  image = docker_image.alpine_ssh.name
  name  = "foo-${count.index}"
  command = [
    "sleep",
    "infinity",
  ]
  ports {
    internal = 80
    external = 2200 + count.index
  }
  // Environment variables for container configuration
  env = [
    "USER_NAME=messium",
    "EDITOR=nvim",
    "ssh_pub_key=${data.local_file.ssh_pub_key.content}"
  ]
}

output "container_info" {
  value = [
    for container in docker_container.foo :
    {
      name       = container.name
      ip_address = container.network_data[0].ip_address
    }
  ]
}
