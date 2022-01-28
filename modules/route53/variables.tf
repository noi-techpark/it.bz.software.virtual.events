variable "route53_zone_id" {
  type = string
}

variable "route53_record_name" {
  type = string
}

variable "route53_record_type" {
  type    = string
  default = "CNAME"
}

variable "route53_record_ttl" {
  type    = string
  default = "300"
}

variable "route53_record_weight" {
  type    = number
  default = 10
}

variable "route53_records" {
  type = list(string)
}
