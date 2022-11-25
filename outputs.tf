output "asg_name" {
  description = "Autoscaling group name"
  value = aws_autoscaling_group.main.name
}

output "application_url" {
  description = "Application URL"
  value       = "http://${aws_lb.main.dns_name}"
}