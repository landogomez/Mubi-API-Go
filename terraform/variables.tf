variable "aws_profile" {
  description = "Nombre del perfil de AWS CLI a utilizar"
  type        = string
  default     = "default" # O el nombre que uses normalmente
}

variable "project_name" {
  default = "muvi"
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "Rango de IPs para la VPC principal"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Rango de IPs para la subred pública (API)"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.2.0/24", "10.0.3.0/24"]
}