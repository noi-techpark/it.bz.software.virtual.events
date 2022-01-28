resource "aws_route53_record" "cname_record" {
  zone_id = var.route53_zone_id     //aws_route53_zone.primary.zone_id
  name    = var.route53_record_name //"matrix.virtual.software.testingmachine.eu"
  type    = var.route53_record_type //"CNAME"
  ttl     = var.route53_record_ttl  //"5"
  records = var.route53_records //["elb-DNS"]
}