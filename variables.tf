variable "project_name" {
  description = "Nombre del proyecto"
  type        = string
  default     = "cheese-factory"
}

variable "environment" {
  description = "Entorno (dev, prod, etc.)"
  type        = string
  default     = "dev"
}

variable "my_ip" {
  description = "IP para acceso SSH"
  type        = string
  default     = "0.0.0.0/0"
}