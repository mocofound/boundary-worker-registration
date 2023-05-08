variable "boundary_cluster_url" {
}

variable "boundary_cluster_id"{
}

variable "boundary_username" {
}

variable "boundary_password" {
}

variable "boundary_auth_method_id" {
}

variable "region" {
  default = "us-east-2"
}

variable "use_hcp_packer" {
  default = true
}

variable "scope_id" {
  default = "global"
}

variable "prefix" {
    type = string
    description = "prefix for resources"
    default = "boundary"
}

variable "vpc_id" {
    type = string
    description = "id of vpc"
}

variable "subnet_id" {
    type = string
    description = "id of subnet"
}

variable "server_count" {
    default = 1
}

variable "key_name" {
  type = string
  default = "ahar-keypair-2024"
}

variable "server_instance_type" {
  description = "The AWS instance type to use for servers."
  default     = "t3.micro"
}

variable "root_block_device_size" {
  description = "The volume size of the root block device."
  default     = 16
}

variable "initial_upstreams" {
  default = ["db50eb6a-848c-4300-d908-62dc1d7119db.proxy.boundary.hashicorp.cloud:9202","e4a10e80-e73c-cb96-7d39-8652b7f7d186.proxy.boundary.hashicorp.cloud:9202","10f8794a-237a-b459-9fdd-a44a370a9f20.proxy.boundary.hashicorp.cloud:9202"]
}
