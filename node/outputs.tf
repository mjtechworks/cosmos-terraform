output "private_ip" {
    description = "private ip"
    value = aws_instance.node.private_ip
}

output "public_ip" {
    description = "public ip"
    value = aws_instance.node.*.public_ip #associate_public_ip
}

output "primary_network_interface_id" {
    description = "network id"
    value = aws_instance.node.primary_network_interface_id #associate_public_ip
}
