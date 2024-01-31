output "vpc_id" {
  value = aws_vpc.lab_vpc.id
  # "ID" extracted from networking/main.tf
}

output "public_subnets" {
  value = aws_subnet.lab_public_subnet.*.id
}

output "webservers_sg" {
  value = aws_security_group.webservers_sg.id
}

output "loadbalancer_sg" {
  value = aws_security_group.loadbalancer_sg.id
}

output "generalpurpose_sg" {
  value = aws_security_group.generalpurpose_sg.id
}