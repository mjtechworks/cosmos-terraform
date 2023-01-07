output "node_private_ips" {
    description = "private ips of nodes"
    value       = values(module.cascadia_nodes)[*].private_ip
}

output "node_public_ips" {
    description = "public ips of nodes"
    value       = values(module.cascadia_nodes)[*].public_ip
}
