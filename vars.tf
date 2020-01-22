variable "hcloud_token" {
  default = "FILL_ME"
  type = string
}

variable "zone" {
  default = "fsn1"
}
variable "net_ip_range" {
  default = "10.0.0.0/24"
}

provider "hcloud" {
  token = var.hcloud_token
}
