resource "aws_route53_record" "cname_record" {
  zone_id = var.route53_zone_id
  name    = var.route53_record_name
  type    = var.route53_record_type
  ttl     = var.route53_record_ttl
  records = var.route53_records
}