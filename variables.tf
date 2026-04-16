variable "project_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "my_ip" {
  description = "IP para acceso SSH"
  type        = string
  default     = "0.0.0.0/0"
}