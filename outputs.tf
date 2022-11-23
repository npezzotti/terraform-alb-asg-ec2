output "application_url" {
  description = "Application URL"
  value       = "http://${aws_lb.main.dns_name}"
}