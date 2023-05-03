variable "boundary_cluster_url" {
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