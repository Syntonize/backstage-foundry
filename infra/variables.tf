variable "aws_region" {
  type = string
  default = "eu-west-1"
}

variable "vpc_id" {
  type = string
}

variable "app_name" {
  type = string
}

variable "app_domain" {
  type = string
}

variable "backstage_port" {
  type = number
}

variable "instance_type" {
  type = string
}

variable "volume_size" {
  type = number
}

variable "volume_type" {
  type = string
}

variable "az_devops_host" {
  type = string
  default = "dev.azure.com"
}

variable "az_devops_org" {
  type = string
}

variable "az_devops_project" {
  type = string
}

variable "az_devops_access_token" {
  type = string
}

variable "github_oauth_id" {
  type = string
}

variable "github_oauth_secret" {
  type = string
}
