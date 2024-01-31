variable "vpc_cidr" {}
variable "azs" {}
variable "public_cidrs" {}
variable "private_cidrs" {}
variable "max_subnets" {}
variable "public_sn_count" {
  type = number
}
variable "private_sn_count" {
  type = number
}
variable "access_ip" {
  type = string
}
variable "db_subnet_group" {}
