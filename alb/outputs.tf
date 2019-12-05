output "alb_dns_name" {
  value = aws_alb.my-aws-alb.dns_name
}

output "alb_target_group_arn" {
  value = aws_alb_target_group.my-target-group.arn
}