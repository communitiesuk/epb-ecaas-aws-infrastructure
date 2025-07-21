# TODO: DELETE THIS AND ADJUST REFERENCES TO IT ONCE THE NEW CERT IS IN PLACE
resource "aws_acm_certificate" "cert-cdn" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
  provider = aws.us-east
}
