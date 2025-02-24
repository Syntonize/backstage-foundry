variable "app_name" {
  type = string
}

variable "app_version" {
  type = string
}

variable "ecr_uri" {
  type = string
  default = "851725456314.dkr.ecr.eu-west-1.amazonaws.com"
}
