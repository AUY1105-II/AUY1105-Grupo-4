output "ec2_public_ip" {
  description = "IP pública asignada a la instancia EC2 (si aplica)."
  value       = module.ec2_instance.public_ip
}

output "ec2_instance_name" {
  description = "Nombre lógico de la instancia (coincide con el argumento name del módulo EC2)."
  value       = "AUY1105-${var.project_name}-ec2"
}

output "vpc_name" {
  description = "Nombre configurado para la VPC."
  value       = module.vpc.name
}
