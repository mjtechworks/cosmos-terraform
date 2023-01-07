output "private_ip" {
    description = "private ip"
    value = aws_instance.node.private_ip
}

output "public_ip" {
    description = "public ip"
    value = aws_instance.node.*.public_ip #associate_public_ip
}
