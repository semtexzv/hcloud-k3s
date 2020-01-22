resource "hcloud_ssh_key" "public" {
  name = "public"
  public_key = file("~/.ssh/id_ed25519.pub")
}

module "cluster" {
  source = "./modules/cluster"
  cluster_name = "trader"
  private_ip_range = var.net_ip_range

  ssh_additional_key_id = hcloud_ssh_key.public.id

  seed = {
    name = "seed"
    image = "centos-8"
    server_type = "cx11"
    location = var.zone
  }
  agents = {
    num = 2
    config = {
      prefix = "agent"
      image = "centos-8"
      server_type = "cx21"
      location = var.zone
    }
  }
}


module "k3s" {
  source = "./modules/k3s"

  cluster_name = "trader"

  cluster_cidr = {
    pods = "10.0.0.0/16"
    services = "10.1.0.0/16"
  }

  additional_flags = {
    server = [
      "--tls-san k3s.my.domain.com"
    ]
    agent = []
  }

  server_node = {
    # The node name will be automatically provided by
    # the module using this value... any usage of --node-name
    # in additional_flags will be ignored
    name = module.cluster.seed_node.name

    # This IP will be used as k3s master node IP.... if you want to use a public
    # address for the connection, use connection.host instead
    ip = module.cluster.seed_cluster_ip

    connection = {
      user = "root"
      host = module.cluster.seed_node.ipv4_address
      private_key = module.cluster.cluster_private_key
    }
  }

  agent_nodes = {
  for x in module.cluster.agent_nodes: x.name => {
    name = x.name
    ip = x.ipv4_address
    connection = {
      type = "ssh"
      user = "root"
      ip = x.ipv4_address
      private_key = module.cluster.cluster_private_key
    }
  }
  }
}