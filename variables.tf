variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "project_name" {
  description = "Name of project"
  type        = string
}

variable "environment" {
  description = "Environment"
  type        = string
}

variable "ssh_key_path" {
  description = "Path to directory containing SSH key"
  type        = string
  default     = ".ssh"
}

variable "subnets" {
  description = "Subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "region" {
  description = "AWS region"
  type        = string
}
