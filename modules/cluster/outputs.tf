output cluster_name {
  value = var.cluster_name
}
output ip_range {
  value = var.private_ip_range
}

output seed_node {
  value = hcloud_server.seed
}
output seed_cluster_ip {
  value = hcloud_server_network.seed_network.ip
}

output server_nodes {
  value = [hcloud_server.seed]
}

output agent_nodes {
  value = hcloud_server.agents
}
output agent_cluster_ips {
  value = [hcloud_server_network.agent_network[*].ip]
}

output all_nodes {
  value = [
    concat(hcloud_server.agents, [hcloud_server.seed])
  ]
}
output cluster_public_key {
  value = tls_private_key.cluster.public_key_openssh
}
output cluster_private_key {
  value = tls_private_key.cluster.private_key_pem
}