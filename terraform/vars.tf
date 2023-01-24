variable "application" {
  type        = string
  description = "Application Name (used as prefix on AWS resources)"
}

variable "aws_region" {
  type    = string
  default = "us-west-2"
}

variable "ecs_memory" {
  type        = number
  description = "Memory for ECS"
  default     = 512
}

variable "ecs_cpu" {
  type        = number
  description = "CPU for ECS"
  default     = 256
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "tls_certificate" {
  type        = string
  description = "TLS certificate"
  default     = ""
  sensitive   = true
}

variable "tls_key" {
  type        = string
  description = "TLS private key"
  default     = ""
  sensitive   = true
}

variable "tls_chain" {
  type        = string
  description = "TLS Chain / CA Bundle"
  default     = ""
  sensitive   = true
}


variable "vpc_cidr" {
  type    = string
  default = "10.10.0.0/16"
}
