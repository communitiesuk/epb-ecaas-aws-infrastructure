module "access" {
  source         = "./modules/access"
  ci_account_id  = var.ci_account_id
  hem_lambda_arn = module.api_gateway.hem_lambda_arn
}

module "api_gateway" {
  source              = "./modules/api_gateway"
  region              = var.region
  cdn_certificate_arn = module.cdn_certificate.certificate_arn
  domain_name         = var.domain_name
}

# This being on us-east-1 is a requirement for CloudFront to use the SSL certificate
module "cdn_certificate" {
  source = "./modules/ssl"
  providers = {
    aws = aws.us-east
  }
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
}

module "front_end" {
  source              = "./modules/front_end"
  front_end_s3_bucket_name = "epb-ecaas-front-end-s3-bucket"
}