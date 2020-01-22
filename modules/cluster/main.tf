resource "tls_private_key" "cluster" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource hcloud_ssh_key default {
  name = "${var.cluster_name}-key"
  public_key = tls_private_key.cluster.public_key_openssh
}

resource "hcloud_network" "default" {
  name = var.private_network_name
  ip_range = var.private_ip_range
}

resource "hcloud_network_subnet" "default" {
  network_id = hcloud_network.default.id
  type = "server"
  network_zone = var.private_network_zone
  ip_range = var.private_ip_range
}

resource "hcloud_floating_ip" "default" {
  type = "ipv4"
  home_location = var.hcloud_location
  name = var.floating_ip_name
}

resource "hcloud_server" "seed" {
  name = var.seed.name
  image = var.seed.image
  server_type = var.seed.server_type
  location = var.seed.location
  ssh_keys = [
    hcloud_ssh_key.default.id,
    var.ssh_additional_key_id]

  provisioner "remote-exec" {
    inline = [
      "yum -y install policycoreutils-python-utils"
    ]
    connection {
      host = self.ipv4_address
      type = "ssh"
      user = "root"
      private_key = tls_private_key.cluster.private_key_pem
    }
  }
}

resource "hcloud_server_network" "seed_network" {
  network_id = hcloud_network.default.id
  server_id = hcloud_server.seed.id
  ip = cidrhost(cidrsubnet(var.private_ip_range, 2, 0), 2)
}

resource "hcloud_floating_ip_assignment" "seed_float_ip" {
  floating_ip_id = hcloud_floating_ip.default.id
  server_id = hcloud_server.seed.id
}


resource "hcloud_server" "agents" {
  count = var.agents.num
  name = "${var.agents.config.prefix}-${count.index}"
  image = var.agents.config.image
  server_type = var.agents.config.server_type
  location = var.agents.config.location
  ssh_keys = [
    hcloud_ssh_key.default.id,
    var.ssh_additional_key_id
  ]


  provisioner "remote-exec" {
    inline = [
      "yum -y install policycoreutils-python-utils"
    ]
    connection {
      host = self.ipv4_address
      type = "ssh"
      user = "root"
      private_key = tls_private_key.cluster.private_key_pem
    }
  }
}


resource "hcloud_server_network" "agent_network" {
  count = var.agents.num

  network_id = hcloud_network.default.id
  server_id = hcloud_server.agents[count.index].id
  ip = cidrhost(cidrsubnet(var.private_ip_range, 2, 1), count.index + 2)
}
