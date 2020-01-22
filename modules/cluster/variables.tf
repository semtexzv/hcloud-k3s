variable "cluster_name" {}

variable "seed" {
  type = object({
    name = string
    image = string
    server_type = string
    location = string
  })
}

variable "agents" {
  type = object({
    num = number
    config = object({
      prefix = string
      image = string
      server_type = string
      location = string
    })
  })
}

variable "hcloud_location" {
  default = "nbg1"
}
variable "private_ip_range" {
  default = "10.0.0.0/16"
}
variable "ssh_additional_key_id" {
  default = "default"
}
variable "private_network_name" {
  default = "default"
}
variable "private_network_zone" {
  default = "eu-central"
}
variable "floating_ip_name" {
  default = "default"
}

